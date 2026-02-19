#!/bin/bash
set -e

# dex installation script
# Usage: curl -fsSL https://github.com/modiqo/dex-releases/releases/latest/download/install.sh | bash
# Non-interactive: DEX_YES=1 curl -fsSL ... | bash

# Configuration
REPO="modiqo/dex-releases"
INSTALL_DIR="${DEX_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${DEX_VERSION:-latest}"
AUTO_YES="${DEX_YES:-}"

# ─── Log setup ───────────────────────────────────────────────────────────────
LOG_DIR="$HOME/.dex/log"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install.log"
: > "$LOG_FILE"   # truncate previous log

log_file() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Restore cursor on exit (in case spinner hides it and script is interrupted)
trap 'printf "\033[?25h" >&2' EXIT

# ─── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Spinner engine ─────────────────────────────────────────────────────────
#
# Single approach: foreground spinner loop, background command.
# The spinner runs in the main process — no orphans, no race conditions.
#
# Usage:
#   spin "phase" "message" "wit1|wit2" command arg1 arg2
#   Returns: exit code of command. Stdout captured in $SPIN_STDOUT.

SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

spin() {
    local phase="$1"; shift
    local message="$1"; shift
    local wit_string="$1"; shift
    local success_msg="$1"; shift
    # Remaining "$@" is the command to run

    local start_time=$(date +%s)
    IFS='|' read -ra wits <<< "$wit_string"

    # Temp file for capturing stdout from the command
    local out_file=$(mktemp /tmp/dex_out.XXXXXX)

    # Run command in background, stdout to file, stderr to log
    "$@" > "$out_file" 2>>"$LOG_FILE" &
    local cmd_pid=$!

    local i=0 wit_idx=0 wit_count=${#wits[@]} ticks=0

    # Hide cursor during spinner to avoid blinking artifact
    printf "\033[?25l" >&2

    # Foreground spinner — naturally terminates when bg process exits
    while kill -0 "$cmd_pid" 2>/dev/null; do
        local frame="${SPINNER_FRAMES[$((i % ${#SPINNER_FRAMES[@]}))]}"
        local wit="${wits[$wit_idx]}"
        printf "\r  ${CYAN}%s${NC}  %-10s %s\033[K" "$frame" "$phase" "$message" >&2
        printf "\n             ${DIM}%s${NC}\033[K\033[A" "$wit" >&2
        sleep 0.08
        i=$((i + 1))
        ticks=$((ticks + 1))
        if [ $ticks -ge 30 ] && [ $wit_count -gt 1 ]; then
            ticks=0
            wit_idx=$(( (wit_idx + 1) % wit_count ))
        fi
    done

    # Capture exit code from wait (|| true prevents set -e from killing us)
    local rc=0
    wait "$cmd_pid" 2>/dev/null || rc=$?
    SPIN_STDOUT=$(cat "$out_file" 2>/dev/null)
    rm -f "$out_file"

    # Elapsed time
    local now=$(date +%s)
    local secs=$((now - start_time))
    local elapsed=""
    if [ $secs -ge 60 ]; then
        elapsed="${DIM}$((secs / 60))m$((secs % 60))s${NC}"
    else
        elapsed="${DIM}${secs}s${NC}"
    fi

    # Restore cursor, then clear spinner + wit line
    printf "\033[?25h" >&2
    printf "\r\033[K\n\033[K\033[A" >&2

    # Auto-print success line if success_msg is provided
    if [ "$rc" = "0" ] && [ -n "$success_msg" ]; then
        printf "\r  ${GREEN}✓${NC}  %-10s %s  %b\n" "$phase" "$success_msg" "$elapsed" >&2
        log_file "✓ [$phase] $success_msg"
    fi

    # Store for callers that need custom handling
    LAST_PHASE="$phase"
    LAST_ELAPSED="$elapsed"
    return "$rc"
}

# Result printers for when spin's built-in success line isn't enough
spin_ok() {
    printf "\r  ${GREEN}✓${NC}  %-10s %s  %b\n" "$LAST_PHASE" "$1" "$LAST_ELAPSED" >&2
    log_file "✓ [$LAST_PHASE] $1"
}

spin_warn() {
    printf "\r  ${YELLOW}⚠${NC}  %-10s %s  %b\n" "$LAST_PHASE" "$1" "$LAST_ELAPSED" >&2
    log_file "⚠ [$LAST_PHASE] $1"
}

spin_fail() {
    printf "\r  ${RED}✗${NC}  %-10s %s\n" "$LAST_PHASE" "$1" >&2
    log_file "✗ [$LAST_PHASE] $1"
}

# Instant step markers (no spinner)
step_ok() {
    printf "  ${GREEN}✓${NC}  %-10s %s\n" "$1" "$2" >&2
    log_file "✓ [$1] $2"
}

step_warn() {
    printf "  ${YELLOW}⚠${NC}  %-10s %s\n" "$1" "$2" >&2
    log_file "⚠ [$1] $2"
}

step_skip() {
    printf "  ${DIM}·${NC}  ${DIM}%-10s %s${NC}\n" "$1" "$2" >&2
    log_file "· [$1] $2"
}

# ─── Read user input (works in curl | bash) ──────────────────────────────────
prompt_user() {
    if [ -t 0 ]; then
        read -r "$@"
    else
        read -r "$@" </dev/tty
    fi
}

# ─── Shell detection ─────────────────────────────────────────────────────────
detect_shell_config() {
    case "$SHELL" in
        */zsh) echo "$HOME/.zshrc" ;;
        */bash)
            if [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            else
                echo "$HOME/.bash_profile"
            fi
            ;;
        *) echo "" ;;
    esac
}

detect_shell_name() {
    case "$SHELL" in
        */zsh) echo "zsh" ;;
        */bash) echo "bash" ;;
        *) echo "" ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
# Detect platform
# ═══════════════════════════════════════════════════════════════════════════════
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)

    case "$os" in
        linux)   OS="linux" ;;
        darwin)  OS="macos" ;;
        mingw* | msys* | cygwin*) OS="windows" ;;
        *)
            printf "  ${RED}✗${NC}  %-10s Unsupported OS: %s\n" "detect" "$os" >&2
            exit 1
            ;;
    esac

    case "$arch" in
        x86_64 | amd64) ARCH="x86_64" ;;
        aarch64 | arm64) ARCH="aarch64" ;;
        *)
            printf "  ${RED}✗${NC}  %-10s Unsupported arch: %s\n" "detect" "$arch" >&2
            exit 1
            ;;
    esac

    case "$OS-$ARCH" in
        linux-x86_64)   ARTIFACT="dex-linux-x86_64-musl";  ARCHIVE_EXT="tar.gz" ;;
        linux-aarch64)  ARTIFACT="dex-linux-aarch64-musl";  ARCHIVE_EXT="tar.gz" ;;
        macos-x86_64)   ARTIFACT="dex-macos-x86_64";       ARCHIVE_EXT="tar.gz" ;;
        macos-aarch64)  ARTIFACT="dex-macos-aarch64";       ARCHIVE_EXT="tar.gz" ;;
        windows-x86_64) ARTIFACT="dex-windows-x86_64";     ARCHIVE_EXT="zip" ;;
        *)
            printf "  ${RED}✗${NC}  %-10s No binary for %s\n" "detect" "$OS-$ARCH" >&2
            echo "         Build from source: https://github.com/modiqo/dex" >&2
            exit 1
            ;;
    esac

    log_file "Platform: $OS-$ARCH, Artifact: $ARTIFACT"
}

# ═══════════════════════════════════════════════════════════════════════════════
# Install sequence
# ═══════════════════════════════════════════════════════════════════════════════
install_dex() {
    local download_url="https://github.com/$REPO/releases/download/v${VERSION}/${ARTIFACT}.${ARCHIVE_EXT}"
    local tmp_dir=$(mktemp -d)
    local archive_file="$tmp_dir/dex.${ARCHIVE_EXT}"

    log_file "Download URL: $download_url"

    # ── download ──────────────────────────────────────────────────────────
    if spin "download" "Downloading dex v${VERSION}..." \
        "Downloading at the speed of bureaucracy...|Patience is a virtue, bandwidth is a resource|Bits are flying across the wire...|Almost there... probably" \
        "Downloaded dex v${VERSION}" \
        curl -fsSL "$download_url" -o "$archive_file"; then
        :
    else
        spin_fail "Download failed — check $LOG_FILE"
        rm -rf "$tmp_dir"
        exit 1
    fi

    # ── extract ───────────────────────────────────────────────────────────
    local extract_cmd=""
    case "$ARCHIVE_EXT" in
        tar.gz) extract_cmd="tar xzf $archive_file -C $tmp_dir" ;;
        zip)    extract_cmd="unzip -q $archive_file -d $tmp_dir" ;;
    esac

    if spin "extract" "Extracting archive..." \
        "Unpacking the good stuff...|Like opening a birthday present|Decompressing knowledge..." \
        "Archive extracted" \
        bash -c "$extract_cmd"; then
        :
    else
        spin_fail "Extraction failed"
        rm -rf "$tmp_dir"
        exit 1
    fi

    # ── install binary ────────────────────────────────────────────────────
    mkdir -p "$INSTALL_DIR"

    if [ "$OS" = "windows" ]; then
        mv "$tmp_dir/dex.exe" "$INSTALL_DIR/dex.exe"
        chmod +x "$INSTALL_DIR/dex.exe"
        BINARY_PATH="$INSTALL_DIR/dex.exe"
    else
        mv "$tmp_dir/dex" "$INSTALL_DIR/dex"
        chmod +x "$INSTALL_DIR/dex"
        BINARY_PATH="$INSTALL_DIR/dex"
        if [ -f "$tmp_dir/dex-stdio-daemon" ]; then
            mv "$tmp_dir/dex-stdio-daemon" "$INSTALL_DIR/dex-stdio-daemon"
            chmod +x "$INSTALL_DIR/dex-stdio-daemon"
            log_file "Installed dex-stdio-daemon"
        fi
    fi

    rm -rf "$tmp_dir"
    step_ok "install" "Installed to $BINARY_PATH"

    # ── verify ────────────────────────────────────────────────────────────
    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        step_warn "path" "$INSTALL_DIR is not in your PATH"
        echo "         Add to your shell profile:  export PATH=\"$INSTALL_DIR:\$PATH\"" >&2
    fi

    if command -v dex >/dev/null 2>&1; then
        local ver_output
        ver_output=$(dex --version 2>/dev/null || echo "unknown")
        step_ok "verify" "dex responds: $ver_output"
    else
        step_warn "verify" "dex not found in PATH — restart your shell after install"
    fi

    # ── node.js ───────────────────────────────────────────────────────────
    if command -v dex >/dev/null 2>&1; then
        if spin "node" "Installing Node.js runtime..." \
            "Teaching your machine JavaScript... sorry in advance|npm install universe --save|Every great stack starts with node_modules" \
            "Node.js runtime installed" \
            dex node install; then
            :
        else
            spin_warn "Node.js install failed — run: dex node install"
        fi
    fi

    # ── path config ───────────────────────────────────────────────────────
    if [ -d "$HOME/.dex/bin" ]; then
        case ":$PATH:" in
            *":$HOME/.dex/bin:"*) ;;
            *) export PATH="$HOME/.dex/bin:$PATH" ;;
        esac

        SHELL_CONFIG=$(detect_shell_config)
        if [ -n "$SHELL_CONFIG" ] && ! grep -qF '/.dex/bin' "$SHELL_CONFIG" 2>/dev/null; then
            echo "" >> "$SHELL_CONFIG"
            echo "# dex bundled runtimes (node, npm, npx, deno)" >> "$SHELL_CONFIG"
            echo 'export PATH="$HOME/.dex/bin:$PATH"' >> "$SHELL_CONFIG"
            step_ok "path" "Added ~/.dex/bin to PATH in $SHELL_CONFIG"
        else
            step_ok "path" "~/.dex/bin already in PATH"
        fi
    fi

    # ── playwright ────────────────────────────────────────────────────────
    if command -v npx >/dev/null 2>&1; then
        if spin "browser" "Installing Playwright Chrome..." \
            "Summoning headless Chrome... the friendly ghost|Browsers: can't live with 'em, can't scrape without 'em|This one takes a minute — good time for coffee|Chrome is packing its bags..." \
            "Playwright Chrome installed" \
            npx -y @playwright/test install --with-deps chrome; then
            :
        else
            spin_warn "Playwright failed — run: npx -y @playwright/test install --with-deps chrome"
        fi
    fi

    # ── stdio servers ─────────────────────────────────────────────────────
    if command -v dex >/dev/null 2>&1; then
        if spin "stdio" "Initializing MCP servers..." \
            "Wiring up the plumbing...|Connecting the dots, literally|Server handshakes in progress..." \
            "MCP stdio servers configured" \
            dex stdio init-baseline; then
            :
        else
            spin_warn "stdio init failed — run: dex stdio init-baseline"
        fi
    fi

    # ── deno + sdk (interactive) ──────────────────────────────────────────
    if command -v dex >/dev/null 2>&1; then
        echo "" >&2
        if [ -n "$AUTO_YES" ]; then
            response="Y"
        else
            printf "  ${CYAN}?${NC}  %-10s Install Deno runtime for TypeScript flows? ${DIM}[Y/n]${NC} " "deno" >&2
            prompt_user response
            response=${response:-Y}
        fi

        if [ "$response" = "Y" ] || [ "$response" = "y" ]; then
            if spin "deno" "Installing Deno runtime..." \
                "Adding another runtime to the collection...|Deno: Node spelled sideways (almost)|TypeScript deserves a good home" \
                "Deno runtime installed" \
                dex deno install; then

                if spin "sdk" "Installing TypeScript SDK..." \
                    "Loading the good TypeScript...|SDK: Software Development Konfidence|Flows need foundations..." \
                    "TypeScript SDK installed → ~/.dex/lib/sdk/ts/" \
                    dex sdk install; then
                    :
                else
                    spin_warn "SDK install failed — run: dex sdk install"
                fi
            else
                spin_warn "Deno install failed — run: dex deno install"
            fi
        else
            step_skip "deno" "Skipped — run later: dex deno install && dex sdk install"
        fi
    fi

    # ── shell setup (interactive) ─────────────────────────────────────────
    if command -v dex >/dev/null 2>&1; then
        echo "" >&2
        if [ -n "$AUTO_YES" ]; then
            response="Y"
        else
            printf "  ${CYAN}?${NC}  %-10s Set up shell integration? (completions, dex-cd) ${DIM}[Y/n]${NC} " "shell" >&2
            prompt_user response
            response=${response:-Y}
        fi

        if [ "$response" = "Y" ] || [ "$response" = "y" ]; then
            if spin "shell" "Setting up shell integration..." \
                "Teaching your terminal new tricks...|Tab completion is a lifestyle|Your shell is about to level up" \
                "Shell integration files created" \
                dex shell-setup; then
                :
            else
                spin_warn "Shell setup failed — run: dex shell-setup"
            fi

            SHELL_CONFIG=$(detect_shell_config)
            SHELL_NAME=$(detect_shell_name)

            if [ -n "$SHELL_CONFIG" ]; then
                if ! grep -qF "dex/shell/init.sh" "$SHELL_CONFIG" 2>/dev/null; then
                    echo "" >> "$SHELL_CONFIG"
                    echo "# dex shell integration" >> "$SHELL_CONFIG"
                    echo '[ -f ~/.dex/shell/init.sh ] && source ~/.dex/shell/init.sh' >> "$SHELL_CONFIG"
                    step_ok "shell" "Added shell integration to $SHELL_CONFIG"
                else
                    step_ok "shell" "Shell integration already in $SHELL_CONFIG"
                fi

                if [ -n "$SHELL_NAME" ] && ! grep -qF "dex completion" "$SHELL_CONFIG" 2>/dev/null; then
                    echo "" >> "$SHELL_CONFIG"
                    echo "# dex completion" >> "$SHELL_CONFIG"
                    echo "eval \"\$(dex completion $SHELL_NAME)\"" >> "$SHELL_CONFIG"
                    step_ok "shell" "Added tab completion to $SHELL_CONFIG"
                fi

                echo "" >&2
                printf "  ${DIM}         Restart your shell or run: source %s${NC}\n" "$SHELL_CONFIG" >&2
            else
                echo "" >&2
                echo "  Add to your shell config:" >&2
                echo "    [ -f ~/.dex/shell/init.sh ] && source ~/.dex/shell/init.sh" >&2
            fi
        else
            step_skip "shell" "Skipped — run later: dex shell-setup"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════════
main() {
    echo "" >&2
    printf "  ${BOLD}dex installer${NC} ${DIM}· Execution Context Engineering${NC}\n" >&2
    echo "" >&2

    log_file "=== dex installation started ==="
    log_file "Installer invoked at $(date)"

    # Detect platform (instant, no spinner)
    detect_platform
    step_ok "detect" "Platform: $OS-$ARCH"

    # Resolve version (needs to capture stdout to set VERSION)
    if spin "fetch" "Resolving latest version..." \
        "Consulting the oracle...|Asking GitHub nicely...|Version numbers: the spice of life" \
        "" \
        bash -c '
            REPO="'"$REPO"'"
            VER="'"$VERSION"'"
            LOG="'"$LOG_FILE"'"
            if [ "$VER" = "latest" ]; then
                VER=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" 2>>"$LOG" \
                    | grep "\"tag_name\":" | sed -E "s/.*\"v([^\"]+)\".*/\1/")
                if [ -z "$VER" ]; then exit 1; fi
            fi
            echo "$VER"
        '; then
        VERSION="$SPIN_STDOUT"
        spin_ok "Resolved version: v$VERSION"
    else
        spin_fail "Failed to fetch latest version"
        exit 1
    fi

    log_file "Version resolved: v$VERSION"

    # Install sequence
    install_dex

    # ── Finale ────────────────────────────────────────────────────────────
    echo "" >&2
    printf "  ${DIM}─────────────────────────────────────────────${NC}\n" >&2
    echo "" >&2
    printf "  ${YELLOW}Plot twist:${NC} We're not AGI yet.\n" >&2
    printf "  ${YELLOW}Humans still required.${NC}\n" >&2
    echo "" >&2
    printf "  ${GREEN}dex setup${NC}   Zero to value in under 60 seconds.\n" >&2
    printf "  ${DIM}            Adapters, tokens, flows. Done.${NC}\n" >&2
    echo "" >&2
    printf "  ${CYAN}dex human${NC}   For those who read the manual\n" >&2
    printf "  ${DIM}            before assembling the furniture.${NC}\n" >&2
    echo "" >&2
    printf "  ${DIM}Full log: %s${NC}\n" "$LOG_FILE" >&2
    echo "" >&2

    log_file "=== dex installation complete ==="
}

main

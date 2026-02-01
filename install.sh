#!/bin/bash
set -e

# dex installation script
# Usage: curl -fsSL https://github.com/modiqo/dex-releases/releases/latest/download/install.sh | bash

# Configuration
REPO="modiqo/dex-releases"
INSTALL_DIR="${DEX_INSTALL_DIR:-$HOME/.local/bin}"
VERSION="${DEX_VERSION:-latest}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS and architecture
detect_platform() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)

    case "$os" in
        linux)
            OS="linux"
            ;;
        darwin)
            OS="macos"
            ;;
        mingw* | msys* | cygwin*)
            OS="windows"
            ;;
        *)
            log_error "Unsupported operating system: $os"
            exit 1
            ;;
    esac

    case "$arch" in
        x86_64 | amd64)
            ARCH="x86_64"
            ;;
        aarch64 | arm64)
            ARCH="aarch64"
            ;;
        *)
            log_error "Unsupported architecture: $arch"
            exit 1
            ;;
    esac

    # Determine artifact name (matches GitHub Actions artifact names)
    # For Linux, prefer musl (static) builds for maximum compatibility
    case "$OS-$ARCH" in
        linux-x86_64)
            ARTIFACT="dex-linux-x86_64-musl"
            ARCHIVE_EXT="tar.gz"
            ;;
        linux-aarch64)
            ARTIFACT="dex-linux-aarch64-musl"
            ARCHIVE_EXT="tar.gz"
            ;;
        macos-x86_64)
            ARTIFACT="dex-macos-x86_64"
            ARCHIVE_EXT="tar.gz"
            ;;
        macos-aarch64)
            ARTIFACT="dex-macos-aarch64"
            ARCHIVE_EXT="tar.gz"
            ;;
        windows-x86_64)
            ARTIFACT="dex-windows-x86_64"
            ARCHIVE_EXT="zip"
            ;;
        *)
            log_error "No prebuilt binary for $OS-$ARCH"
            log_info "You can build from source: https://github.com/modiqo/dex"
            exit 1
            ;;
    esac

    log_info "Detected platform: $OS-$ARCH (using static musl build for Linux)"
}

# Get latest version
get_latest_version() {
    if [ "$VERSION" = "latest" ]; then
        log_info "Fetching latest version..."
        VERSION=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [ -z "$VERSION" ]; then
            log_error "Failed to fetch latest version"
            exit 1
        fi
        log_info "Latest version: v$VERSION"
    fi
}

# Download and install
install_dex() {
    local download_url="https://github.com/$REPO/releases/download/v${VERSION}/${ARTIFACT}.${ARCHIVE_EXT}"
    local tmp_dir=$(mktemp -d)
    local archive_file="$tmp_dir/dex.${ARCHIVE_EXT}"

    log_info "Downloading dex v${VERSION}..."
    log_info "URL: $download_url"

    if ! curl -fsSL "$download_url" -o "$archive_file"; then
        log_error "Download failed"
        rm -rf "$tmp_dir"
        exit 1
    fi

    log_info "Extracting archive..."
    cd "$tmp_dir"
    
    case "$ARCHIVE_EXT" in
        tar.gz)
            tar xzf "$archive_file"
            ;;
        zip)
            unzip -q "$archive_file"
            ;;
    esac

    # Create install directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"

    # Install binary
    log_info "Installing to $INSTALL_DIR/dex..."
    if [ "$OS" = "windows" ]; then
        mv dex.exe "$INSTALL_DIR/dex.exe"
        chmod +x "$INSTALL_DIR/dex.exe"
        BINARY_PATH="$INSTALL_DIR/dex.exe"
    else
        mv dex "$INSTALL_DIR/dex"
        chmod +x "$INSTALL_DIR/dex"
        BINARY_PATH="$INSTALL_DIR/dex"
    fi

    # Cleanup
    rm -rf "$tmp_dir"

    log_info "${GREEN}✓${NC} dex v${VERSION} installed successfully!"
    echo
    log_info "Binary location: $BINARY_PATH"
    
    # Check if install dir is in PATH
    if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
        log_warn "$INSTALL_DIR is not in your PATH"
        echo
        echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        echo
    fi

    # Verify installation
    if command -v dex >/dev/null 2>&1; then
        echo "Verify installation:"
        echo "  $ dex --version"
        dex --version 2>/dev/null || log_warn "Could not verify version (check PATH)"
    else
        log_warn "dex command not found in PATH. You may need to restart your shell."
    fi

    # Initialize baseline stdio MCP servers
    if command -v dex >/dev/null 2>&1; then
        echo
        log_info "Initializing baseline stdio MCP servers..."
        if dex stdio init-baseline 2>/dev/null; then
            log_info "${GREEN}✓${NC} stdio servers configured"
        else
            log_warn "stdio initialization failed (run manually: dex stdio init-baseline)"
        fi
    fi
    
    # Offer to install Deno runtime for TypeScript SDK flows
    if command -v dex >/dev/null 2>&1; then
        echo
        echo -n "Install Deno runtime for TypeScript flows? [Y/n] "
        read -r response
        response=${response:-Y}

        if [ "$response" = "Y" ] || [ "$response" = "y" ]; then
            echo
            log_info "Installing Deno runtime..."
            if dex deno install 2>/dev/null; then
                echo
                log_info "${GREEN}✓${NC} Deno runtime installed!"
                echo
                echo "Run 'dex deno status' to verify installation."

                # Also install the TypeScript SDK
                echo
                log_info "Installing TypeScript SDK..."
                if dex sdk install 2>/dev/null; then
                    echo
                    log_info "${GREEN}✓${NC} TypeScript SDK installed!"
                    echo
                    echo "SDK location: ~/.dex/lib/sdk/ts/"
                    echo "Run 'dex sdk status' to verify installation."
                else
                    log_warn "SDK installation failed. Run manually: dex sdk install"
                fi
            else
                log_warn "Deno installation failed. Run manually: dex deno install"
            fi
        else
            echo
            log_info "Skipped Deno + SDK installation. Run later:"
            echo "  dex deno install"
            echo "  dex sdk install"
        fi
    fi

    # Offer to run shell-setup automatically
    if command -v dex >/dev/null 2>&1; then
        echo
        echo -n "Set up shell integration now? (completions, dex-cd) [Y/n] "
        read -r response
        response=${response:-Y}

        if [ "$response" = "Y" ] || [ "$response" = "y" ]; then
            echo
            log_info "Running dex shell-setup..."
            if dex shell-setup 2>/dev/null; then
                echo
                log_info "${GREEN}✓${NC} Shell integration configured!"
                echo
                echo "Add this line to your shell config (~/.zshrc or ~/.bashrc):"
                echo "  [ -f ~/.dex/shell/init.sh ] && source ~/.dex/shell/init.sh"
                echo
                echo "Then restart your shell or run: source ~/.zshrc"
            else
                log_warn "Shell setup failed. Run manually: dex shell-setup"
            fi
        else
            echo
            log_info "Skipped shell setup. Run later: dex shell-setup"
        fi
    fi

    # Fun message at the very end
    echo
    echo "========================================="
    echo -e "  ${YELLOW}Plot twist:${NC} We're not AGI yet."
    echo -e "  ${YELLOW}Humans still required.${NC}"
    echo "========================================="
    echo
    echo -e "[INFO] Run ${GREEN}dex human${NC} to see your journey"
    echo "  (We'll tell you what to do next. Promise it's fun.)"
    echo
}

# Main
main() {
    echo "========================================="
    echo "  dex Installer"
    echo "  Execution Context Engineering"
    echo "========================================="
    echo

    detect_platform
    get_latest_version
    install_dex
}

main


# mq - Execution Context Engineering

> **Deterministic agent-tool orchestration through embedded guidance and self-reflective languages.**

<img src="images/mq_3.png" alt="mq screenshot" height="200">

## What is mq?

mq sits **between your AI agent and MCP servers**, creating a self-reflective learning loop that captures action sequences for future reuse.

### How Agents Use mq

Agents use mq as their primary tool for MCP interactions. When an agent uses mq, it unlocks:

**1. Self-Reflective Correction Loop**

As the agent executes commands, mq observes and provides real-time feedback:

```bash
Agent: mq tools /gmail-mcp --names-only -s
mq: [HINT] Invalid flag '-s' for tools command
    Fix: mq tools /gmail-mcp --names-only

Agent: <applies fix>
mq: OK - Command succeeded
```

The agent learns through iteration—mq catches mistakes and shows the correct pattern immediately.

**2. Action Sequence Recording**

Every command the agent executes is recorded. When the task is accomplished, the entire action sequence is stored as a reusable script:

```bash
First time agent does "Get 5 recent emails":
  mq init fetch-emails --seq
  mq set max_results=5
  mq init-session /gmail-mcp
  mq POST /gmail-mcp '{"maxResults":$max_results}' -t -s
  → mq export ~/.mq/flows/gmail/recent.sh --params max_results

Second time agent needs "Get 10 recent emails":
  → ~/.mq/flows/gmail/recent.sh 10  (2 seconds, 250 tokens)
```

**3. Future Replay Without Re-Learning**

Once recorded, the agent doesn't rediscover—it just invokes the saved sequence:

- No tool discovery needed
- No schema reading needed  
- No trial-and-error needed
- Just execute and get results

### The mq Layer

```
┌─────────────────────────────────┐
│ AI Agent (Cursor, Claude, etc.) │
└────────────┬────────────────────┘
             │ uses mq commands
             ▼
┌─────────────────────────────────────────────┐
│ mq (learning substrate)                     │
│  • Records action sequences                 │
│  • Provides real-time correction hints      │
│  • Stores successful sequences for replay   │
│  • Caches responses for instant re-query    │
└────────────┬────────────────────────────────┘
             │ makes API calls
             ▼
┌─────────────────────────────────┐
│ MCP Servers (Gmail, GitHub...)  │
└─────────────────────────────────┘
```

### Time and Token Savings

**First execution (30 seconds, 12,000 tokens):**
- Agent explores → makes mistakes → gets corrected by mq
- Agent discovers tools → mq records each action
- Agent makes API calls → mq caches responses
- Task accomplished → mq stores the successful sequence

**Subsequent executions (2 seconds, 250 tokens):**
- Agent searches: "fetch emails" → finds saved sequence
- Agent invokes: `~/.mq/flows/gmail/recent.sh 10`
- Done—no re-learning, no re-discovery, no mistakes

**Concrete Savings:**
- **Time**: 93% faster (30s → 2s)
- **Tokens**: 90%+ reduction (12,000 → 250)
- **Reliability**: Same action sequence every time

> **Agents learn once. Recall forever. Save 90% of tokens on repeat tasks.**

[![CI](https://github.com/modiqo/mq/workflows/CI/badge.svg)](https://github.com/modiqo/mq/actions/workflows/ci.yml)
[![Release](https://github.com/modiqo/mq/workflows/Release/badge.svg)](https://github.com/modiqo/mq/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/release/modiqo/mq.svg)](https://github.com/modiqo/mq/releases/latest)

mq optimizes the MCP development cycle by caching responses and reifying interactive sessions to deterministic scripts.

**Key Optimizations:**

1. **Iteration Speed:** Execute once, query unlimited times from cache (vs re-executing on every query mistake)
2. **Token Efficiency:** Reified flows use ~250 tokens vs ~12,000 tokens for agent-driven discovery (97% reduction)
3. **Development Velocity:** 2 seconds to replay cached context vs 30 seconds to rebuild from scratch

**The Problem:** Agent frameworks treat every execution as fresh exploration, re-executing HTTP calls and storing responses in context.

**The Solution:** mq treats exploration as a reification phase—capture once, translate to script, invoke deterministically forever.

**Author:** Chetan Conikee <chetan@modiqo.ai>  
**License:** MIT  
**Repository:** https://github.com/modiqo/mq  
**Documentation:** https://modiqo.github.io/mq  

**Read:** [Why mq exists](docs/design_considerations/motivation.md) - Understanding the token economics problem in agent frameworks

---

## Novel Architecture: Embedded Guidance and Error-Driven Learning

mq pioneers three architectural patterns for execution context engineering:

### 1. Embedded Guidance: Tools as Self-Documenting Metadata

Traditional tools separate documentation from execution. mq embeds guidance directly in the tool as queryable metadata:

```bash
mq guidance modiqo essential  # Returns 800-line protocol guide
mq guidance agent             # Returns general agent steering
```

The guidance isn't external documentation—it's part of the tool's interface, embedded in the binary. This reduces discovery tokens by eliminating external context lookups:

- **Version-synchronized:** Guidance ships with binary, always in sync
- **Queryable:** Agents retrieve only relevant sections
- **Executable:** Examples are runnable code, not prose
- **No hallucination:** Guidance is ground truth, not LLM-generated

**Token Impact:** ~2,000 tokens for complete protocol vs ~12,000 tokens for rediscovery through trial-and-error.

### 2. Error-Driven Learning Loop: Self-Correcting Through Targeted Hints

When agents make mistakes, mq doesn't just report errors—it provides targeted, actionable hints that **force reflection**:

```bash
$ mq tools /gmail-mcp --names-only -s
Error: Invalid configuration: Unknown flag '-s'

╔═══════════════════════════════════════════════════════════════════╗
║                        STOP: ERROR DETECTED                       ║
║            DO NOT PROCEED WITHOUT ADDRESSING THIS ERROR           ║
╚═══════════════════════════════════════════════════════════════════╝

[HINT] Configuration error.
  Your command: mq tools /gmail-mcp --names-only -s
  
╔═══════════════════════════════════════════════════════════════════╗
║                        FOR AI AGENTS:                             ║
╚═══════════════════════════════════════════════════════════════════╝

Before proceeding, you MUST:
  1. Explain what caused this error in your <thinking> block
  2. Confirm you understand the fix before applying it
  3. Apply ONLY the specific fix shown above
  4. DO NOT use curl, MCP probe tools, or other workarounds

WARNING: Attempting workarounds indicates you did NOT read this hint!
```

**v0.8.0 Enhancement:** Runtime detection of ignored hints. If an agent receives a hint but tries a workaround (e.g., using MCP probe tools instead of fixing the command), the system detects this pattern and shows a critical warning:

```bash
╔═══════════════════════════════════════════════════════════════════╗
║         CRITICAL: YOU IGNORED THE PREVIOUS HINT!                 ║
╚═══════════════════════════════════════════════════════════════════╝

You received a hint about a configuration error, but instead of 
fixing the command, you tried to use MCP probe tools...
```

This creates an **error-driven learning loop**:
1. Agent reads baseline guidance
2. Attempts command → encounters error
3. Receives targeted hint pointing to specific guidance section
4. Applies fix (workarounds are detected and blocked)
5. Succeeds → error automatically filtered from exported flow

**Learning Cost:** $T_{\text{learn}} = \sum_{i=1}^{n} \epsilon_i \cdot (T_{G[\text{sec}_i]} + T_{\text{trial}})$ where $T_{G[\text{sec}_i]} \ll T_G$. 
Expected reduction: ~90% vs re-reading full guidance.

### 3. Anti-Pattern Detection: Real-Time Execution Optimization

mq analyzes command logs and provides optimization suggestions:

```bash
$ mq detect $(mq action-id)

[WARNING] 2 anti-patterns detected

1. [MEDIUM] HTTP requests without error checking
   Suggestion: mq POST /api '{}' -s
               is-error @2 || exit 1

2. [LOW] Sequential requests that could be parallel
   Suggestion: Use mq -p for independent operations
```

The system:
1. Logs commands asynchronously (<10μs overhead)
2. Builds AST from command history
3. Constructs dependency graph (Kahn's algorithm)
4. Matches against 16+ antipattern rules (YAML definitions)
5. Provides specific corrections with impact metrics

Combined, these create a tool that doesn't just execute—it **teaches correct usage and prevents agent mistakes through enforced reflection**.

See: [Embedded Guidance Architecture](images/embedded-guidance-architecture.svg) and [Self-Reflective Feedback](images/self-reflective-feedback-system.svg)

---

## Agents Learn mq Naturally

**No training required.** Agents learn mq through iteration and self-reflection—the same way they learned `curl`, `jq`, `ls`, and `cp`. 

It's just another tool in their environment. Except this one turns their exploration into reusable flows.

**For MCP Server Providers:** Consider distributing common flows with your server. When customers install your MCP server, their agents become immediately productive—no exploration phase, no trial-and-error, no token waste discovering your API patterns. Your customers get instant value, and you control the best practices through distributed flows.

---

## Bootstrap: Getting Started with mq

**Choose your MCP client environment:**

mq works with any MCP-compatible client. The default is Cursor (`~/.cursor/mcp.json`), but you can specify others:

- **Cursor** (default): Uses `~/.cursor/mcp.json`
- **Claude Desktop**: Use `--config=~/Library/Application\ Support/Claude/claude_desktop_config.json`
- **VSCode**: Use `--config=/path/to/your/mcp.json`
- **Custom**: Use `--config=/path/to/config.json`

**Before using mq, read the embedded guidance (it's built into the binary):**

### For AI Agents (Cursor, Claude, etc.)
```bash
# Start with the essential guide (NEW in v0.8.0!)
mq guidance agent essential

# This is the streamlined 700-line guide covering:
# - Core concepts and best practices
# - Common workflows (step-by-step patterns)
# - Error handling protocol (CRITICAL!)
# - Quick reference for 90% of workflows

# For complete reference:
mq guidance agent full  # 1,400+ lines
```

### For Modiqo-Specific Workflows
```bash
# Start with the essential guide (NEW in v0.8.0!)
mq guidance modiqo essential

# This is the comprehensive 800-line protocol guide covering:
# 1. Critical Principles (includes Error Handling Protocol!)
# 2. Discovery Protocol (MANDATORY FIRST STEP)
# 3. Execution Basics (sessions, queries, parallel)
# 4. Export Elicitation (ask before exporting!)
# 5. Quick Reference (command cheat sheet)

# For complete reference:
mq guidance modiqo full  # 2,900+ lines
```

### For Script Creation
```bash
# Read the script creation guide
mq guidance script

# Covers: DSL usage, flow compilation, parameterization
```

**Modular Reading (v0.8.0):** Instead of reading everything upfront, read modules as needed:

```bash
# Essential guides for quick start (RECOMMENDED)
mq guidance modiqo essential  # 800 lines, 95% of workflows
mq guidance agent essential   # 700 lines, core patterns

# Specific modules for advanced topics
mq guidance modiqo atomic-flows    # Building composable flows
mq guidance modiqo query-engine    # Advanced query operations
mq guidance modiqo examples        # Real-world scenarios

# Save for reference
mq guidance modiqo essential > /tmp/mq-essential.txt

# Search for specific topics
mq guidance modiqo | grep -A 10 "Discovery"
```

**Critical:** The guidance is embedded in the binary and contains the error handling protocol. **Agents MUST read the Error Handling Protocol section** to understand how to respond to [HINT] messages correctly.

---

## Quick Start (5 Minutes)

### Installation

**Option 1: Install via curl (Recommended)**

```bash
# Install latest version (v0.8.0+)
curl -fsSL https://github.com/modiqo/mq/releases/latest/download/install.sh | bash

# Install specific version
MQ_VERSION=0.8.0 curl -fsSL https://github.com/modiqo/mq/releases/latest/download/install.sh | bash

# Install to custom directory
MQ_INSTALL_DIR=/usr/local/bin curl -fsSL https://github.com/modiqo/mq/releases/latest/download/install.sh | bash
```

**Option 2: Download binary directly**

Download pre-built binaries from [GitHub Releases](https://github.com/modiqo/mq/releases):

- **Linux x86_64**: `mq-linux-x86_64.tar.gz`
- **Linux x86_64 (musl)**: `mq-linux-x86_64-musl.tar.gz` (static binary)
- **Linux ARM64**: `mq-linux-aarch64.tar.gz`
- **macOS Intel**: `mq-macos-x86_64.tar.gz`
- **macOS Apple Silicon**: `mq-macos-aarch64.tar.gz`
- **Windows x86_64**: `mq-windows-x86_64.zip`

```bash
# Example: Install on Linux
wget https://github.com/modiqo/mq/releases/latest/download/mq-linux-x86_64.tar.gz
tar xzf mq-linux-x86_64.tar.gz
sudo mv mq /usr/local/bin/
```

**Option 3: Build from source**

```bash
# Clone the repository
git clone https://github.com/modiqo/mq.git
cd mq

# Build and install
cargo install --path .
```

### Your First Flow

```bash
# 1. Create a workspace
mq init my-first-flow --seq

# 2. Go to workspace
cd ~/.mq/workspaces/my-first-flow

# 3. Initialize GitHub MCP (shorthand - no JSON!)
mq init-session /github-mcp-mcp
#  @1 9ms → Query with: mq @1 '$'

# 4. List available tools
mq tools /github-mcp-mcp
#  @2 128ms → Query with: mq @2 '$'

# 5. Query the response (instant - from cache!)
mq @2 '$.result.tools[0].name' -r
# github_probe

# 6. View your captured context
mq ls
# Responses:
#   @1 POST 9ms
#   @2 POST 128ms
```

**That's it!** You just captured a reusable MCP flow.

---

## Step-by-Step Guide

### Step 1: Discover Available Workspaces

```bash
# List all workspaces (works from anywhere)
mq ls

# Output:
# Available Workspaces:
#   my-flow (4 responses)
#   demo (2 responses)
```

### Step 2: Create a Workspace

```bash
# Sequential workflow
mq init my-flow --seq

# Parallel workflow  
mq init my-flow --par

# With custom MCP config (for Claude Desktop, VSCode, etc.)
mq init my-flow --seq --config=~/Library/Application\ Support/Claude/claude_desktop_config.json
```

**MCP Config Locations:**
- **Cursor** (default): `~/.cursor/mcp.json`
- **Claude Desktop**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **VSCode**: Custom path (depends on your setup)

The `--config` flag lets you use different MCP configurations per workspace, useful when working with multiple editors.

### Step 3: Enter the Workspace

```bash
cd ~/.mq/workspaces/my-flow
```

### Step 4: Execute MCP Requests

**Option A: Shorthand (Recommended)**
```bash
# Initialize session (no JSON needed!)
mq init-session /github-mcp-mcp

# List tools
mq tools /github-mcp-mcp

# List resources
mq resources /github-mcp-mcp

# Read a resource
mq read /github-mcp-mcp github_refinement_strategies
```

**Option B: Full Control**
```bash
# Custom POST request
mq POST /github-mcp-mcp '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{...}}'

# With session injection
mq POST /github-mcp-mcp '{"method":"tools/list","params":{}}' -s

# With template substitution
mq POST /github-mcp-mcp '{"id":"$my_variable"}' -t -s
```

**Option C: Names Only (For Scripting)**
```bash
# Get clean list of names/URIs (one per line)
mq tools /github-mcp-mcp --names-only
mq resources /github-mcp-mcp --names-only
mq prompts /github-mcp --names-only

# Use in shell scripts:
for tool in $(mq tools /github-mcp-mcp --names-only); do
  echo "Found tool: $tool"
done

# Or capture to array:
TOOLS=($(mq tools /github-mcp-mcp --names-only))
echo "First tool: ${TOOLS[0]}"
```

### Step 5: Query Cached Responses

```bash
# Query a response
mq @1 '$.result.protocolVersion'

# Extract and save to variable
mq @1 '$.result.serverInfo.name' -s server_name -r

# MCP unwrap (extract from .result.content[0].text)
mq @2 '$.tools[0].name' -m -r

# Filter with comparisons
mq @1 '.[] | select(.score > 80 and .active == true)' -r

# Conditionals
mq @1 'if .value > 10 then "big" else "small" end' -r

# Object construction
mq @1 '.items | map({id: .number, name: .title})' -r
```

**Built-in Query Engine:**
mq includes a powerful jq-compatible query engine with NO external dependencies:

- **Comparison operators:** `>`, `>=`, `<`, `<=`, `==`, `!=`
- **Boolean operators:** `and`, `or`, `not`
- **Conditionals:** `if-then-else-end`, `elif`
- **Object construction:** `map({key: .field})`
- **String interpolation:** `"Text: \(.field)"`
- **Base64:** `@base64d`, `@base64` (critical for Gmail!)
- **Array ops:** `first`, `last`, `length`, `unique`, `sort`, `flatten`
- **String ops:** `split`, `join`
- **Composition:** `mq query-stdin` for pure mq pipelines
- **And more:** See [Query Reference](docs/tutorials/query-reference.md)

### Step 6: Analyze Your Workflow

```bash
# View execution plan
mq plan

# Output:
# Execution Plan:
#   Level 0: [@1, @2] (128ms) parallel
#   
# Sequential: 137ms
# Parallel: 128ms  
# Speedup: 1.07x

# View token consumption
mq stats

# Output:
# Total tokens: 1,949
# Average: 487 tokens/request
```

### Step 7: Export Reusable Flow

```bash
# Export as executable shell script (RECOMMENDED)
mq export ~/.mq/flows/github/issues.sh --params owner,repo

# Output:
#  Flow script exported: ~/.mq/flows/github/issues.sh
#   Parameters: 2
#   Format: executable shell script
```

**The exported .sh script is standalone and executable:**

```bash
# Run from anywhere with different parameters
~/.mq/flows/github/issues.sh rust-lang cargo
~/.mq/flows/github/issues.sh facebook react
~/.mq/flows/github/issues.sh golang go

# No workspace needed - creates temporary session
# 2 seconds per execution vs 30 seconds rebuilding
```

---

## Common Flows

### Discovery Flow

```bash
mq init discover --seq
cd ~/.mq/workspaces/discover

# 1. Initialize
mq init-session /github-mcp

# 2. Discover tools
mq tools /github-mcp
mq @2 '$.result.tools' | head -n 20

# Or get just the names for scripting
mq tools /github-mcp --names-only
# github_probe
# github_probe_call

# 3. Discover resources
mq resources /github-mcp
mq @3 '$.result.resources[0].name' -r

# Or get just the URIs
mq resources /github-mcp --names-only
# github_refinement_strategies

# 4. Read documentation
mq read /github-mcp github_refinement_strategies
mq @4 '$.result.contents[0].text' -r | head -n 30
```

### Data Extraction Flow

```bash
mq init extract --seq
cd ~/.mq/workspaces/extract

# 1. Initialize
mq init-session /github-mcp

# 2. Use probe to find tools
mq POST /github-mcp '{"method":"tools/call","params":{"name":"github_probe","arguments":{"query":"list repositories"}}}' -s

# 3. Extract tool name
mq @2 '$.result.content[0].text' -m | head -n 5

# 4. Save to variable for next request
mq @2 -m '$.tools[0].name' -s tool_name -r

# 5. Use in template
mq POST /github-mcp '{"method":"tools/call","params":{"name":"$tool_name","arguments":{...}}}' -t -s
```

### Parallel Multi-Endpoint

```bash
mq init multi --par
cd ~/.mq/workspaces/multi

# Execute multiple requests in parallel
mq -p \
  POST /gmail-mcp '{"method":"initialize",...}' \
  POST /github-mcp '{"method":"initialize",...}'

# Output:
#  @1 116ms
#  @2 19ms
# Total: 117ms (concurrent!)

# Each has its own session
mq @1 '$.response.headers.mcp-session-id'
mq @2 '$.response.headers.mcp-session-id'
```

### Parameterized Flow Reification (v0.2.0)

```bash
mq init github-capture --seq
cd ~/.mq/workspaces/github-capture

# 1. Set variables for parameterization
mq set owner=modiqo
mq set repo=mq

# 2. Initialize and capture with variables
mq init-session /github-mcp

mq POST /github-mcp '{
  "method":"tools/call",
  "params":{
    "name":"github_search_issues",
    "arguments":{
      "owner":"$owner",
      "repo":"$repo"
    }
  }
}' -t -s

# 3. Export as executable script
mq export ~/.mq/flows/github/fetch-issues.sh --params owner,repo

# 4. Reuse with different parameters
~/.mq/flows/github/fetch-issues.sh rust-lang cargo
~/.mq/flows/github/fetch-issues.sh facebook react

# Each execution: 2 seconds vs 30 seconds to rebuild
# Token savings: 99% (50 tokens vs 5,000 tokens)
```

### Composable Flow

```bash
# Build atomic flows first
mq export ~/.mq/flows/github/list-issues.sh --params owner,repo --atomic
mq export ~/.mq/flows/gmail/create-draft.sh --params subject --atomic

# Export composition wrapper (uses ONLY mq, no jq!)
mq export-composition ~/.mq/flows/composite/github-to-draft.sh \
  ~/.mq/flows/github/list-issues.sh \
  ~/.mq/flows/gmail/create-draft.sh \
  --params owner,repo \
  --transform '.[] | "- #\(.number): \(.title)"' \
  --transform 'join("\n")' \
  --description "Creates Gmail draft from GitHub issues"

# Run the composition
~/.mq/flows/composite/github-to-draft.sh conikeec mcpr

# Features:
# - String interpolation: "Text: \(.field)" syntax supported!
# - mq query-stdin: Transform JSON in pipes (no jq needed!)
# - Pure mq: Zero external dependencies
```

### Scripting with Names Only (v0.4.0)

```bash
mq init discover-tools --seq
cd ~/.mq/workspaces/discover-tools

# Initialize session
mq init-session /github-mcp

# Get clean list of tool names (one per line)
mq tools /github-mcp --names-only
# Output:
# github_probe
# github_probe_call

# Use in shell scripts:
for tool in $(mq tools /github-mcp --names-only); do
  echo "Discovered tool: $tool"
  # Use the tool name...
done

# Check if specific tool exists:
if mq tools /github-mcp --names-only | grep -q "github_probe"; then
  echo "Probe tool available"
fi

# Same for resources and prompts:
mq resources /github-mcp --names-only   # List resource URIs
mq prompts /github --names-only     # List prompt names

# Build dynamic workflows:
FIRST_TOOL=$(mq tools /github-mcp --names-only | head -1)
mq POST /github-mcp "{\"method\":\"tools/call\",\"params\":{\"name\":\"$FIRST_TOOL\"}}" -s
```

**Read [docs/design_considerations/flows.md](docs/design_considerations/flows.md) for complete flow export documentation.**

---

## Key Concepts

### Response Caching

**Execute HTTP once, query many times:**

```bash
# Execute (makes HTTP call)
mq tools /github-mcp
#  @1 128ms

# Query (instant from cache)
mq @1 '$.result.tools[0].name' -r      # <1ms
mq @1 '$.result.tools[1].name' -r      # <1ms
mq @1 '$.result.protocolVersion' -r    # <1ms

# Result: 1 HTTP call, 3 queries = ~130ms
# vs curl+jq: 3 HTTP calls = ~360ms
# Speedup: 64% faster
```

### Auto-Numbering

```bash
mq init-session /github-mcp   # Saved as @1
mq tools /github-mcp          # Saved as @2
mq resources /github-mcp      # Saved as @3

# Special references:
# @1, @2, @3 - specific responses
# @0 - latest response (not implemented yet)
```

### Template Variables

```bash
# Extract and save
mq @1 '$.result.protocolVersion' -s protocol -r

# Use in next request
mq POST /github-mcp '{"version":"$protocol"}' -t

# Inline query
mq POST /github-mcp '{"session":"@1{$.response.headers.mcp-session-id}"}' -t
```

### Per-Endpoint Sessions

```bash
mq init-session /gmail-mcp    # session: virtual-gmail-xxx
mq init-session /github-mcp   # session: virtual-github-yyy

# Each endpoint maintains independent session
# No cross-endpoint contamination
```

---

## Configuration

**Single Source of Truth:** `~/.cursor/mcp.json`

All configuration comes from Cursor's MCP config:
- Endpoint URLs
- Authentication (Bearer tokens or API keys)
- Auto-refresh on each request

**No config files needed!**

Example `~/.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "github-mcp": {
      "type": "http",
      "url": "http://127.0.0.1:3000/mcp/github",
      "headers": {
        "Authorization": "Bearer ..."
      }
    },
    "parallel-task-mcp": {
      "type": "http",
      "url": "https://task-mcp.parallel.ai/mcp",
      "headers": {
        "x-api-key": "your-api-key-here"
      }
    }
  }
}
```

**Endpoint Naming (v0.5.0+):**
- Endpoints derived from **server key names** (not URL paths)
- Names are normalized: lowercase + spaces → underscores
- Examples:
  - `gmail-mcp` → `/gmail-mcp`
  - `Parallel Task MCP` → `/parallel_task_mcp`
  - `My Custom Server` → `/my_custom_server`

**Authentication Support:**
- `Authorization: Bearer <token>` - OAuth/JWT tokens
- `x-api-key: <key>` - API key authentication

---

## Command Reference

### Workspace Management
```bash
mq init <name> --seq|--par           # Create workspace
mq init <name> --seq --config=PATH   # Create with custom MCP config
mq ls                                # List workspaces (grouped by date) OR responses
mq ls --flat                         # List workspaces alphabetically (ungrouped)
mq clean --empty                     # Delete empty workspaces
mq clean --except-today              # Delete all except today's workspaces
mq clean --older-than=7d             # Delete workspaces older than 7 days
mq clean --all -i                    # Delete all workspaces (with confirmation)
mq clear @<N>                        # Clear specific response
mq clear -a                          # Clear all responses
```

**Custom MCP Config Examples:**
```bash
# Cursor (default)
mq init cursor-flow --seq

# Claude Desktop
mq init claude-flow --seq --config=~/Library/Application\ Support/Claude/claude_desktop_config.json

# Custom path
mq init custom-flow --seq --config=/path/to/your/mcp.json
```

### Help
```bash
mq help                      # Show all commands
mq help <command>            # Show command-specific help
mq <command> --help          # Show command-specific help
```

### HTTP Execution
```bash
mq POST <endpoint> <body>    # Execute request
  -s, --session              # Auto-inject session
  -t, --template             # Enable $var/@1{.path} substitution
  --id-only                  # Output only response ID (for scripting)

mq -p POST /gmail-mcp '{...}' -t -s POST /github-mcp '{...}' -t -s  # Parallel execution
```

### Query & Extract
```bash
mq @<N> <query>              # Query response
  -m, --mcp                  # Unwrap MCP structure
  -r, --raw                  # Raw output (no JSON)
  -s <var>, --save <var>     # Save to variable
```

### MCP Shorthand
```bash
mq init-session <endpoint>              # initialize
  --id-only                             # output only response ID
mq tools <endpoint>                     # tools/list
  --id-only                             # output only response ID
  --names-only                          # list tool names only (one per line)
mq resources <endpoint>                 # resources/list
  --id-only                             # output only response ID
  --names-only                          # list resource URIs only (one per line)
mq prompts <endpoint>                   # prompts/list
  --id-only                             # output only response ID
  --names-only                          # list prompt names only (one per line)
mq read <endpoint> <uri>                # resources/read
  --id-only                             # output only response ID
mq prompt <endpoint> <name> [k=v...]    # prompts/get
  --id-only                             # output only response ID
```

### Analysis & Export
```bash
mq plan                                    # Show DAG execution plan
mq stats                                   # Token consumption metrics
mq export <file.sh> --params <vars>       # Export as executable shell script (RECOMMENDED)
mq export <file.json>                     # Export as JSON (documentation only)
mq action-id                               # Get current workspace's action ID
```

---

## Control Flow Commands (Phases 1-11)

### Phase 1: Essential Conditions
**Error Handling & Validation**

```bash
# Check if response has error
is-error @N
# Exit 0 if error detected, 1 if no error

# Example:
mq POST /github-mcp '{"owner":"invalid"}' -s
is-error @2 && {
  echo "Error: $(mq @2 '$.error.message' -r)"
  exit 1
}

# Check if field exists
exists @N 'query'
# Exit 0 if field exists, 1 if missing

# Example:
exists @1 '$.result.tools' && echo "Tools available"

# Check if session exists
has-session /endpoint
# Exit 0 if session exists, 1 if missing

# Example:
has-session /github-mcp || mq init-session /github-mcp
```

### Phase 2: OAuth Token Validation
**Authentication Confidence**

```bash
# Validate OAuth token (JWT or opaque)
token-valid /endpoint
# Exit 0 if valid, 1 if invalid/expired

# Example: Validate before workflow
token-valid /github-mcp || {
  echo "Token invalid - please refresh"
  exit 1
}
mq init-session /github-mcp  # Proceed with confidence

# Display token information
token-info /endpoint

# Example output:
# Token: eyJh***CVA
# Type: JWT (Non-Opaque)
# Issuer: https://auth0.example.com/
# User: user@example.com
# Scopes: openid, profile
# Expires: 2025-10-17T01:33:54+00:00
# Status: Valid (12 hours remaining)
```

### Phase 3: Comparison & Validation
**Data Validation**

```bash
# Check if result is empty
is-empty @N 'query'
# Exit 0 if empty, 1 if not empty

# Example:
is-empty @2 '$.items' && {
  echo "No items found"
  exit 0
}

# Universal comparison operator
compare @N 'query' OPERATOR value
# Operators: -eq, -ne, -gt, -ge, -lt, -le, -match, -contains
# Exit 0 if true, 1 if false

# Examples:
compare @1 '$.count' -gt 10 && echo "More than 10 items"
compare @1 '$.status' -eq "active" && proceed
compare @1 '$.email' -match ".*@gmail\.com$" && notify
compare @1 '$.message' -contains "error" && alert

# Check if variable exists
has-var VAR_NAME
# Exit 0 if exists, 1 if missing

# Example:
has-var user_id || {
  mq @1 '$.user.id' -s user_id -r
}
mq POST /api '{"user_id":"$user_id"}' -t -s
```

### Phase 4: Array Iteration & Display
**Loop Elimination with Parallel Support**

```bash
# Iterate over array elements
for @N 'ARRAY_QUERY' [--parallel] POST /endpoint 'BODY' [-t] [-s]

# Sequential example:
for @2 '$.items[]' POST /api '{"id":"$id"}' -s

# Parallel example (4x faster):
for @2 '$.items[]' --parallel POST /api '{"id":"$id"}' -s

# Variable flattening:
# {"user": {"id": 123, "login": "alice"}} becomes:
#   $user_id = "123"
#   $user_login = "alice"

# Real-world example:
mq POST /github-mcp '{"owner":"user","repo":"project","per_page":10}' -s
for @2 '$.items[]' --parallel \
  POST /github-mcp '{"issue_number":"$number"}' -s
# Fetches all 10 issues simultaneously

# Display multiple responses with field extraction
display @N..@M [--base PATH] --field name=path [--field name=path...]

# Example: Display range of responses
display @5..@10 \
  --base '$.result.content[0].text | @json' \
  --field subject='.payload.headers | .[] | select(.name == "Subject") | .value' \
  --field from='.payload.headers | .[] | select(.name == "From") | .value' \
  --field date='.payload.headers | .[] | select(.name == "Date") | .value'

# Features:
# - Range notation: @5..@7 or individual @5 @6 @7
# - --base flag: Common path prefix (DRY principle)
# - --field flag: Repeatable field extraction
# - Auto error handling: Skips failed/missing responses
# - Automatic fallbacks: "(no subject)" if field missing
# - Replaces 24+ lines of bash with single command
```

### Phase 5: Advanced Conditions
**Change Detection & Batch Validation**

```bash
# Detect changes between responses
changed @OLD @NEW 'query'
# Exit 0 if changed, 1 if same

# Example: Polling
mq POST /api '{"resource":"status"}' -s  # @1
sleep 30
mq POST /api '{"resource":"status"}' -s  # @2
changed @1 @2 '$.count' && notify-team

# Check if all responses succeeded
all-success @N..@M
all-success @3 @4 @5

# Example:
mq -p POST /a '{}' -s POST /b '{}' -s POST /c '{}' -s
all-success @3..@5 || {
  echo "At least one failed"
  rollback
}

# Check if any response has error
any-error @N..@M

# Example:
any-error @3..@5 && {
  for i in 3 4 5; do
    is-error @$i && echo "@$i failed"
  done
}
```

### Phase 6: Type Validation
**Schema & Type Safety**

```bash
# Check if field matches type
is-type @N 'query' TYPE
# Types: string, number, boolean, array, object, null

# Example:
is-type @1 '$.count' number || {
  echo "Expected number, got $(mq @1 '$.count | type' -r)"
  exit 1
}

# Check multiple required fields
expect @N 'path1' 'path2' 'path3'

# Example:
expect @1 '$.data.user' '$.data.email' '$.metadata' || {
  echo "Response missing required fields"
  exit 1
}
```

### Phase 7: Data Operations
**Response Comparison & Aggregation**

```bash
# Compare two responses
diff @OLD @NEW ['query']

# Example:
mq POST /api '{"resource":"issues"}' -s  # @1
sleep 60
mq POST /api '{"resource":"issues"}' -s  # @2
diff @1 @2 '$.items'
# Output:
#   Added: 3 items
#   Changed: 1 item  
#   Removed: 0 items

# Aggregate data from multiple sources
aggregate --from @N 'query' --as VAR_NAME ...

# Example:
aggregate \
  --from @2 '$.messages | length' --as email_count \
  --from @4 '$.issues | length' --as issue_count \
  --from @6 '$.pull_requests | length' --as pr_count
# Output: {"email_count": 5, "issue_count": 12, "pr_count": 3}
```

### Phase 8-11: Infrastructure Features
**Resilience, Pagination, Snapshots, Monitoring**

```bash
# Retry infrastructure (in execution module)
# - BackoffStrategy: Fixed, Linear, Exponential
# - Used internally for resilient operations

# Pagination infrastructure (in execution module)
# - PaginationConfig: continue condition, next page extraction
# - Supports automatic pagination for paginated APIs

# Workspace snapshots
mq snapshot save NAME        # Save workspace state
mq snapshot restore NAME     # Restore from snapshot
mq snapshot list             # List snapshots
mq snapshot delete NAME      # Delete snapshot

# Example:
mq snapshot save before-risky-operation
# ... do risky operations ...
mq snapshot restore before-risky-operation  # Rollback if needed

# Rate limit & time checking (infrastructure)
# - RateLimitTracker: track requests per endpoint
# - ElapsedChecker: check time since response
# - Duration parsing: 30s, 5m, 1h
```

### Anti-Pattern Detection & Flow Validation
**Self-Correcting Flows**

```bash
# Get current flow's action ID
mq action-id
# Output: my-flow_1760658133

# Detect anti-patterns in your flow
mq detect <ACTION_ID>

# Example:
ACTION_ID=$(mq action-id)
mq detect "$ACTION_ID"

# Output shows detected issues:
# [WARNING] 1 anti-patterns detected
#
# 1 [MEDIUM] HTTP requests without error checking
#   Suggestion:
#     mq POST /api '{}' -s
#     is-error @2 || { echo "Request failed"; exit 1; }

# Automatic inline hints (every 5 commands)
# mq automatically analyzes your flow and provides hints as you work:
# [HINT] HTTP requests without error checking
# [HINT] Consider: is-error @N || exit 1

# What gets detected:
# - Missing error checks (is-error)
# - Missing session validation (has-session)
# - Sequential requests that could be parallel
# - Manual loops instead of for
# - Using curl/jq instead of native mq
# - And 10+ other patterns

# Smart detection for modern patterns:
# ✓ Recognizes for + any-error as valid
# ✓ Understands batch validation patterns
# ✓ No false positives for proper error handling
```

---

## DSL Quick Start (WIP!)

**Write flows in declarative DSL, not bash:**

```mq
# @mq-dsl-v1
flow github_demo {
  params {
    owner = string
    repo = string
  }
  
  github {
    session = init()
    issues = call("github_probe_call", {
      name = "github_issues_list-for-repo"
      arguments = {
        owner = params.owner
        repo = params.repo
      }
    })
    
    let items = issues.result.content[0].text | @json
    
    for issue in items {
      display {
        number = issue.number as string
        title = issue.title as string
        state = issue.state as string
      }
    }
  }
  
  output {
    total = github.items | length
  }
}
```

**Run:**
```bash
mq run github-demo.mq modiqo mq
# Compiles DSL → bash, executes, shows all issues
```

**Or compile once, run many:**
```bash
mq compile github-demo.mq  # → github-demo.sh
./github-demo.sh owner repo
```

**See:** [examples/](examples/) for complete DSL examples

---

## Learn More

### Getting Started
- **[Quickstart](docs/tutorials/quickstart.md)** - 5-minute introduction
- **[Motivation](docs/design_considerations/motivation.md)** - Why mq exists and the token economics problem
- **[Sequential Tutorial](docs/tutorials/tutorial-sequential.md)** - Step-by-step sequential flow
- **[Parallel Tutorial](docs/tutorials/tutorial-parallel.md)** - Multi-endpoint parallel flow

### Feature Guides
- **[Flow Export & Reusability](docs/design_considerations/flows.md)** - Parameterized flows and flow catalog
- **[Query Reference](docs/tutorials/query-reference.md)** - Complete query language documentation
- **[MCP Protocol Reference](docs/tutorials/mcp-protocol-reference.md)** - All MCP methods
- **[DAG Algorithm](docs/algorithm/dag-algorithm.md)** - Kahn's topological sort and parallel execution

### Advanced
- **[Agent Steering Guide](docs/steering/modiqo-agent-steering.md)** - How agents should use mq
- **[Agent Checkpoint Pattern](docs/design_considerations/agent-checkpoint-pattern.md)** - Agent-in-the-loop flows
- **[Composite Flow Example](docs/tutorials/example-composite-flow.md)** - GitHub to Gmail integration
- **[Workspace Bootstrap](docs/design_considerations/workspace-bootstrap.md)** - Advanced workspace features

---

## Security

- **Zero tokens on disk** - Only in ~/.cursor/mcp.json
- **Token obfuscation** - Saved as `Bearer ya29***206`
- **Fresh tokens** - Read from mcp.json every request
- **Per-endpoint isolation** - Gmail and GitHub sessions separate
- **No environment variables needed** - Single source of truth

---

## What's New in v0.8.0: Agent Hint Steering System

The v0.8.0 release introduces a comprehensive error-driven learning system that fundamentally changes how agents interact with mq:

### Runtime Detection of Ignored Hints

The system now tracks when hints are shown and detects if agents attempt workarounds instead of applying fixes:

- **Pattern Detection**: Identifies when agents use MCP probe tools, curl, or other workarounds after receiving specific error hints
- **Critical Warnings**: Shows prominent "CRITICAL: YOU IGNORED THE PREVIOUS HINT!" message
- **5-Minute Window**: Hints expire after 5 minutes to prevent false positives
- **Workspace-Level Tracking**: Hints are tracked per workspace in non-persisted state

### Visual STOP Directives

Error hints now include prominent visual barriers to force agent attention:

```
╔═══════════════════════════════════════════════════════════════════╗
║                        STOP: ERROR DETECTED                       ║
║            DO NOT PROCEED WITHOUT ADDRESSING THIS ERROR           ║
╚═══════════════════════════════════════════════════════════════════╝
```

### Agent-Specific Reflection Prompts

Every error hint includes a dedicated "FOR AI AGENTS" section with mandatory steps:
1. Explain the error in `<thinking>` block
2. Confirm understanding before applying fix
3. Apply ONLY the suggested fix
4. DO NOT attempt workarounds

### Enhanced Guidance with Error Handling Protocol

Both essential guides now include comprehensive "Error Handling Protocol" sections:

- **Mandatory behavior** when seeing [HINT] messages
- **Forbidden behaviors** (using probe tools, removing flags without understanding, etc.)
- **Correct vs incorrect** error response patterns with examples
- **Why it matters**: Explanation of consequences

### Detected Workaround Patterns

The system detects three primary workaround patterns:
- **ConfigError → MCP Probe Tools**: Agent uses `gmail_probe` instead of fixing config
- **SessionMissing → No -s Flag**: Agent's next command still missing `-s`
- **JsonRpcParseError → Probe/Curl**: Agent tries probe tools or curl instead of fixing JSON-RPC

**Impact**: Significantly reduces wasted API calls and improves agent learning efficiency by preventing agents from bypassing error corrections.

### Adaptive Forgetting: Flow Metrics and Environmental Drift Detection

mq now tracks flow invocations automatically, modeling procedural memory with adaptive forgetting:

**Automatic Tracking:**
Every exported flow includes invisible metrics tracking. No user action needed:

```bash
# Export flow (metrics tracking auto-injected)
mq export ~/.mq/flows/gmail/fetch.sh --params count

# Run the flow (metrics recorded automatically)
~/.mq/flows/gmail/fetch.sh 5
~/.mq/flows/gmail/fetch.sh 10
~/.mq/flows/gmail/fetch.sh 20
```

**View Flow Health:**
```bash
# Basic stats
mq flow stats ~/.mq/flows/gmail/fetch.sh

# Output:
Flow Invocation Metrics

  Flow: ~/.mq/flows/gmail/fetch.sh
  Created: 2025-10-23 13:09:54
  Last invoked: 2025-10-23 13:10:29

  Invocation Summary:
    Total: 119
    Successful: 86
    Failed: 33

  Success Rates:
    Historical: 72.3%
    Recent (last 20): 25.0%

  Performance:
    Avg execution time: 607ms
```

**Environmental Drift Detection:**

When APIs evolve and flows start failing, mq detects the pattern automatically:

```bash
mq flow stats ~/.mq/flows/gmail/fetch.sh

# Output includes:
  WARNING: Environmental Drift Detected!
    Historical success: 72%
    Recent success: 10%
    Likely cause: API schema likely changed
    Recommendation: Re-record this action sequence
```

**Error Evidence Review:**
```bash
# View recent error details
mq flow stats ~/.mq/flows/gmail/fetch.sh --show-errors

# Shows:
  Recent Errors:
    [2025-10-23 13:10] SchemaMismatch
       Field 'maxResults' not found in request
    
    [2025-10-23 13:10] SchemaMismatch
       Field 'maxResults' not found in request
```

**Storage Model (DNA + Epigenetics):**
```
~/.mq/flows/gmail/
  fetch.sh          # Immutable code (DNA sequence)
  fetch.sh.metrics  # Mutable tracking (~480 bytes)
  fetch.sh.stderr   # Error evidence (~4KB max)
```

**How It Works:**
1. **Recording Phase:** Agent learns through trial-and-error, errors filtered on export
2. **Automaticity Phase:** Exported flow executes repeatedly, metrics tracked
3. **Drift Detection:** Error rate spike (e.g., 90% → 20%) signals API changed
4. **Adaptive Forgetting:** Stale flows identified for re-recording or removal

**Garbage Collection (Future):**
```bash
# Analyze which flows need attention
mq gc --analyze

# Remove flows with high error rates (environmental drift)
mq gc --error-prone

# Remove flows not used recently*
mq gc --unused-for=60d

# Keep best performers when duplicates exist
mq gc --keep-best-performing
```

**\* Note on Usage-Based Decay:** The `--unused-for` mechanism contradicts procedural memory research. Human procedural memories (like riding a bike) persist indefinitely without rehearsal—they don't decay with disuse. This command is retained only for **manual disk space management**, not automatic forgetting. Flows should only be forgotten when: (1) they fail due to environmental drift (API changed), or (2) user explicitly removes them. Time-based removal violates the procedural memory model and may be removed in future versions.

**Impact:** Transforms procedural memory model into working system—flows that work repeatedly are retained, flows that stop working trigger re-learning.

---

## Features

### Core Flow Development
- **Response caching** - Execute once, query unlimited (62% faster than curl+jq)
- **Template substitution** - Clean data flow with `$var` and `@1{.path}` syntax
- **Flow reification** - Convert exploration to parameterized shell scripts (standalone executables)
- **Flow composition** - `mq export-composition` auto-generates composition wrappers (NEW!)
- **Flow catalog** - Organize reusable .sh flows at `~/.mq/flows/{endpoint}/`
- **Per-endpoint sessions** - Automatic session management per MCP endpoint
- **Parallel execution** - Multi-request concurrency with `-p` flag (now with -t and -s support!)
- **DAG analysis** - Automatic dependency detection and optimization
- **Token tracking** - Measure API data exchange and optimize costs
- **MCP shorthand** - Simplified commands (no JSON for common operations)
- **Smart workspace discovery** - Grouped by date, bulk cleanup with filters
- **Comprehensive query engine** - jq-compatible with comparisons, conditionals, string interpolation (NEW!)
- **Query from stdin** - `mq query-stdin` for pure mq pipelines (NEW!)
- **Zero external dependencies** - Single binary, no curl/jq/base64 needed

### Control Flow (Phases 1-11)
- **Error handling** - `is-error`, `exists`, `has-session` for defensive flows
- **OAuth validation** - `token-valid`, `token-info` for JWT and opaque tokens
- **Comparison operators** - `compare` with 8 operators (-eq, -gt, -match, -contains)
- **Empty checking** - `is-empty` for validating results
- **Variable validation** - `has-var` for template variable safety
- **Array iteration** - `for` with sequential and parallel modes (4x speedup)
- **Batch display** - `display` with field extraction and range notation (eliminates display loops)
- **Change detection** - `changed` for polling and monitoring
- **Batch operations** - `all-success`, `any-error` for parallel flow validation
- **Type validation** - `is-type`, `expect` for schema checking
- **Data operations** - `diff`, `aggregate` for multi-response analysis
- **Flow info** - `mq action-id` for anti-pattern detection integration
- **Retry infrastructure** - BackoffStrategy (Fixed, Linear, Exponential)
- **Pagination support** - PaginationConfig for auto-pagination
- **Snapshot management** - Save/restore workspace state for safe experimentation
- **Monitoring** - Rate limit tracking, elapsed time checking

**Total:** 20+ commands for building robust, production-ready agent flows

### Error-Driven Learning (NEW in v0.8.0)
- **Visual STOP directives** - Prominent red borders force agent attention
- **Agent-specific prompts** - Mandatory reflection steps in [HINT] messages
- **Runtime hint detection** - Tracks hints and detects ignored patterns
- **Workaround blocking** - Identifies and warns about MCP probe tool workarounds
- **5-minute expiration** - Hints expire to prevent false positives
- **Workspace tracking** - Non-persisted hint state per workspace
- **Error filtering** - Automatic exclusion of failed attempts from exports
- **Targeted guidance** - Hints point to specific sections of embedded documentation
- **Learning cost reduction** - ~90% reduction vs re-reading full guidance

**Impact:** Transforms declarative knowledge into procedural memory through enforced reflection

---

## Performance Characteristics

**Measured optimizations from real flows:**

```
Response Caching (Query Iteration):
  Without cache: 360ms (re-execute HTTP 3 times for query mistakes)
  With cache: 138ms (1 HTTP + 3 instant cache queries)
  Optimization: 62% faster iteration

Parallel Execution (Independent Requests):
  Sequential: 135ms (requests execute one after another)
  Parallel: 117ms (requests execute concurrently)
  Optimization: 13% reduction in wall-clock time

Development Velocity (Context Replay):
  Agent rebuild: 30 seconds + 12,000 tokens (re-discover everything)
  Cached replay: 2 seconds + 250 tokens (execute from reified flow)
  Optimization: 93% faster, 98% fewer tokens

Note: HTTP execution speed is identical to curl/reqwest. Gains come from
eliminating rediscovery overhead, not faster HTTP.
```

---

## Requirements

- Rust 1.85+ (edition 2024)
- Cursor with MCP configured (~/.cursor/mcp.json)
- MCP servers running (e.g., http://127.0.0.1:3000/mcp/*)

---

## Technical Stack

**Pure Rust - Zero External Binaries:**
- reqwest - HTTP client (not curl)
- serde_json_path - JSON queries (not jq)
- tokio - Async runtime
- petgraph - DAG algorithms
- tiktoken-rs - Token counting

**Single 6.9MB binary** - works on any platform

---

## Contributing

This project follows Rust best practices (see ~/tulving/rust.md):
- Zero unsafe code
- Comprehensive tests (497 passing)
- Clean compilation (zero warnings)
- Small modules (all <250 lines)
- Config structs (no multi-arg functions)
- Expert Rust patterns throughout

---

## License

MIT License - Copyright (c) 2025 Chetan Conikee

---

## What is mq?

**mq is an interactive context development environment for MCP.**

It captures your exploration and translates it into deterministic, reusable flows that can be invoked by natural language without mistakes or retries.

**Traditional Approach:**
```
Agent: curl MCP → parse with jq → store in context (costs tokens)
Agent: curl MCP → parse with jq → store in context (costs tokens)
Agent: curl MCP → parse with jq → store in context (costs tokens)
Result: Stochastic execution, high token cost, no reusability
```

**With mq:**
```
You: Execute once → Query cached → Template next → Optimize → Reify
Result: Deterministic flows, 97% fewer tokens, instant iteration
```

It enables:
- **Interactive Development:** Capture context as you explore
- **Response Caching:** Execute HTTP once, query unlimited times
- **Template Variables:** Clean data flow with zero context pollution
- **Parallel Optimization:** Automatic DAG-based execution planning
- **Flow Reification:** Export deterministic flows for production
- **Token Economics:** Measure and minimize agent overhead

**Context engineering as code.** You just don't have to write it.

**Read [docs/design_considerations/motivation.md](docs/design_considerations/motivation.md) to understand why this matters.**

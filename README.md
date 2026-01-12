# dex - Execution Context Engineering

> **A substrate between agents and APIs**

Deterministic agent-tool orchestration through embedded guidance and self-reflective languages.

---

## What is dex?

dex sits **between your AI agent and APIs**, transforming exploration into reusable, deterministic workflows with 90%+ token savings on repeat tasks.

```
┌─────────────────────────────────┐
│ AI Agent (Cursor, Claude, etc.) │
└────────────┬────────────────────┘
             │ natural language
             ▼
┌─────────────────────────────────────────────┐
│ dex (learning substrate)                     │
│  • Records action sequences                 │
│  • Provides real-time correction hints      │
│  • Stores successful sequences for replay   │
│  • Caches responses for instant re-query    │
└────────────┬────────────────────────────────┘
             │ structured API calls
             ▼
┌─────────────────────────────────┐
│ APIs (GitHub, Gmail, Stripe...) │
└─────────────────────────────────┘
```

**Key Insight:** First exploration takes 30 seconds and 8,400 tokens. Subsequent runs take 2 seconds and 250 tokens.

---

## Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/modiqo/dex-releases/main/install.sh | bash
```

### Platform-Specific

<details>
<summary><b>macOS (Apple Silicon)</b></summary>

```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/latest/dex-macos-aarch64.tar.gz | tar xz
sudo mv dex /usr/local/bin/
dex --version
```
</details>

<details>
<summary><b>macOS (Intel)</b></summary>

```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/latest/dex-macos-x86_64.tar.gz | tar xz
sudo mv dex /usr/local/bin/
dex --version
```
</details>

<details>
<summary><b>Linux (x86_64)</b></summary>

```bash
curl -L https://github.com/modiqo/dex-releases/raw/main/releases/latest/dex-linux-x86_64.tar.gz | tar xz
sudo mv dex /usr/local/bin/
dex --version
```
</details>

---

## Getting Started

### Private Beta Access

dex is currently in private beta. You'll need an invite code to register.

```bash
# 1. Join with your invite code
dex join abc123-def456-ghi789

# 2. Register with OAuth
dex register --provider google

# 3. Install powerpack (adapters and skills)
dex pull powerpack --yes --with-skills
```

**Don't have an invite?** Email us: **ask@modiqo.ai**

### Your First Workflow

```bash
# Start interactive onboarding
dex how

# Initialize a workspace
dex init my-first-workflow --seq

# Make an API call (example with GitHub adapter)
dex POST adapter/github-api '{
  "method": "tools/call",
  "params": {
    "name": "github_api_probe",
    "arguments": {"query": "list repositories", "limit": 5}
  }
}' -s

# Query the cached response
dex @1 '.result.tools[].name' -r

# Export as reusable flow
dex export ~/.dex/flows/github/my-workflow.sh
```

---

## Core Capabilities

### 1. MCP Workflow Automation

Execute sequences of MCP calls with state management:

```bash
# Initialize session
dex init-session /github

# Make calls with session state
dex POST /github '{"method":"tools/call",...}' -s

# Query responses without re-executing
dex @1 '.result.data' -r
dex @1 '.result.items | length' -r
dex @1 '.result.items[] | select(.active)' -r
```

**Result:** <100 microseconds per query vs 500ms for HTTP re-execution.

### 2. Adapter Framework: Any REST API → MCP

Transform any REST API into searchable MCP capabilities:

```bash
# Create adapter from OpenAPI spec
dex adapter new github-api https://api.github.com/openapi.json --yes

# Now you have 2 virtual MCP tools:
# 1. github_api_probe - Search 1,111 operations semantically
# 2. github_api_call - Execute discovered operations

# Search for capability
dex POST adapter/github-api '{
  "method": "tools/call",
  "params": {
    "name": "github_api_probe",
    "arguments": {"query": "create repository", "limit": 5}
  }
}' -s

# Execute discovered tool
dex POST adapter/github-api '{
  "method": "tools/call",
  "params": {
    "name": "github_api_call",
    "arguments": {
      "tool_name": "repos/create",
      "arguments": {"name": "my-project", "owner": "myorg"}
    }
  }
}' -s
```

**Supported:** OpenAPI 3.x, Google Discovery, GraphQL SDL, gRPC

**Value:** No custom MCP server needed. Any API becomes MCP-compatible in seconds.

### 3. Skills: Reusable Workflows

Skills are parameterized workflows that can depend on adapters:

```bash
# Pull a skill from registry
dex registry skill pull github-issue-creator

# Skill declares dependencies:
# - Requires: github_api adapter (fingerprint: mcp_abc123...)
# - Auto-installs missing dependencies

# Run the skill
~/.dex/skills/github-issue-creator.sh "Bug in login" "Steps to reproduce..."

# Skills compose:
# - Skill A uses Adapter X
# - Skill B uses Adapter Y + Skill A
# - Exponential value through composition
```

**Power:** Skills + Adapters = Compounding Value

### 4. Flow Export: Exploration → Automation

Convert successful explorations into reusable scripts:

```bash
# After exploring a workflow
dex export ~/.dex/flows/my-workflow.sh \
  --params owner,repo,state \
  --description "Fetch GitHub issues" \
  --composable

# Reuse instantly
~/.dex/flows/my-workflow.sh facebook react open

# Fork with new parameters (~3 seconds vs 30s from scratch)
dex flow fork ~/.dex/flows/my-workflow.sh \
  --as my-variant \
  --params owner=google,repo=chrome \
  --replay
```

**Result:** 95%+ token savings on repeat tasks.

### 5. Browser Automation

Automate web interactions via Playwright:

```bash
# Navigate and snapshot (CRITICAL: snapshot first!)
dex browse --headed https://example.com

# Query efficiently (95-99% token savings)
dex browser-extract @1 button
dex browser-find @1 --text "search"

# Interact using discovered refs
dex browse click <ref>

# Export workflow
dex export ~/.dex/flows/web/my-automation.sh
```

**Pattern:** Navigate → Snapshot → Understand → Interact

---

## The Power of Composition

### Adapters + Skills = Exponential Value

**Level 1: Adapters**
- GitHub API → `github_api` adapter
- Stripe API → `stripe_api` adapter
- Twilio API → `twilio_api` adapter

**Level 2: Skills (Using Adapters)**
- `github-issue-creator` (uses github_api)
- `payment-processor` (uses stripe_api)
- `sms-notifier` (uses twilio_api)

**Level 3: Composite Skills (Using Skills + Adapters)**
- `bug-to-payment` (uses github-issue-creator + payment-processor)
- `deploy-and-notify` (uses multiple skills + adapters)

**Result:** Each layer multiplies value. 3 adapters × 10 skills = 30 capabilities. Add 5 composite skills = 150+ workflows.

### Real Example

```bash
# Install GitHub adapter
dex adapter new github-api https://api.github.com/openapi.json --yes

# Install skill that uses it
dex registry skill pull github-issue-creator

# Skill automatically:
# 1. Checks for github_api adapter (by fingerprint)
# 2. Installs if missing
# 3. Runs workflow using adapter

# Now you can:
~/.dex/skills/github-issue-creator.sh "Bug title" "Description"

# And other skills can use github-issue-creator:
~/.dex/skills/bug-tracker.sh  # Uses github-issue-creator internally
```

---

## Key Features

### Embedded Guidance

Self-contained documentation, no external lookups:

```bash
dex how                          # Interactive onboarding
dex guidance agent essential     # 700-line agent guide
dex guidance adapters essential  # Adapter framework guide
dex guidance browser essential   # Browser automation guide
dex grammar query                # Query syntax examples
dex machine workspace            # Architecture deep-dive
```

### 98% jq Compatibility

No external tools needed:

```bash
# Extract
dex @1 '.items[].name' -r

# Filter
dex @1 '.items[] | select(.active)' -r

# Transform
dex @1 '.items | map(.name)' -r
dex @1 '.items | sort_by(.score)' -r
dex @1 '.items | group_by(.type)' -r

# Aggregate
dex @1 '.scores | sum' -r
dex @1 '.prices | min' -r
dex @1 '.ratings | avg' -r

# Multi-response
dex aggregate @2..@50 '$.contact' --filter 'status == active'
```

### TypeScript Transformations (90/8/2 Rule)

- **90%** of tasks: Use native dex (~5ms)
- **8%** of tasks: Inline TypeScript (~70-200ms)
- **2%** of tasks: External files (>20 lines, reusable)

```bash
# Native (fast)
dex @1 '.items[] | select(.active)' -r

# Inline TypeScript (when needed)
dex @1 '$' --transform-ts 'return response.filter(x => x.score > 0.8)'

# With curated packages
dex @1 '$' --transform-ts 'import { format } from "dex:date-fns"; return format(data.date, "yyyy-MM-dd")'
```

### Flow Search & Reuse

Don't rebuild existing workflows:

```bash
# Search before building
dex flow search "fetch github issues"

# Found? Run it from /tmp
cd /tmp
~/.dex/flows/github/fetch-issues.sh facebook react open

# Not found? Build, then export
dex init my-workflow --seq
# ... explore ...
dex export ~/.dex/flows/my-workflow.sh
```

---

## Performance

```
┌──────────────────────────────────────────────────┐
│ METRICS                                          │
├──────────────────────────────────────────────────┤
│ First Exploration:  30 seconds · 8,400 tokens   │
│ Subsequent Runs:    2 seconds  · 250 tokens     │
│                                                  │
│ Cache Query Time:   <100 microseconds           │
│ Flow Export Size:   <500 bytes (binary)         │
│ Token Savings:      90-97% on repeat tasks      │
└──────────────────────────────────────────────────┘
```

---

## Use Cases

### For AI Agents

- **Workflow Automation:** Execute multi-step MCP sequences
- **Response Caching:** Query API responses without re-execution
- **Flow Reuse:** Search and reuse existing workflows
- **Error Recovery:** Real-time hints for common mistakes

### For Developers

- **API Integration:** Any REST API → MCP in seconds
- **Skill Distribution:** Share reusable workflows via registry
- **Browser Automation:** Playwright workflows with export
- **Testing:** Deterministic replay of API sequences

### For Teams

- **Knowledge Sharing:** Export successful workflows as skills
- **Onboarding:** New agents learn from existing flows
- **Standardization:** Consistent API interaction patterns
- **Cost Reduction:** 90%+ token savings across team

---

## Architecture

### Three-Layer System

**Layer 1: Adapters** (API → MCP)
- Transform REST APIs into MCP capabilities
- Semantic search across 1,000+ operations
- Production-ready middleware (rate limiting, retry, circuit breakers)

**Layer 2: Skills** (Workflows)
- Parameterized, reusable workflows
- Declare adapter dependencies (by fingerprint)
- Auto-install missing dependencies
- Compose with other skills

**Layer 3: Registry** (Distribution)
- Multi-tenant artifact registry (Supabase-based)
- Organizations (private) and Communities (public)
- Full-text search across adapters and skills
- Dependency resolution and version management

### Workspace Isolation

Each task gets its own isolated sandbox:
- Responses cached as `@1`, `@2`, `@3`...
- Variables stored as `$name=value`
- Independent MCP sessions
- Separate cache namespace

**No interference between tasks. Full isolation. Clean state.**

---

## Command Reference

### Essential Commands

```bash
# Onboarding
dex how                          # Interactive guide
dex start                        # Protocol checklist
dex guidance agent essential     # 700-line guide

# Workflow
dex init <name> --seq            # Create workspace
dex POST /endpoint '{}' -s       # Execute with session
dex @N '<query>' -r              # Query cached response
dex export <path> --params x,y   # Export as reusable flow

# Discovery
dex flow search "intent"         # Find existing flows
dex explore "intent"             # Cross-adapter tool search
dex inventory                    # List all endpoints

# Adapters
dex adapter new <id> <spec>      # Create from OpenAPI
dex adapter list                 # List installed adapters

# Skills
dex registry skill search "query" # Search registry
dex registry skill pull <name>    # Install skill
dex registry skill push <file>    # Publish skill

# Browser
dex browse --headed <url>        # Navigate and snapshot
dex browser-extract @N button    # Extract elements
dex browse click <ref>           # Interact

# Reference
dex grammar <topic>              # Command examples
dex machine <topic>              # Architecture guides
```

---

## Examples

### Example 1: GitHub Issues Workflow

```bash
# Initialize
dex init github-issues --seq
cd ~/.dex/workspaces/github-issues

# Set parameters
dex set owner=facebook repo=react state=open

# Search for capability
dex POST adapter/github-api '{
  "method": "tools/call",
  "params": {
    "name": "github_api_probe",
    "arguments": {"query": "list issues", "limit": 5}
  }
}' -s

# Execute discovered tool
dex POST adapter/github-api '{
  "method": "tools/call",
  "params": {
    "name": "github_api_call",
    "arguments": {
      "tool_name": "issues/list",
      "arguments": {"owner": "$owner", "repo": "$repo", "state": "$state"}
    }
  }
}' -t -s

# Query results
dex @2 '.items[].title' -r

# Export for reuse
dex export ~/.dex/flows/github/list-issues.sh \
  --params owner,repo,state \
  --description "Fetch GitHub issues"
```

**Reuse:**
```bash
cd /tmp
~/.dex/flows/github/list-issues.sh facebook react open
```

### Example 2: Skill Composition

```bash
# Install base adapter
dex adapter new github-api https://api.github.com/openapi.json --yes

# Install skill that uses adapter
dex registry skill pull github-issue-creator

# Skill automatically checks for github_api adapter
# If missing, prompts to install

# Use skill
~/.dex/skills/github-issue-creator.sh "Bug in login" "Steps: 1. Go to /login 2. Click submit"

# Install composite skill
dex registry skill pull bug-tracker

# This skill uses github-issue-creator internally
# Plus adds notification, assignment, labeling
~/.dex/skills/bug-tracker.sh "Critical bug" "Production down"
```

**Value Multiplication:**
- 1 adapter (github_api) → 1,111 operations
- 10 skills using adapter → 10 workflows
- 5 composite skills → 50+ capabilities
- Total: 1,111 + 10 + 50 = 1,171 capabilities from 1 adapter

---

## Why dex?

### Problem: Token Waste

Traditional approach:
```
Agent: "Fetch GitHub issues"
→ Lists all 1,111 GitHub operations (80K tokens)
→ Picks one operation
→ Makes API call
→ Parses response
→ Total: 30 seconds, 8,400 tokens

Next time: Repeat everything (no memory)
```

### Solution: Learning Substrate

With dex:
```
First time:
→ dex flow search "fetch github issues"
→ Not found, explore and export
→ 30 seconds, 8,400 tokens

Second time:
→ dex flow search "fetch github issues"
→ Found! Run existing flow
→ 2 seconds, 250 tokens (97% savings)

Subsequent times: Same 2 seconds, 250 tokens
```

### Problem: MCP Infrastructure Gap

**Traditional:** Each API needs a custom MCP server
- GitHub → Custom server
- Stripe → Custom server
- Twilio → Custom server
- Result: Maintenance burden, token waste

**With Adapters:** One framework for all APIs
- Any OpenAPI spec → Adapter in seconds
- 2 virtual tools: `{adapter}_probe` + `{adapter}_call`
- Semantic search across all operations
- Result: Universal API access

### Problem: Workflow Silos

**Traditional:** Each agent starts from scratch
- Agent A explores GitHub workflow
- Agent B explores same workflow
- Agent C explores same workflow
- Result: 3× cost, 3× time

**With Skills:** Agents learn from each other
- Agent A explores and exports skill
- Agent B searches registry, finds skill, reuses
- Agent C searches registry, finds skill, reuses
- Result: 1× cost, instant reuse

---

## Advanced Features

### Parallel Execution

```bash
# Execute multiple calls in parallel
dex for @1 '.items[]' --parallel POST /api '{"id": "$"}' -t -s

# 10 items = 10 parallel requests = 3-10x faster
```

### Dependency Tracking

```bash
# Track variable sources
dex @1 '.name' -s tool_name    # Tracks: tool_name ← @1.name

# Use in templates
dex POST /api '{"tool":"$tool_name"}' -t -s

# View dependency graph
dex ls --show-dependencies

# Export knows dependencies automatically
dex export flow.sh --params tool_name
```

### Anti-Pattern Detection

```bash
# Detect common mistakes
dex detect

# 16 patterns detected:
# - Using jq instead of native dex
# - Missing -s flag on POST
# - Hardcoded values (should be params)
# - Inefficient query patterns
```

### Model Tracking

```bash
# Set your model identity
dex model set claude-sonnet-4.5 --provider anthropic

# Track which models explore which workflows
# Enables performance comparison and debugging
```

---

## Registry System

### Multi-Tenant Architecture

**Organizations** (Private)
- Role-based access (owner/admin/developer/reader)
- Team isolation
- Private by default

**Communities** (Public)
- Anyone can join
- Subscription-based
- Public by default

### Publishing

```bash
# Create organization
dex registry org create my-company

# Push adapter
dex registry adapter push my-adapter.adapt my-company

# Push skill
dex registry skill push my-skill.sh my-company

# Or publish to community
dex registry community subscribe powerpack
dex registry skill push my-skill.sh powerpack
```

### Discovery

```bash
# Search adapters
dex registry adapter search "github api"

# Search skills
dex registry skill search "create issue"

# Pull and install
dex registry skill pull github-issue-creator
```

---

## Documentation

### Built-In Guides

```bash
dex how                          # Onboarding flow
dex start                        # Protocol checklist
dex guidance agent essential     # Essential agent guide (700 lines)
dex guidance adapters essential  # Adapter framework guide
dex guidance browser essential   # Browser automation guide
```

### Command Examples

```bash
dex grammar query                # Query syntax (jq-compatible)
dex grammar http                 # HTTP requests
dex grammar session              # Session management
dex grammar iteration            # Loops and parallel
dex grammar deno                 # TypeScript transformations
```

### Architecture

```bash
dex machine workspace            # How workspaces work
dex machine adapters             # Adapter architecture
dex machine typescript           # TypeScript integration
dex machine mcp                  # MCP session management
dex machine story                # Complete workflow story
```

---

## Platform Support

- **macOS** - Apple Silicon (M1/M2/M3) and Intel
- **Linux** - x86_64 (Ubuntu, Debian, Fedora, RHEL, etc.)
- **Windows** - Coming soon

**Binary Size:** 8-15 MB (depending on features)  
**Dependencies:** Zero runtime dependencies  
**Language:** Pure Rust (no C bindings)

---

## Security

### Binary Verification

```bash
# Download with checksum
curl -LO https://github.com/modiqo/dex-releases/raw/main/releases/latest/dex-macos-aarch64.tar.gz
curl -LO https://github.com/modiqo/dex-releases/raw/main/releases/latest/dex-macos-aarch64.tar.gz.sha256

# Verify
sha256sum -c dex-macos-aarch64.tar.gz.sha256
```

### Invite System

Private beta access with:
- Invite codes (72 bits entropy)
- Rate limiting (10 attempts/IP/minute)
- RLS policies for access control
- Referral tracking (5 invites per user)

---

## Updates

### Check Version

```bash
dex --version
```

### Update to Latest

```bash
curl -fsSL https://raw.githubusercontent.com/modiqo/dex-releases/main/install.sh | bash
```

---

## Community

- **Email:** ask@modiqo.ai
- **Private Beta:** Request invite code
- **Issues:** Contact via email
- **Documentation:** Run `dex guidance` after installation

---

## FAQ

**Q: What makes dex different from other MCP tools?**  
A: dex is a learning substrate. It doesn't just execute MCP calls - it learns from successful explorations and makes them reusable. Agents learn from each other.

**Q: Do I need to write MCP servers for my APIs?**  
A: No. Use the adapter framework to transform any OpenAPI spec into MCP capabilities in seconds.

**Q: Can I share workflows with my team?**  
A: Yes. Export flows as skills and publish to your organization or community in the registry.

**Q: How does the 90%+ token savings work?**  
A: First exploration is cached. Subsequent runs query the cache (<100 microseconds) instead of re-executing HTTP calls (500ms). Plus, exported flows are parameterized and reusable.

**Q: What's the difference between adapters and skills?**  
A: Adapters transform APIs into MCP. Skills are workflows that use adapters. Skills can depend on other skills, creating compounding value.

**Q: Is my data private?**  
A: Yes. Workspaces are local. Registry is opt-in. You control what you publish.

---

## License

See LICENSE file in this repository.

---

## About

dex is developed by Modiqo. It's designed to let agents learn from each other through embedded guidance and self-reflective languages.

**Website:** https://modiqo.ai  
**Releases:** https://github.com/modiqo/dex-releases  
**Source:** Private (this is a releases-only repository)

---

**Current Version:** v0.12.0 - Private Beta Launch  
**Status:** Production Ready  
**Platforms:** macOS (Intel + Apple Silicon), Linux (x86_64)

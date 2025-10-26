# dex - Execution Context Engineering

> **Deterministic agent-tool orchestration through embedded guidance and self-reflective languages.**


---

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ SYSTEM                                                                       │
│ OVERVIEW      dex: Lightweight Command Tool for MCP Protocol                 │
├──────────────────────────────────────────────────────────────────────────────┤
│ BINARY SIZE   8.1 MB                                                         │
│ DEPENDENCIES  Zero runtime dependencies                                      │
│ LANGUAGE      Rust (pure, no C bindings)                                     │
│ PLATFORMS     Linux (x86_64, ARM64, musl) · macOS (Intel, Apple Silicon)     │
│               Windows                                                        │
└──────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│ KEY                                                                          │
│ METRICS       First Exploration: 30 seconds · 8,400 tokens                   │
│               Subsequent Runs:   2 seconds  · 250 tokens                     │
│                                                                              │
│               Cache Query Time:  <100 microseconds                           │
│               Flow Metrics Size: <500 bytes (binary)                         │
│               Anti-Patterns:     16 patterns detected                        │
└──────────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
 FIGURE 1: SYSTEM ARCHITECTURE - DEVELOPER TO MCP SERVERS
═══════════════════════════════════════════════════════════════════════════════


    DEVELOPER              AGENT FRAMEWORK              dex BINARY
  ┌───────────┐           ┌────────────────┐        ┌───────────────┐
  │           │           │                │        │   COMMANDS    │
  │  "Fetch   │──────────>│    CURSOR      │───────>│               │
  │   my      │ Natural   │                │  CLI   │ dex init      │
  │  recent   │ Language  │    CLAUDE      │  exec  │ dex POST      │
  │  emails"  │           │    DESKTOP     │        │ dex @N '$'    │
  │           │           │                │        │ dex export    │
  │           │           │    CLINE       │        │ dex flow      │
  └───────────┘           │                │        │ dex guidance  │
      ▲                   │    AIDER       │        │ dex detect    │
      │                   │                │        │ dex plan      │
      │                   └────────────────┘        └───────┬───────┘
      │                           ▲                         │
      │                           │                         │
      │                    HINTS  │                         │
      │                    (stderr)                         │
      │                           │                         │
      │                           │                ┌────────┴────────┐
      │                           │                │  EMBEDDED       │
      │                           │                │  GUIDANCE       │
      │                           │                ├─────────────────┤
      │                           └────────────────│ Best practices  │
      │                                            │ Anti-patterns   │
      │                                            │ MCP examples    │
  ┌───┴────┐                                       │ Error hints     │
  │ RESULT │                                       └────────┬────────┘
  │        │                                                │
  │ "Here  │                                                │
  │  are   │                                                ▼
  │ your 5 │                              ┌─────────────────────────────┐
  │ emails"│                              │  CORE MECHANISMS            │
  └────────┘                              │  (stateless, deterministic) │
                                          ├─────────────────────────────┤
                                          │                             │
                                          │  ┌───────────────────────┐  │
                                          │  │ RESPONSE CACHE        │  │
                                          │  │ @1 @2 @3 ... @N       │  │
                                          │  │ In-memory HashMap     │  │
                                          │  │ Query: <100μs         │  │
                                          │  └───────────────────────┘  │
                                          │                             │
                                          │  ┌───────────────────────┐  │
                                          │  │ SESSION MANAGER       │  │
                                          │  │ -s flag auto-inject   │  │
                                          │  │ Header: Mcp-Session   │  │
                                          │  └───────────────────────┘  │
                                          │                             │
                                          │  ┌───────────────────────┐  │
                                          │  │ DAG ANALYZER          │  │
                                          │  │ Dependency tracking   │  │
                                          │  │ Parallel detection    │  │
                                          │  │ Topological sort      │  │
                                          │  └───────────────────────┘  │
                                          │                             │
                                          │  ┌───────────────────────┐  │
                                          │  │ ANTI-PATTERN ENGINE   │  │
                                          │  │ 16 patterns known     │  │
                                          │  │ Real-time detection   │  │
                                          │  │ Suggestion generator  │  │
                                          │  └───────────────────────┘  │
                                          │                             │
                                          │  ┌───────────────────────┐  │
                                          │  │ FLOW METRICS          │  │
                                          │  │ Binary storage <500B  │  │
                                          │  │ Circular buffer (20)  │  │
                                          │  │ Drift detection       │  │
                                          │  └───────────────────────┘  │
                                          │                             │
                                          └─────────────┬───────────────┘
                                                        │
                                                        │ JSON-RPC 2.0
                                                        │ over HTTP
                                                        ▼
                                          ┌─────────────────────────────┐
                                          │   MODEL CONTEXT PROTOCOL    │
                                          │   (MCP) SPECIFICATION       │
                                          └─────────────┬───────────────┘
                                                        │
                        ┌───────────────────────────────┼──────────────────┐
                        │                               │                  │
                        ▼                               ▼                  ▼
                   ┌──────────┐                   ┌──────────┐      ┌──────────┐
                   │ /GMAIL   │                   │ /GITHUB  │      │ /SLACK   │
                   │   MCP    │                   │   MCP    │      │   MCP    │
                   ├──────────┤                   ├──────────┤      ├──────────┤
                   │ init     │                   │ init     │      │ init     │
                   │ tools    │                   │ tools    │      │ tools    │
                   │ call     │                   │ call     │      │ call     │
                   │ resources│                   │ resources│      │ resources│
                   └──────────┘                   └──────────┘      └──────────┘


═══════════════════════════════════════════════════════════════════════════════
 FIGURE 2: LEARNING CYCLE - FIRST TIME EXECUTION (EXPLORATION PHASE)
═══════════════════════════════════════════════════════════════════════════════

  ELAPSED TIME: 30 seconds
  TOKENS USED:  8,400 tokens
  PHASE:        Agent explores, makes mistakes, learns correct patterns


  ┌─────────────────────────────────────────────────────────────────────────┐
  │ AGENT EXECUTION TRACE                                                   │
  └─────────────────────────────────────────────────────────────────────────┘

    t=0s     │  $ dex flow search "recent emails"
             │  No matches found
             │  [Agent decides to explore]
             │
    t=1s     │  $ dex init recent-emails --seq
             │  Workspace: ~/.dex/workspaces/recent-emails
             │  Mode: sequential
             │
    t=2s     │  $ cd ~/.dex/workspaces/recent-emails
             │  $ dex set max_results=5
             │  Variable stored: max_results=5
             │
    t=3s     │  $ dex init-session /gmail
             │  Session created: @1
             │  Session-Id: virtual-gmail-abc123
             │
    t=5s     │  $ dex POST /gmail '{"method":"tools/call",...}' -s
             │  Response cached: @2
             │  [Agent needs to extract message IDs]
             │
    t=5s     │  $ dex @2 '$.result.tools'
             │  Error: No such path
    t=5s     │  Query time: 87μs [FROM CACHE]
             │  [First mistake - wrong path]
             │
    t=6s     │  $ dex @2 '$.tools'  
             │  Result: null
    t=6s     │  Query time: 62μs [FROM CACHE]
             │  [Second mistake - still wrong]
             │
    t=7s     │  $ dex @2 '$'
             │  [Agent inspects full response structure]
    t=7s     │  Query time: 45μs [FROM CACHE]
             │
    t=8s     │  $ dex @2 '$.result.content[0].text'
             │  Result: {"messages": [...]}
    t=8s     │  Query time: 93μs [FROM CACHE]
             │  [Success! Correct path found]
             │
    t=9s     │  $ dex @2 '$.result.content[0].text | @json | 
             │          .messages[0].id' -s msg_id -r
             │  Variable stored: msg_id=abc123xyz
             │
    t=12s    │  $ dex POST /gmail '{"id":"$msg_id","format":"full"}' -t -s
             │  Response cached: @3
             │  Template expanded: $msg_id -> abc123xyz
             │
    t=15s    │  $ dex for @2 '$.result.content[0].text | @json | 
             │          .messages[]' --parallel POST /gmail '{...}' -s
             │  Parallel execution: 5 requests
             │  Responses cached: @4 @5 @6 @7 @8
             │
    t=20s    │  $ dex display @4..@8 --base '$.result.content[0].text | 
             │          @json' --field subject='...' --field from='...'
             │  
             │  ┌─────────────────────────────────────────────────────┐
             │  │ Results displayed to developer                      │
             │  └─────────────────────────────────────────────────────┘
             │
    t=22s    │  $ dex plan
             │  
             │  DAG Analysis:
             │    Level 0: @1 (init-session)
             │    Level 1: @2 (tools/call) [depends on @1]
             │    Level 2: @4 @5 @6 @7 @8 (parallel fetch) [depends on @2]
             │  
             │  [HINT] Detected: 5 requests executed in parallel (optimal)
             │
    t=23s    │  $ dex stats
             │  
             │  Token Usage:
             │    Discovery:  2,100 tokens
             │    Schema:     3,200 tokens  
             │    Execution:  3,100 tokens
             │    Total:      8,400 tokens
             │  
             │  Cache Performance:
             │    Queries:    7 total
             │    Cache hits: 6 queries (<100μs each)
             │    HTTP calls: 7 requests
             │
    t=25s    │  $ dex detect
             │  
             │  Anti-Pattern Analysis:
             │    [OK] No sequential operations that could be parallel
             │    [OK] Session management correct (-s flag used)
             │    [OK] Error handling present
             │  
             │  No anti-patterns detected.
             │
    t=28s    │  $ dex export ~/.dex/flows/gmail/recent-emails.sh \
             │      --params max_results \
             │      --description "Fetch recent Gmail messages" \
             │      --tag gmail --tag parallel
             │  
             │  Exported to: ~/.dex/flows/gmail/recent-emails.sh
             │  Parameters: max_results (required)
             │  Errors filtered: 2 failed query attempts excluded
             │  
             │  ┌────────────────────────────────────────────────────┐
             │  │ REIFICATION COMPLETE                               │
             │  │ Successful sequence → Procedural memory            │
             │  └────────────────────────────────────────────────────┘
             │
    t=30s    EXPLORATION COMPLETE


  ┌─────────────────────────────────────────────────────────────────────────┐
  │ WHAT HAPPENED                                                           │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │  • Agent made 2 query mistakes (wrong paths)                            │
  │  • Mistakes cost <100μs each (cache, not HTTP retries)                  │
  │  • Agent found correct pattern on 3rd attempt                           │
  │  • dex detected parallel optimization automatically                     │
  │  • Successful sequence exported, errors filtered out                    │
  │  • Result: Deterministic flow in ~/.dex/flows/                          │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
 FIGURE 3: HABIT EXECUTION - SUBSEQUENT INVOCATIONS (PROCEDURAL PHASE)
═══════════════════════════════════════════════════════════════════════════════

  ELAPSED TIME: 2 seconds
  TOKENS USED:  250 tokens
  PHASE:        Agent recognizes known task, invokes procedural memory


  ┌─────────────────────────────────────────────────────────────────────────┐
  │ AGENT EXECUTION TRACE                                                   │
  └─────────────────────────────────────────────────────────────────────────┘

    t=0s     │  $ dex flow search "recent emails"
             │  
             │  Semantic Search Results:
             │  
             │  ┌────────────────────────────────────────────────────┐
             │  │ Match: gmail/recent-emails.sh                      │
             │  │ Score: 92%                                         │
             │  │ Params: max_results                                │
             │  │ Tags: gmail, parallel                              │
             │  │ Last used: 2 minutes ago                           │
             │  │ Success rate: 100% (1 invocations)                 │
             │  └────────────────────────────────────────────────────┘
             │  
             │  [Agent recognizes this as known procedure]
             │
    t=0.5s   │  $ ~/.dex/flows/gmail/recent-emails.sh 5
             │  
             │  ┌────────────────────────────────────────────────────┐
             │  │ FLOW EXECUTION (DETERMINISTIC)                     │
             │  └────────────────────────────────────────────────────┘
             │  
             │  Validating token... OK
             │  Checking endpoint... OK
             │  Initializing session... OK
             │  Fetching messages... OK (5 messages)
             │  Parallel fetch... OK (5 requests, 900ms)
             │  Formatting output... OK
             │  
             │  ┌────────────────────────────────────────────────────┐
             │  │ Results displayed to developer                     │
             │  └────────────────────────────────────────────────────┘
             │  
    t=2s     │  Updating metrics: ~/.dex/flows/gmail/recent-emails.sh.metrics
             │  
             │  Metrics Updated:
             │    Total invocations: 2
             │    Successful: 2 (100%)
             │    Recent success rate: 100%
             │    Historical success rate: 100%
             │
    t=2s     HABIT EXECUTION COMPLETE


  ┌─────────────────────────────────────────────────────────────────────────┐
  │ WHAT HAPPENED                                                           │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │  • Agent searched procedural memory first (not exploration)             │
  │  • Found existing flow with 92% semantic match                          │
  │  • Invoked flow directly (no rediscovery, no mistakes)                  │
  │  • Execution was deterministic (same operations every time)             │
  │  • Metrics updated for drift detection                                  │
  │  • Time: 93% faster (2s vs 30s)                                         │
  │  • Tokens: 97% reduction (250 vs 8,400)                                 │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
 FIGURE 4: ADAPTIVE FORGETTING - ENVIRONMENTAL DRIFT DETECTION
═══════════════════════════════════════════════════════════════════════════════

  SCENARIO: Gmail API schema changed 2 weeks after flow creation
  DETECTION: Statistical drift analysis after 15 consecutive failures


  ┌─────────────────────────────────────────────────────────────────────────┐
  │ FLOW METRICS FILE: gmail/recent-emails.sh.metrics                       │
  │ FORMAT: Binary (bincode), SIZE: 517 bytes                               │
  └─────────────────────────────────────────────────────────────────────────┘

    HISTORICAL BASELINE
    ─────────────────────────────────────────────────────────────────
    Total invocations:       115
    Successful:              104  (90.4%)
    Failed:                   11  (9.6%)
    
    Error breakdown:
      Network timeout:         7  (6.1%)
      Rate limit:              4  (3.5%)
      Schema mismatch:         0  (0.0%)  ◄─── Initially zero


    RECENT WINDOW (Last 20 invocations, circular buffer)
    ─────────────────────────────────────────────────────────────────
    Invocation #96:  ✓ Success
    Invocation #97:  ✓ Success
    Invocation #98:  ✓ Success
    Invocation #99:  ✓ Success
    Invocation #100: ✓ Success
    
    [2 weeks later: Gmail API update deployed]
    
    Invocation #101: ✗ Failed  (SchemaMismatch)
    Invocation #102: ✗ Failed  (SchemaMismatch)
    Invocation #103: ✗ Failed  (SchemaMismatch)
    Invocation #104: ✗ Failed  (SchemaMismatch)
    Invocation #105: ✗ Failed  (SchemaMismatch)
    Invocation #106: ✗ Failed  (SchemaMismatch)
    Invocation #107: ✗ Failed  (SchemaMismatch)
    Invocation #108: ✗ Failed  (SchemaMismatch)
    Invocation #109: ✗ Failed  (SchemaMismatch)
    Invocation #110: ✗ Failed  (SchemaMismatch)
    Invocation #111: ✗ Failed  (SchemaMismatch)
    Invocation #112: ✗ Failed  (SchemaMismatch)
    Invocation #113: ✗ Failed  (SchemaMismatch)
    Invocation #114: ✗ Failed  (SchemaMismatch)
    Invocation #115: ✗ Failed  (SchemaMismatch)  ◄─── Drift detected!
    
    Recent success rate:      5/20  (25.0%)  ◄─── Spike!
    
    
    DRIFT DETECTION TRIGGERED
    ─────────────────────────────────────────────────────────────────
    Condition: recent_success < 0.5 × historical_success
    
    Calculation:
      Historical success:  90.4%
      Recent success:      25.0%
      Threshold:          0.5 × 90.4% = 45.2%
      
      25.0% < 45.2%  ✓ DRIFT DETECTED
    
    Statistical confidence: >95% (binomial test, p < 0.05)
    
    Error classification:
      SchemaMismatch: 15/15 (100%)  ◄─── Pattern recognized
      
    Evidence preserved: ~/.dex/flows/gmail/recent-emails.sh.stderr
      "Error: Cannot read property 'content' of undefined"
      "Expected: $.result.content[0].text"
      "Actual structure changed"
    

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ AGENT WARNING (Invocation #115)                                         │
  └─────────────────────────────────────────────────────────────────────────┘

    $ ~/.dex/flows/gmail/recent-emails.sh 5
    
    [WARNING] Flow shows environmental drift
    
    Flow: gmail/recent-emails.sh
    Historical success rate: 90%
    Recent success rate:     25% (last 20 invocations)
    
    Likely cause: API schema changed
    Error pattern: SchemaMismatch (15 consecutive failures)
    
    Evidence:
      "Cannot read property 'content' of undefined"
      "Expected path: $.result.content[0].text"
      
    Recommendation: Re-record action sequence
      $ dex init gmail-recent-v2 --seq
      [explore with new schema]
      $ dex export gmail/recent-emails.sh --params max_results
      
    This will update the flow with current API structure.
    
    Show full error log? (y/n): _


  ┌─────────────────────────────────────────────────────────────────────────┐
  │ WHAT HAPPENED                                                           │
  ├─────────────────────────────────────────────────────────────────────────┤
  │                                                                         │
  │  • Flow worked perfectly for 100 invocations (90% success baseline)     │
  │  • External API changed schema without notice                           │
  │  • dex detected drift after 15 failures (statistical significance)      │
  │  • Error classifier identified: SchemaMismatch (not transient)          │
  │  • Evidence preserved for root cause analysis                           │
  │  • Agent warned: "Re-learn this procedure, environment changed"         │
  │  • Without drift detection: Silent repeated failures                    │
  │  • With drift detection: Actionable re-learning signal                  │
  │                                                                         │
  └─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
 FIGURE 5: PERFORMANCE COMPARISON - MEASURED IMPACT
═══════════════════════════════════════════════════════════════════════════════

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ EXECUTION TIME                                                          │
  │                                                                         │
  │ First Time (Exploration)                                                │
  │ ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 30 seconds                               │
  │                                                                         │
  │ Subsequent (Habit)                                                      │
  │ ■■ 2 seconds                                                            │
  │                                                                         │
  │ Speedup: 15x (93% reduction)                                            │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ TOKEN USAGE                                                             │
  │                                                                         │
  │ First Time (Exploration)                                                │
  │ ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 8,400 tokens                 │
  │                                                                         │
  │ Subsequent (Habit)                                                      │
  │ ■ 250 tokens                                                            │
  │                                                                         │
  │ Reduction: 97% (8,150 tokens saved)                                     │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ CACHE PERFORMANCE                                                       │
  │                                                                         │
  │ HTTP re-execution (typical query iteration)                             │
  │ ■■■■■■■■■■■■■■■■■■■■■■■■■ 500 milliseconds                              │
  │                                                                         │
  │ Cached query (dex response cache)                                       │
  │ ▪ <100 microseconds                                                     │
  │                                                                         │
  │ Speedup: 5000x (learning iteration acceleration)                        │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ PARALLEL EXECUTION                                                      │
  │                                                                         │
  │ Sequential (5 message fetches)                                          │
  │ ■■■■■■■■■■■■■■■■■■■■■■■■■ 2.5 seconds                                   │
  │                                                                         │
  │ Parallel (automatic detection)                                          │
  │ ■■■■■■■■■ 0.9 seconds                                                   │
  │                                                                         │
  │ Speedup: 2.8x (via DAG analysis + dex plan)                             │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ TEAM EFFICIENCY                                                         │
  │                                                                         │
  │ Without dex (5 agents explore same task)                                │
  │ Agent 1: ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 30s                             │
  │ Agent 2: ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 30s                             │
  │ Agent 3: ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 30s                             │
  │ Agent 4: ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 30s                             │
  │ Agent 5: ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 30s                             │
  │ Total: 150 seconds                                                      │
  │                                                                         │
  │ With dex (shared procedural memory)                                     │
  │ Agent 1: ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 30s (learns)                    │
  │ Agent 2: ■■ 2s (invokes)                                                │
  │ Agent 3: ■■ 2s (invokes)                                                │
  │ Agent 4: ■■ 2s (invokes)                                                │
  │ Agent 5: ■■ 2s (invokes)                                                │
  │ Total: 38 seconds                                                       │
  │                                                                         │
  │ Team efficiency: 75% reduction (112 seconds saved)                      │
  └─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
 FIGURE 6: COMMAND REFERENCE - dex CLI SYNTAX
═══════════════════════════════════════════════════════════════════════════════

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ WORKSPACE MANAGEMENT                                                    │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ dex init <name> [--seq|--par]     Create workspace (sequential/parallel)│
  │ dex ls                             List all workspaces                  │
  │ dex cd <name>                      Switch workspace context             │
  │ dex clean <name>                   Remove workspace                     │
  │ dex clear                          Clear current workspace state        │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ MCP OPERATIONS                                                          │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ dex init-session <endpoint>        Initialize MCP session               │
  │ dex tools <endpoint> [-s]          List available tools                 │
  │ dex resources <endpoint> [-s]      List available resources             │
  │ dex prompts <endpoint> [-s]        List available prompts               │
  │ dex POST <endpoint> <json> [-s]    Execute tool call                    │
  │ dex GET <endpoint> <uri> [-s]      Read resource                        │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ QUERY & EXTRACTION                                                      │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ dex @N '<query>'                   Query cached response @N             │
  │ dex @N '<query>' -s <var>          Store result in variable             │
  │ dex @N '<query>' -r                Raw output (no JSON)                 │
  │ dex @N '<query>' -m                MCP unwrap (extract content)         │
  │ dex @ '<query>'                    Query most recent (@last)            │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ CONTROL FLOW                                                            │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ dex is-error @N                    Check if response is error           │
  │ dex exists @N '<path>'             Check if JSON path exists            │
  │ dex has-session                    Check if session initialized         │
  │ dex token-valid <endpoint>         Validate OAuth token                 │
  │ dex is-empty @N '<path>'           Check if path is empty/null          │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ ADVANCED OPERATIONS                                                     │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ dex for @N '<query>' CMD           Iterate over array, execute CMD      │
  │ dex for @N '<query>' --parallel    Parallel iteration                   │
  │ dex display @N..@M [--field ...]   Tabular display of responses         │
  │ dex plan                           Show execution DAG                   │
  │ dex stats                          Show token usage, timing             │
  │ dex detect                         Run anti-pattern detection           │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ REIFICATION & DISCOVERY                                                 │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ dex export <path> --params <list>  Export workspace as flow             │
  │ dex flow search "<query>"          Semantic search for flows            │
  │ dex flow list [--tag <tag>]        List all flows                       │
  │ dex flow info <path>               Show flow metadata & metrics         │
  │ dex guidance <server>              Show embedded guidance               │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ FLAGS                                                                   │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ -s, --session                     Auto-inject session header            │
  │ -t, --template                    Expand $variables in JSON             │
  │ -r, --raw                         Raw output (no JSON wrapping)         │
  │ -m, --mcp-unwrap                  Extract MCP content automatically     │
  │ -p, --parallel                    Execute commands in parallel          │
  └─────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════
 APPENDIX: KEY INSIGHTS
═══════════════════════════════════════════════════════════════════════════════

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ 1. DEVELOPER BEHAVIOR NEVER CHANGES                                     │
  │                                                                         │
  │    Developers continue to express intent in natural language.           │
  │    No new syntax to learn. No workflow changes. Just faster results.    │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ 2. AGENTS GET SMARTER THROUGH STRUCTURED LEARNING                       │
  │                                                                         │
  │    dex observes agent behavior, caches responses, guides toward         │
  │    correct patterns, and captures successful sequences as reusable      │
  │    procedures. Learning happens through iteration, not prompting.       │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ 3. FIRST TIME: EXPLORATION (30s) · EVERY TIME AFTER: HABIT (2s)         │
  │                                                                         │
  │    Initial exploration has cost, but procedural memory amortizes it     │
  │    across all future invocations. Break-even after 3 reuses.            │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ 4. PROCEDURAL MEMORY IS SHARED ACROSS ENTIRE TEAM                       │
  │                                                                         │
  │    One agent learns, all agents benefit. No duplicate exploration.      │
  │    Team efficiency scales linearly with flow catalog size.              │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ 5. ADAPTIVE FORGETTING KEEPS MEMORY CURRENT                             │
  │                                                                         │
  │    Statistical drift detection signals when APIs change. Agents         │
  │    receive actionable warnings to re-learn procedures rather than       │
  │    silently fail. Memory evolves with environment.                      │
  └─────────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────────┐
  │ 6. NO LLM, NO PROMPTS, NO RUNTIME                                       │
  │                                                                         │
  │    dex uses deterministic logic: caching, DAG analysis, pattern         │
  │    matching, statistical drift detection. Pure Rust, 8.1 MB binary.     │
  │    Old-fashioned intelligence that actually works.                      │
  └─────────────────────────────────────────────────────────────────────────┘
```

---

## Installation

**Option 1: Install via curl (Recommended)**

```bash
# Install latest version (v0.8.0+)
curl -fsSL https://github.com/modiqo/dex-releases/releases/latest/download/install.sh | bash

# Install specific version
DEX_VERSION=0.8.0 curl -fsSL https://github.com/modiqo/dex-releases/releases/latest/download/install.sh | bash

# Install to custom directory
DEX_INSTALL_DIR=/usr/local/bin curl -fsSL https://github.com/modiqo/dex-releases/releases/latest/download/install.sh | bash
```

**Option 2: Download binary directly**

Download pre-built binaries from [GitHub Releases](https://github.com/modiqo/dex-releases/releases):

- **Linux x86_64**: `dex-linux-x86_64.tar.gz`
- **Linux x86_64 (musl)**: `dex-linux-x86_64-musl.tar.gz` (static binary)
- **Linux ARM64**: `dex-linux-aarch64.tar.gz`
- **macOS Intel**: `dex-macos-x86_64.tar.gz`
- **macOS Apple Silicon**: `dex-macos-aarch64.tar.gz`
- **Windows x86_64**: `dex-windows-x86_64.zip`

```bash
# Example: Install on Linux
wget https://github.com/modiqo/dex-releases/releases/latest/download/dex-linux-x86_64.tar.gz
tar xzf dex-linux-x86_64.tar.gz
sudo mv dex /usr/local/bin/
```
---

## Learn More

- **Documentation:** [https://getdex.sh](https://getdex.dev)
- **Author:** Chetan Conikee <chetan@modiqo.ai>
---

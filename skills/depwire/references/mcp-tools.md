# MCP Tools Reference

Complete reference for all 23 depwire MCP tools.

## Connection

### `connect_repo`

Connect depwire to a local project or GitHub repository.

```typescript
connect_repo({
  source: string,           // Local path or GitHub URL
  subdirectory?: string,    // Subdirectory to analyze (optional)
})
```

**Returns**: Confirmation with project root path.

**Use when**: Starting a new project analysis, connecting to a different repo.

---

## Navigation & Search

### `search_symbols`

Find symbols by name across the entire codebase. Supports partial matching.

```typescript
search_symbols({
  query: string,            // Symbol name (case-insensitive substring)
  limit?: number,          // Max results (default: 20)
})
```

**Returns**: Array of matching symbols with file locations.

**Example use**: Finding all references to `UserService` before renaming.

---

### `list_files`

List all files in the project with basic stats.

```typescript
list_files({
  directory?: string,      // Filter to specific subdirectory (optional)
})
```

**Returns**: File paths with size, modification time, symbol count.

---

### `get_symbol_info`

Look up detailed information about a specific symbol.

```typescript
get_symbol_info({
  name: string, // Symbol name (e.g., 'Router') or full ID (e.g., 'src/router.ts::Router')
});
```

**Returns**: All imports, exports, dependents, and file location.

**Note**: If multiple symbols share the same name, returns all matches for disambiguation.

---

## Dependency Queries

### `get_dependencies`

Get all symbols that a given symbol depends on (what does this symbol use/import/call?).

```typescript
get_dependencies({
  symbol: string, // Symbol name or full ID
});
```

**Returns**: Direct dependencies with file paths.

**Use when**: Understanding what a symbol imports — useful before refactoring to see coupling.

---

### `get_dependents`

Get all symbols that depend on a given symbol (what uses this symbol?).

```typescript
get_dependents({
  symbol: string, // Symbol name or full ID
});
```

**Returns**: Direct dependents with file paths.

**Use when**: Understanding blast radius — how many things would break if this symbol changed.

---

### `get_file_context`

Get complete context about a file — all symbols defined in it, all imports, all exports, and all files that import from it.

```typescript
get_file_context({
  filePath: string, // Relative file path (e.g., 'services/UserService.ts')
});
```

**Returns**: Imports, exports, internal symbols, dependents, cross-language edges (REST API calls, subprocess invocations).

**Use when**: Understanding a file's full surface area before refactoring.

---

## Impact & Safety

### `impact_analysis`

Analyze what would break if a symbol is changed, renamed, or removed.

```typescript
impact_analysis({
  symbol: string,           // Symbol name or full ID
  file?: string,            // Optional file path to disambiguate
})
```

**Returns**:

- Direct dependents
- Transitive dependents (chain reaction)
- All affected files
- Cross-language edges included (TypeScript fetch → Python route counts as affected)

**Use when**: Planning any significant change — shows the full blast radius.

---

### `simulate_change`

Simulate an architectural change before touching any code. Zero file I/O.

```typescript
simulate_change({
  operation: "move" | "delete" | "rename" | "split" | "merge",
  target: string,           // Relative file path of primary target
  destination?: string,      // Required for move and rename — new file path
  symbols?: string[],       // Required for split — symbol names to move to new file
  mergeTarget?: string,     // Required for merge — the file to merge into target
})
```

**Returns**:

- Health score delta (negative = risk, positive = improvement)
- Broken imports
- Affected nodes

**Use when**: About to rename/move/delete/split/merge — shows exactly what would break.

**Example**:

```typescript
// Simulate renaming UserService to UserManager
simulate_change({
  operation: 'rename',
  target: 'src/services/user.service.ts',
  destination: 'src/services/user-manager.ts',
});
```

---

### `verify_change`

Before applying a code change, return a deterministic safety report.

```typescript
verify_change({
  file_path?: string,       // File path being changed
  new_content?: string,     // Proposed new content of the file
  unified_diff?: string,    // OR a unified diff string
  agent_identity_token?: string,
})
```

**Returns**:

- Broken imports
- New circular dependencies
- Health score impact
- Targeted security scan on changed files

**Use when**: Pre-commit check, pre-PR safety gate.

---

## Architecture & Health

### `get_architecture_summary`

Get high-level overview of project's architecture.

```typescript
get_architecture_summary({});
```

**Returns**:

- File count
- Symbol count
- Most connected files (hotspots)
- Orphan files (no connections)
- Dependency depth

**Use when**: Onboarding, getting oriented, understanding project structure.

---

### `get_health_score`

Get a 0-100 health score for the project's dependency architecture.

```typescript
get_health_score({});
```

**Returns**: Overall score, per-dimension breakdown, actionable recommendations.

**Dimensions**:
| Dimension | What it measures |
|-----------|-----------------|
| Coupling | Inter-module dependencies |
| Cohesion | Related code grouped together |
| Complexity | Cyclomatic complexity distribution |
| Naming | Naming convention consistency |
| Architecture | Layer adherence |
| Dead code | Unused symbol percentage |

**Score interpretation**:

- **90-100**: Excellent
- **70-89**: Good
- **50-69**: Fair — technical debt accumulating
- **Below 50**: Poor — significant refactoring needed

---

### `get_temporal_graph`

Show how the dependency graph evolved over git history.

```typescript
get_temporal_graph({
  commits?: number,         // Number of commits to sample (default: 10)
  strategy?: "even" | "weekly" | "monthly",  // Sampling strategy (default: even)
})
```

**Returns**: Snapshots at sampled commits showing file counts, symbol counts, edge counts, structural changes.

**Use when**: Detecting architecture regression, showing trends to stakeholders.

---

### `visualize_graph`

Render an interactive arc diagram visualization of the current codebase's cross-reference graph.

```typescript
visualize_graph({
  highlight?: string,       // File or symbol name to highlight (optional)
  maxFiles?: number,        // Limit to top N most connected files (optional)
})
```

**Returns**: Inline visualization showing files as bars along the bottom, dependency arcs connecting them, colored by distance.

**Use when**: Presenting architecture to team, understanding connectivity patterns.

---

## Documentation

### `get_project_docs`

Retrieve auto-generated codebase documentation.

```typescript
get_project_docs({
  doc_type?: "architecture" | "conventions" | "dependencies" | "onboarding" | "all",  // default: all
})
```

**Returns**: Architecture overview, code conventions, dependency maps, onboarding guides.

**Docs generated** (13 total):

- ARCHITECTURE.md
- CONVENTIONS.md
- DEPENDENCIES.md
- ONBOARDING.md
- FILES.md
- API_SURFACE.md
- ERRORS.md
- TESTS.md
- HISTORY.md
- CURRENT.md
- STATUS.md
- HEALTH.md
- DEAD_CODE.md

**Use when**: Onboarding new developers, architecture documentation, understanding project structure.

---

### `update_project_docs`

Regenerate codebase documentation with the latest changes.

```typescript
update_project_docs({
  doc_type?: "architecture" | "conventions" | "dependencies" | "onboarding" | "all",  // default: all
})
```

**Use when**: After significant refactors, before releases, when docs are stale.

---

## Code Quality

### `find_dead_code`

Find potentially dead code — symbols defined but never referenced.

```typescript
find_dead_code({
  confidence?: "high" | "medium" | "low",  // Minimum confidence (default: medium)
})
```

**Returns**: Symbols categorized by confidence level:

- **high**: Definitely unused — safe to remove
- **medium**: Likely unused — verify with `get_dependents`
- **low**: Possibly unused — may be dynamically used, reflection, framework magic

**Use when**: Tech debt cleanup, sprint cleanup, before large refactors.

**Note**: Smart exclusions for entry points (main, App, exports). Edge cases exist — always verify with `get_dependents` before deleting.

---

### `security_scan`

Scan the codebase for security vulnerabilities with graph-aware severity scoring.

```typescript
security_scan({
  classes?: string[],        // Vulnerability classes to check (optional, omit for all)
  graphAware?: boolean,     // Enable graph-aware severity elevation (default: true)
  target?: string,           // Relative file path to scan (optional, omit for full scan)
})
```

**Checks**:

- Dependency CVEs
- Shell injection
- Hardcoded secrets
- Path traversal
- Auth bypass
- Input validation
- Information disclosure
- Cryptography weaknesses
- Frontend XSS
- Architecture-level risks

**Severity levels** (graph-aware):

- **Critical**: Reachable from MCP tools or HTTP routes (remote exploit possible)
- **High**: Reachable from internal services
- **Medium**: Not directly reachable but vulnerable
- **Low**: Theoretical vulnerability

**Use when**: Security audit, CI pipeline, before releases.

---

## Multi-Agent Coordination

### `claim_files`

Declare intent to modify files so other MCP clients see the claim and avoid conflicts.

```typescript
claim_files({
  file_paths: string[],      // Files to claim
  session_id: string,        // Identifies calling agent/session
  ttl_minutes?: number,      // Time-to-live (default: 30, max: 240)
  reason?: string,           // Human-readable reason (optional)
  agent_identity_token?: string,
})
```

**Returns**: Claim ID for later release.

**Use when**: Multi-agent workflows, about to start working on files that others might touch.

---

### `get_active_claims`

Query who is currently working on what.

```typescript
get_active_claims({
  filter_by_file?: string,   // Only return claims affecting this file (optional)
  filter_by_session?: string, // Only return claims from this session (optional)
  include_expired?: boolean,  // Include expired claims (default: false)
})
```

**Returns**: Active file claims with session IDs, reasons, expiration times.

**Use when**: Checking for conflicts before starting work, team coordination.

---

### `release_files`

Release a previously made file claim.

```typescript
release_files({
  claim_id: string, // The claim ID to release
  session_id: string, // Must match original claim's session_id
});
```

**Use when**: Done with claimed files, aborting work, handing off to another agent.

---

## Decision Memory

### `record_decision`

Save a structured decision for future sessions to reference.

```typescript
record_decision({
  context: string,           // What problem was being solved
  decision: string,          // What was chosen
  options_considered: string[],  // Alternatives weighed
  reasoning: string,         // Why this option was chosen
  files_affected?: string[], // Optional list of files this decision touches
  tags?: string[],           // Optional tags for categorization
  session_id: string,        // Identifies calling agent/session
  agent_identity_token?: string,
})
```

**Stores**: In `.depwire/decisions.jsonl` (persists across sessions).

**Use when**: Architectural decision made, team convention established, tradeoff documented.

---

### `get_decisions`

Retrieve past decisions matching a query.

```typescript
get_decisions({
  query?: string,            // Free-text search across context, decision, reasoning
  filter_by_file?: string,   // Only decisions affecting this file
  filter_by_session?: string, // Only decisions from this session
  filter_by_tag?: string,    // Only decisions with this tag
  limit?: number,            // Max results (default: 20, max: 100)
  since?: string,            // ISO-8601 timestamp, only decisions after this time
})
```

**Use when**: Understanding why something was done a certain way, onboarding, investigating architecture choices.

---

## Tool Combinations Quick Reference

| Scenario                        | Tools to chain                                                             |
| ------------------------------- | -------------------------------------------------------------------------- |
| About to rename a symbol        | `search_symbols` → `impact_analysis` → `simulate_change` → `verify_change` |
| Dead code cleanup               | `find_dead_code` → `get_dependents` (verify) → `simulate_change` (delete)  |
| Security audit                  | `security_scan` → `impact_analysis` (per finding) → `verify_change`        |
| Pre-PR check                    | `verify_change` → `get_health_score`                                       |
| Onboarding                      | `get_architecture_summary` → `get_project_docs`                            |
| Multi-agent coordination        | `claim_files` → work → `release_files`                                     |
| Documenting decision            | `record_decision`                                                          |
| Finding architectural decisions | `get_decisions`                                                            |
| Understanding file context      | `get_file_context` → `get_dependents` → `get_dependencies`                 |

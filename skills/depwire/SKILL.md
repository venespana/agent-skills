---
name: depwire
description: Use depwire for architecture analysis, refactor safety, dead code detection, security scanning, and dependency-aware code changes. Trigger when user mentions depwire, wants to analyze code structure, find unused code, plan refactoring, check impact before changes, understand dependencies, audit security, or needs to know what would break if they delete/rename/move a symbol. Use depwire whenever you're about to touch code and don't know the blast radius — it's the difference between guessing and knowing.
---

# Depwire Skill

Depwire provides symbol-level dependency graphs with graph-aware analysis. It knows what actually breaks before you touch anything.

## Overview

Depwire has 23 MCP tools and 8 CLI commands. The core value: **before you change code, know exactly what breaks**.

Key differentiators vs traditional tools:

- **Deterministic** (not probabilistic) — graph queries, not embeddings
- **Symbol-level** — every function/class/import tracked, not just files
- **What-If simulation** — zero file I/O before applying changes
- **Cross-language** — detects REST API edges (TS fetch → Python route) and subprocess edges
- **Graph-aware security** — a medium vulnerability reachable from HTTP route becomes Critical

## Core Decision Tree

```
You need to change code.
        │
        ▼
Is this a REFACTOR (delete/move/rename/split/merge)?
        │
   ┌────┴────┐
  YES         NO
   │           │
   ▼           ▼
simulate_change    Is this PRE-COMMIT or PRE-PR?
 → blast radius         │
   + health delta    ┌──┴───┐
                      YES    NO
                       │      │
                       ▼      ▼
                   verify_change   Is this for DOCUMENTATION / ONBOARDING?
                       │                    │
                       │                ┌───┴────┐
                       │            YES           NO
                       │             │             │
                       ▼             ▼             ▼
                   pre-commit    get_project_docs  Is this for TEAM COORDINATION?
                   safety check  (13 auto-docs)     │
                                                ┌────┴────┐
                                              YES         NO
                                               │           │
                                               ▼           ▼
                                          claim_files  get_health_score
                                          get_active_claims  → architecture
                                          record_decision      overview + fix
                                          get_decisions
```

## MCP Tools Reference

### Impact & Safety (Use Before ANY Change)

| Tool              | When to use                                          | Key output                                     |
| ----------------- | ---------------------------------------------------- | ---------------------------------------------- |
| `simulate_change` | Planning refactor (delete/move/rename/split/merge)   | health delta, broken imports, affected nodes   |
| `impact_analysis` | Want to understand blast radius of changing a symbol | direct + transitive dependents, affected files |
| `verify_change`   | Pre-commit or pre-PR safety check                    | broken imports, circular deps, health delta    |

### Architecture & Health

| Tool                       | When to use                       | Key output                                  |
| -------------------------- | --------------------------------- | ------------------------------------------- |
| `get_health_score`         | Sprint start, architecture review | 0-100 score, 6 dimensions, recommendations  |
| `get_architecture_summary` | Onboarding, getting oriented      | file count, symbol count, hotspots, orphans |
| `get_temporal_graph`       | Architecture regression detection | evolution over git history                  |
| `visualize_graph`          | Presenting architecture to team   | interactive arc diagram                     |

### Code Quality

| Tool               | When to use                         | Key output                                         |
| ------------------ | ----------------------------------- | -------------------------------------------------- |
| `find_dead_code`   | Tech debt cleanup, sprint cleanup   | unused symbols by confidence (high/medium/low)     |
| `security_scan`    | Security audit, CI pipeline         | vulnerabilities by severity with attack scenarios  |
| `get_file_context` | Understanding a file's full context | imports, exports, dependents, cross-language edges |

### Navigation & Search

| Tool               | When to use                              | Key output                   |
| ------------------ | ---------------------------------------- | ---------------------------- |
| `search_symbols`   | Finding a symbol by name across codebase | symbol locations             |
| `get_symbol_info`  | Looking up a symbol's details            | imports, exports, dependents |
| `get_dependencies` | What does this symbol use/import/call?   | dependency list              |
| `get_dependents`   | What depends on this symbol?             | dependent list               |
| `list_files`       | Listing all files with stats             | file tree                    |

### Documentation

| Tool                  | When to use                   | Key output                                                                         |
| --------------------- | ----------------------------- | ---------------------------------------------------------------------------------- |
| `get_project_docs`    | Onboarding, architecture docs | 13 auto-generated docs (architecture, conventions, dependencies, onboarding, etc.) |
| `update_project_docs` | After significant refactors   | regenerates all 13 docs                                                            |

### Multi-Agent Coordination

| Tool                | When to use                      | Key output                           |
| ------------------- | -------------------------------- | ------------------------------------ |
| `claim_files`       | Declaring intent to modify files | claim ID for later release           |
| `get_active_claims` | Checking who's working on what   | active file claims                   |
| `release_files`     | Releasing a file claim           | removes claim                        |
| `record_decision`   | Saving architectural decision    | decision in .depwire/decisions.jsonl |
| `get_decisions`     | Retrieving past decisions        | decisions by query/session/tag/file  |

### Connection

| Tool           | When to use                                 |
| -------------- | ------------------------------------------- |
| `connect_repo` | Connect to any local project or GitHub repo |

## Bundled Scripts (Always Use When Applicable)

This skill includes automation scripts that guide the agent through common workflows. **Always reference and follow the relevant script** when the task matches its workflow:

| Script                             | Use when                           | What it provides                                  |
| ---------------------------------- | ---------------------------------- | ------------------------------------------------- |
| `scripts/depwire-quick-check.sh`   | Fast pre-change dependency check   | Impact/simulate/verify decision guide             |
| `scripts/depwire-refactor-safe.sh` | Renaming, moving, deleting symbols | 4-step safe refactoring workflow                  |
| `scripts/depwire-dead-code.sh`     | Sprint cleanup, tech debt          | Confidence-level verification + deletion guidance |
| `scripts/depwire-security.sh`      | Pre-release security audit         | Severity triage, fix patterns, CI integration     |

**Scripts are documentation — read them and apply their workflow steps.** They contain decision points, verification checklists, and fix patterns that the agent should follow exactly.

## Report Structure (Mandatory for All Outputs)

When producing any depwire analysis report, follow this structure:

```
# [Title] — Depwire Analysis

## Executive Summary
[2-3 sentences: what was analyzed, key findings, go/no-go recommendation]

## Tools Called
[Table: tool name, purpose, key output — include ALL numbers returned]

## Detailed Findings
[Organized findings with tool output data included inline]

## Attack Scenarios / Impact Assessment (for security/refactor)
[For each finding: threat/impact, exploitability, code-level fix pattern]

## Recommended Actions
[Prioritized list with timeframes]

## False Positive Notes (always check)
[Any findings that might be false positives and why]
```

**Critical rule: Always include the actual tool output data in your report — numbers, file paths, severity levels.** Never just say "impact analysis was run" — include the count of dependents, the health delta, the specific files affected.

## Workflows

### Safe Refactoring Workflow

Follow `scripts/depwire-refactor-safe.sh`:

```
1. connect_repo (if not already connected)
2. search_symbols → confirm symbol exists first
3. impact_analysis(symbol) → capture direct + transitive dependents
4. simulate_change(target, operation, destination) → capture health_delta, broken_imports
5. Review output and present to user: health delta (negative=risk), broken_imports, affected_nodes
6. If approved: verify_change → apply → quality gates
```

### Dead Code Cleanup Workflow

Follow `scripts/depwire-dead-code.sh`:

```
1. find_dead_code(confidence="high") ← start with high only
2. For each HIGH confidence symbol:
   a. Verify with get_dependents — no consumers = safe
   b. Check for false positives: entity classes with private fields accessed via getters,
      React hooks re-exported through barrels, route-based pages (not import-connected)
3. For MEDIUM/LOW: flag for human review only — NEVER auto-delete
4. Common false positives to check:
   - Entity classes: private _fields accessed via public getters — NOT dead
   - Barrel re-exports: symbols re-exported through index.ts — NOT dead
   - Route pages: loaded by router, no explicit import — NOT dead
   - Test files: not imported by app code — NOT dead
   - Dynamic imports, reflection, framework magic
```

### Security Audit Workflow

Follow `scripts/depwire-security.sh`:

```
1. security_scan(target, graphAware=true) ← scan specific path or full repo
2. Sort findings by severity: CRITICAL first, then HIGH, MEDIUM, LOW
3. For each CRITICAL/HIGH finding:
   a. impact_analysis(symbol) → capture the impact data
   b. Include the specific attack scenario from security_scan output
   c. Provide code-level fix pattern (before/after code)
4. For each finding: explain WHY it has its severity (graph-aware reasoning)
5. CRITICAL: fix immediately, verify_change before commit
6. HIGH: fix within sprint
7. Include a prioritized action table at the end of the report
```

### Pre-PR Safety Check

```
1. verify_change(unified_diff="...")  ← paste diff or file paths
2. Check:
   - broken_imports: must be empty
   - circular_dependencies: must be empty
   - health_score_delta: must not be negative
3. If any check fails: do NOT commit until fixed
4. Run quality gates before commit
```

### Impact Analysis Before Big Changes

```
1. For multi-symbol changes:
   a. impact_analysis(symbol="ParentSymbol")
   b. For each affected symbol, recursively check impact
2. Build a change impact report:
   - Core symbols to change (direct)
   - Downstream consumers (transitive)
   - Cross-language dependencies (REST API edges)
   - Test files affected
3. Present to user before proceeding
```

## Output Interpretation

### Health Score Dimensions

`get_health_score` returns 0-100 across 6 dimensions:

- **Coupling**: inter-module dependencies
- **Cohesion**: related code grouped together
- **Complexity**: cyclomatic complexity distribution
- **Naming**: consistency of naming conventions
- **Architecture**: layer adherence
- **Dead code**: unused symbol percentage

Score interpretation:

- **90-100**: Excellent — production ready
- **70-89**: Good — minor improvements possible
- **50-69**: Fair — technical debt accumulating
- **Below 50**: Poor — significant refactoring recommended

### Dead Code Confidence

- **high**: Definitely unused — safe to remove automatically
- **medium**: Likely unused — verify with `get_dependents` before removing
- **low**: Possibly unused — manual review required (may be dynamically used, reflection, framework magic)

**False positive patterns** (depwire may flag these as dead when they are NOT):

- Entity classes with private `_fields` accessed via public getters
- React hooks exported through barrel files (index.ts re-exports)
- Route-based pages loaded by router (TanStack Router, no explicit import edges)
- Test files not imported by production code
- Framework magic (DI containers, decorators, dynamic imports)
- Always verify with `get_dependents` before deleting even HIGH confidence symbols

### Security Severity (Graph-Aware)

Depwire elevates severity based on reachability:

- **Critical**: Reachable from MCP tools or HTTP routes (remote exploit possible)
- **High**: Reachable from internal services
- **Medium**: Not directly reachable but vulnerable
- **Low**: Theoretical vulnerability

## Anti-Patterns (When NOT to Use Depwire)

- **Trivial one-file changes** with no downstream consumers — depwire overhead not justified
- **Deep semantic/data-flow analysis** — use CodeQL or SonarQube instead
- **Very early prototyping** where architecture changes daily — graph becomes stale fast
- **Package-level only analysis** — traditional build graphs (Nx, Turborepo) are faster

## Integration with Other Skills

| Context          | Depwire workflow                                                     |
| ---------------- | -------------------------------------------------------------------- |
| SDD apply phase  | Use `simulate_change` + `verify_change` before implementing          |
| refactoring code | Use `impact_analysis` + `simulate_change` to understand blast radius |
| quality-gates    | Add `verify_change` as pre-commit check                              |
| security audit   | Run `security_scan` + `impact_analysis` for each finding             |
| git-workflow     | Record architectural decisions with `record_decision`                |

## Health Score Usage in SDD

When running SDD phases:

- **After design phase**: Run `get_health_score` to establish baseline
- **After apply phase**: Run `get_health_score` again to verify no regression
- **Before archive**: Run `find_dead_code` to clean up what was introduced
- **Before PR**: Run `verify_change` as safety gate

## Quick Reference Commands (CLI)

```bash
# Interactive visualization
depwire viz

# Simulate before changing
depwire whatif --target=UserService --operation=rename --new-name=UserManager

# Architecture health
depwire health

# Dead code detection
depwire dead-code --min-confidence=high

# Security scan
depwire security --fail-on=high

# Generate documentation
depwire docs

# Temporal evolution
depwire temporal --commits=10
```

## Files Generated by Depwire

| File/Dir                   | Purpose                                            |
| -------------------------- | -------------------------------------------------- |
| `.depwire/decisions.jsonl` | Architectural decisions (persists across sessions) |
| `.depwire/claims.jsonl`    | Active file claims for multi-agent coordination    |
| `depwire-output.json`      | Last analyzed dependency graph                     |
| `.depwire/`                | Config, cache, output (gitignored)                 |

---

## Key Resources

Always load the appropriate resource for your task:

| Resource                       | When to load               | Content                                              |
| ------------------------------ | -------------------------- | ---------------------------------------------------- |
| `references/mcp-tools.md`      | Need exact tool parameters | Complete 23 MCP tools with signatures and examples   |
| `references/health-guide.md`   | Interpreting health scores | Dimension breakdown, improvement strategies          |
| `references/security-guide.md` | Security audit or finding  | Vulnerability classes, fix patterns, false positives |
| `assets/decision-guide.md`     | Unsure which tool to use   | Decision trees for every scenario                    |
| `assets/cli-reference.md`      | Using CLI commands         | Complete CLI command reference                       |

**About scripts**: Scripts are executable documentation. Read them when starting the corresponding workflow — they contain decision points and verification steps you must follow. Do not improvise when a bundled script covers your task.

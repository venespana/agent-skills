# Depwire Decision Guide

Quick reference for which tool to use when.

## Common Scenarios

| What you want to do                   | Tool to use                   | Why                                                |
| ------------------------------------- | ----------------------------- | -------------------------------------------------- |
| About to rename/move/delete something | `simulate_change`             | Shows exact breakage before you touch code         |
| Want to know blast radius of a change | `impact_analysis`             | Direct + transitive dependents, all files          |
| Pre-commit or pre-PR safety check     | `verify_change`               | Broken imports, circular deps, health delta        |
| Start of sprint / architecture review | `get_health_score`            | 0-100 across 6 dimensions with recommendations     |
| Onboarding / understanding codebase   | `get_architecture_summary`    | File count, hotspots, orphans                      |
| Finding unused code                   | `find_dead_code`              | Confidence-scored (high/medium/low)                |
| Security audit                        | `security_scan`               | 11 vulnerability classes, graph-aware severity     |
| Understanding a file's full context   | `get_file_context`            | Imports, exports, dependents, cross-language edges |
| Before big refactor                   | `get_health_score` → baseline | Compare before/after                               |
| After refactor                        | `verify_change`               | Ensure no breakage                                 |
| Before archive                        | `find_dead_code`              | Clean up dead code                                 |
| Multi-agent coordination              | `claim_files`                 | Avoid conflicts                                    |
| Architectural decision made           | `record_decision`             | Persist for future                                 |
| Why was something done this way?      | `get_decisions`               | Retrieve past decisions                            |
| Presenting architecture to team       | `visualize_graph`             | Interactive arc diagram                            |
| Architecture over time                | `get_temporal_graph`          | Git history scrubbing                              |

## Decision Tree: Which Tool for Refactoring?

```
Planning a rename/move/delete/split/merge?
        │
   YES ──────── NO
   │              │
   ▼              ▼
simulate_change   Is it a delete operation?
        │              │
        │         ┌────┴────┐
        │        YES        NO
        │         │          │
        │         ▼          ▼
        │    simulate     Need safety check?
        │    (shows            │
        │     exact       ┌────┴────┐
        │     breakage)   YES        NO
        │                  │          │
        │                  ▼          ▼
        │             verify_change  impact_analysis
        │                  │          │
        │                  │          ▼
        │                  │    Understanding
        │                  │    blast radius
        │                  ▼
        ▼            Pre-commit/pre-PR
    Pre-apply         safety check
```

## Decision Tree: Which Tool for Analysis?

```
Want to analyze code?
        │
   ┌────┴────────────────────────┐
   │                             │
   ▼                             ▼
Architecture/Health          Code Quality
   │                             │
   ├── get_health_score       ├── find_dead_code
   ├── get_architecture_summary├── security_scan
   ├── get_temporal_graph     └── get_file_context
   └── visualize_graph
```

## Decision Tree: Which Tool for Coordination?

```
Multi-agent or team workflow?
        │
   ┌────┴─────┐
   │          │
  YES         NO
   │          │
   ▼          ▼
claim_files  record_decision
get_active_claims (if needed)
release_files (when done)
   │
   ▼
get_decisions (to retrieve)
```

## Severity → Action Mapping

| Severity            | Timeframe      | Action                                    |
| ------------------- | -------------- | ----------------------------------------- |
| Critical (security) | Immediate      | Fix in same session, verify before commit |
| High (security)     | Current sprint | Schedule fix, document attack scenario    |
| Medium              | Next sprint    | Add to tech debt backlog                  |
| Low                 | Backlog        | Document for future cleanup               |
| Dead code HIGH      | This sprint    | Verify with get_dependents, auto-remove   |
| Dead code MEDIUM    | Next sprint    | Manual review required                    |
| Dead code LOW       | Backlog        | Manual review required                    |

## Health Score → Action Mapping

| Score    | Rating    | Action                                 |
| -------- | --------- | -------------------------------------- |
| 90-100   | Excellent | No action needed                       |
| 70-89    | Good      | Minor improvements OK                  |
| 50-69    | Fair      | Plan refactor within 2 sprints         |
| Below 50 | Poor      | Immediate attention, break into chunks |

## Integration with Other Skills

```
SDD apply phase:
  Before implementing → simulate_change → verify_change

quality-gates:
  Pre-commit → verify_change → get_health_score

git-workflow:
  After architectural decision → record_decision
  Before big change → impact_analysis + get_health_score baseline
  After change → get_health_score comparison

fsd-validation:
  Check architecture with get_health_score
  Verify no cross-slice violations before commit

security audit:
  security_scan → impact_analysis per finding → fix → verify_change
```

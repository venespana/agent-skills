# Health Score Guide

Interpreting depwire's 0-100 health score and its 6 dimensions.

## Overview

`get_health_score` returns an overall score and per-dimension breakdown:

```
{
  "overall": 78,
  "dimensions": {
    "coupling": { "score": 82, "issues": [...] },
    "cohesion": { "score": 75, "issues": [...] },
    "complexity": { "score": 68, "issues": [...] },
    "naming": { "score": 85, "issues": [...] },
    "architecture": { "score": 71, "issues": [...] },
    "dead_code": { "score": 90, "issues": [...] }
  },
  "recommendations": [...]
}
```

## Dimension Breakdown

### Coupling (inter-module dependencies)

**What it measures**: How tightly modules depend on each other.

**High coupling indicators**:

- Deep import chains (A imports B imports C)
- Circular dependencies
- High fan-out (one module imports many)
- High fan-in (many modules import one)

**Healthy range**: 75-95

**How to improve**:

- Introduce interfaces/ports for cross-module communication
- Use dependency injection to invert dependencies
- Break God modules into smaller focused units

---

### Cohesion (related code grouped together)

**What it measures**: How well related functionality is colocated.

**Low cohesion indicators**:

- Utility modules with unrelated helpers
- Modules that change for different reasons
- Feature split across many locations

**Healthy range**: 70-90

**How to improve**:

- Colocate code that changes together
- Extract shared utilities into dedicated modules
- Use FSD layers: features with high cohesion in slices

---

### Complexity (cyclomatic complexity distribution)

**What it measures**: Complexity distribution across functions/methods.

**High complexity indicators**:

- Functions with many branches/loops
- Deep nesting
- Large switch statements
- Complex conditional logic

**Healthy range**: 65-85

**How to improve**:

- Extract complex functions into smaller units
- Replace switch statements with polymorphism
- Use early returns to reduce nesting
- Extract complex conditions into well-named functions

---

### Naming (naming convention consistency)

**What it measures**: Consistency and clarity of identifiers.

**Naming issues**:

- Inconsistent casing (camelCase vs snake_case)
- Cryptic abbreviations
- Too generic names (data, info, temp)
- Hungarian notation mixed with modern styles

**Healthy range**: 80-95

**How to improve**:

- Establish and document naming conventions
- Use consistent prefixes for related concepts
- Prefer descriptive over abbreviated
- Match language conventions (TypeScript: camelCase for variables, PascalCase for types)

---

### Architecture (layer adherence)

**What it measures**: How well the code follows architectural principles.

**Architecture violations**:

- Upward imports (entities importing features)
- Cross-slice imports at same layer
- Business logic in UI components
- Infrastructure in domain layer

**Healthy range**: 70-90

**How to improve**:

- Enforce import rules via linter
- Use FSD layer validation skill
- Move business logic to use cases
- Keep services thin (delegation only)

---

### Dead Code (unused symbol percentage)

**What it measures**: Percentage of symbols with zero references.

**Healthy range**: 85-100 (low dead code = high score)

**Indicators of issues**:

- Old features not cleaned up
- Refactored code leaving behind artifacts
- Experimented code never removed

**How to improve**:

- Run `find_dead_code` regularly
- Remove HIGH confidence dead code
- Review MEDIUM/LOW with `get_dependents`
- Set CI to fail on high dead code percentage

---

## Score Interpretation

| Score        | Rating    | Action                                     |
| ------------ | --------- | ------------------------------------------ |
| **90-100**   | Excellent | Production ready, minor polish only        |
| **70-89**    | Good      | Minor improvements possible, no urgency    |
| **50-69**    | Fair      | Technical debt accumulating, plan refactor |
| **Below 50** | Poor      | Significant refactoring recommended ASAP   |

## What Causes Score Drops

| Change type                       | Typical impact             |
| --------------------------------- | -------------------------- |
| Adding circular dependency        | -5 to -15 coupling         |
| Adding God function (>100 lines)  | -10 to -20 complexity      |
| Introducing cross-slice import    | -10 to -20 architecture    |
| Not removing dead code            | Stable dead_code dimension |
| Renaming without updating imports | Varies by impact           |

## Health Score in SDD Workflow

### Baseline (after design phase)

Run `get_health_score` to establish baseline. Document the score.

### Pre-apply check

Verify no major architecture violations in the planned implementation.

### Post-apply verification

Run `get_health_score` again. Compare to baseline:

- Drop >5 points: Investigate what caused it, fix before committing
- Drop >10 points: Do not commit until resolved

### Before archive

Run `find_dead_code` to clean up any dead code introduced during the change.

## Health Score as Quality Gate

Integrate health score into your quality gates:

```
Before any commit:
1. verify_change(...) → must have 0 broken imports
2. get_health_score → overall must not be lower than baseline -5
3. build → must pass
4. lint → must pass
5. test → must pass
```

If health score check fails:

- Do not commit
- Run `get_architecture_summary` to identify the issue
- Fix the architecture issue
- Re-run health score check

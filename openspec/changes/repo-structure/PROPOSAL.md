# Proposal: Create Initial Repository Structure for skills.sh Compatibility

## Intent

Establish the minimal repository scaffolding required for `skills.sh` to recognize and index this repository as a skills provider. Currently, the repo lacks a `README.md` and a `skills/` directory, which prevents discovery by the skills.sh CLI.

## Scope

### In Scope
- Create `README.md` with skills.sh badge and repository description
- Create empty `skills/` directory as the standard discovery path

### Out of Scope
- No SKILL.md files inside `skills/`
- No actual skill logic or implementation
- No CI/CD, testing, or tooling setup

## Capabilities

### New Capabilities
- None (no spec-level behavioral changes)

### Modified Capabilities
- None (no existing capabilities are altered)

## Approach

Minimal scaffolding: add a single markdown file and an empty directory. No build steps, no dependencies. The `skills/` directory presence alone satisfies `skills.sh` discovery conventions.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `README.md` | New | Root documentation with skills.sh badge |
| `skills/` | New | Empty directory for future skill definitions |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| None identified | — | — |

## Rollback Plan

Delete `README.md` and `skills/` directory. Working tree returns to exact pre-change state.

## Dependencies

- None

## Success Criteria

- [ ] `README.md` exists at repository root with valid skills.sh badge
- [ ] `skills/` directory exists at repository root
- [ ] `npx skills add owner/repo --list` discovers the repo (empty skills dir is acceptable)
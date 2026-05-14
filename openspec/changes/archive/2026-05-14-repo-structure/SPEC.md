# Specification: repo-structure

## Requirements

1. **README.md exists at root**
   - File path: `/home/alex_/develop/skills/README.md`
   - MUST contain valid Markdown
   - MUST include a `skills.sh` badge reflecting the repo path (`venespana/agent-skills`)
   - MUST describe the repository purpose in at least one sentence

2. **`skills/` directory exists at root**
   - Directory path: `/home/alex_/develop/skills/skills/`
   - MUST be created if absent
   - MUST remain empty (no SKILL.md files yet)

## Scenarios

### Scenario 1: Happy Path — Fresh Clone

**Given** a fresh clone of the repository
**When** the repository is indexed by `skills.sh`
**Then** `npx skills add venespana/agent-skills --list` discovers the `skills/` directory and lists it as a valid skills provider.

### Scenario 2: Edge Case — Directory Already Exists

**Given** the `skills/` directory already exists (e.g., from a prior aborted setup)
**When** the change is applied
**Then** the operation is idempotent — `skills/` is left as-is (still empty) and no error is raised.

## Acceptance Criteria

- [ ] `README.md` exists at repository root with valid markdown syntax
- [ ] `skills/` directory exists at repository root and is empty
- [ ] Badge URL in `README.md` reads exactly `https://skills.sh/b/venespana/agent-skills`
- [ ] `README.md` contains a concise description of the repository's purpose

## Files

| File / Directory | Action | Description |
|------------------|--------|-------------|
| `README.md`      | New    | Root documentation with skills.sh badge and repo description |
| `skills/`        | New    | Empty directory; the standard discovery path for skills.sh |
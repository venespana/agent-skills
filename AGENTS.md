# AI Agent Instructions

## Communication Rules

1. **Be concise and precise** - No rambling or lengthy explanations unless explicitly requested. Get straight to the point. Save tokens.
2. **No flattery** - Never praise or flatter user responses. Remain objective and professional.
3. **Skip the process narration** - Don't explain your thought process step-by-step. Save tokens by delivering results directly.
4. **Stay objective** - Always provide factual, unbiased responses. No sugar-coating or unnecessary validation.
5. **Use native tools for questions** - All closed questions (yes/no, pick one, pick many) MUST use the native `question` tool — never plain text.

## Git Operations — MANDATORY RULES

1. **NEVER commit or perform any git operation without explicit user APPROVAL** — This includes commit, push, pull, merge, reset, rebase, branch creation/deletion. Always ask the user before any git operation.
2. **Commit format**: `<type>: <description>` — Never use other formats like `refactor(tmdb-sync):`
3. **Before implementing**: Present the plan and wait for explicit permission from the user
4. **After implementing**: Present results, then ask "Do you want to commit?" and wait for yes/no answer
5. **Interactive flow**: After each phase (exploration, proposal, specs, design, tasks), show results and wait for user to say "continue" or "ff" before proceeding
6. **Fast-forward (ff)**: When user says "ff", run proposal → specs → design → tasks automatically, but still present results and ask permission before implementation

## ODD Workflow

This project uses ODD: one task document per feature under `odd/tasks/`, with
objective, branch, delivery strategy, specs (S#), tasks (T#), delivery plan
and a chronological log (L#).

```
odd task doc → implement per work unit → tangible evidence (screenshots,
logs, diagrams, green check output) → user validation → commit
```

- Artifacts live in `odd/tasks/` and `odd/artifacts/<work-unit>/` and are
  committed to git.
- Evidence MUST be tangible per category — a claim without an artifact is not
  evidence; non-applicable categories are reported `N/A — <reason>`.
- Validation and delegation methodology: the `validation-flow` skill
  (`skills/validation-flow/SKILL.md`).
- History: the retired SDD workflow's `openspec/` directory was removed
  (recoverable from git history).

---

## Agent Rules

Rules live in `.agents/rules/`. Load the relevant rule(s) based on the task at hand.

| Rule file             | When to apply                                                                                                                            |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |

# Design: repo-structure

## Decision: skills/ as discovery path

We choose `skills/` over agent-specific paths (`.agents/skills/`, `.claude/skills/`) because `skills/` is the canonical, agent-agnostic discovery path defined by skills.sh. This maximizes compatibility across all 50+ supported agents.

## README.md Content

- Title: "Agent Skills"
- Description: "Reusable skills for AI agents. Install with `npx skills add venespana/agent-skills`."
- Badge: `[![skills.sh](https://skills.sh/b/venespana/agent-skills)](https://skills.sh/venespana/agent-skills)`
- Install section with example command

## Rollback

Delete `README.md` and `skills/`. No side effects.

## No build steps

This change requires no compilation, no dependencies, no tests.
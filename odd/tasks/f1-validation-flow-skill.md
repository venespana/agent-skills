# F1 — Validation flow skill (project-independent)

Publish a reusable skill that encodes risk-tiered validation and delegation for
agentic development, with no dependency on any specific project: the skill
carries the doctrine, each project instantiates it. The companion command
`/evidencia` ships with the skill as a supporting asset.

- **Branch**: `feat/validation-flow-skill` (from `develop`) — created only with user approval.
- **Delivery**: work-unit commits AFTER user validation (standing rule). NO push without the user.
- **Test runner**: none (markdown-only change). Checks: frontmatter parse, independence grep, command parse, README consistency.
- **Evidence**: tangible artifacts required, not descriptions — see S12. For this work unit: diagram of the three-piece architecture + the raw output of every check (see T8).
- **Workflow**: ODD — this repo's `AGENTS.md` still prescribes an SDD workflow with `openspec/`; that section is stale (see T7 + Log L2).

## Specs

- **S1** (user request, verbatim): «recuerda no usamos sdd sino odd» — artifacts live in `odd/tasks/`, not in `openspec/changes/`.
- **S2** (user request, verbatim): «la idea es crear la skill sin necesidad de tener dependencias de ningun proyect» — the skill MUST NOT reference any repository, framework, service or absolute local path; independence is verified by grep, not by review opinion.
- **S3** (cross-agent review, 2026-11-20): three pieces, one job each — the per-project AGENTS.md block is the always-on guarantee (deterministic: always in context); the `/evidencia` command is the formal delivery ritual (deterministic: on demand); the skill is the portable doctrine (bonus depth only — trigger matching is probabilistic and MUST NOT carry a guarantee).
- **S4** Skill layout (repo convention, skills.sh): `skills/validation-flow/SKILL.md`. Frontmatter MUST include `name`, a `description` starting with `Trigger:`, `license: Apache-2.0`, `metadata.author: venespana`, `metadata.version`. Body sections: `Activation Contract` then `Hard Rules` — same shape as the repo's other skills.
- **S5** Supporting assets shipped inside the skill (user decision 2026-11-20: a slash command adds no value over the invocable skill — dropped): `scripts/collect-evidence.sh` (generic collector: diff, status, detected check suite; never commits), `assets/evidence-report.md` (the ordered response template) and `references/evidence-standard.md` (per-category artifact rules, the `N/A` rule, persistence and citation).
- **S6** Doctrine content (MUST): tier framework A/B/C as framework, with assignments declared per-project data; acceptance criteria standard (Given/When/Then, observable, ~30s verifiable); evidence package format — with tangible artifacts per category (see S12); trust ladder (3 consecutive green work units promote tier-B to agent-commit-with-evidence; any miss resets); the 4 diff questions (trust boundary · secrets · data-loss paths · previously working behavior); delegation map (delegate freely / with checkpoint / retain); integration principle (doubles for iteration, ONE final real acceptance).
- **S7** Graceful degradation: a project without a policy gets the defaults applied and the absence reported; a missing command means the evidence package is assembled manually. Never fail hard.
- **S8** Install (optional, user-approved, outside the repo): skill → `~/.config/opencode/skills/validation-flow/`; command → `~/.config/opencode/commands/evidencia.md`. The doctrine applies even without installing.
- **S9** `README.md`: list `validation-flow` among the available skills and drop the stale "No skills available yet" claim.
- **S10** Independence check (mechanical): grep the skill body for repository names, framework names and absolute home paths — expect zero hits.
- **S11** Out of scope: any consumer-repository change (e.g. the thin AGENTS.md block for the freelance-dashboard repo). That block is an instantiation of this doctrine, never a dependency of it.
- **S12** (user request, verbatim): «importante los artefactos que se deben generar debe ser tangibles tanto como captura de pantallas, logs de la aplicacion y diagramas donde se demuestre que esta todo realizado ademas de demostrar qu elos test pasan en verde» — the evidence package MUST carry tangible artifacts, not descriptions: screenshots, application logs, diagrams, and the proof that the suite passes green. Per-category rules: UI change → screenshots of the affected flows; runtime behavior → the application logs of the exercised window; structural change → a diagram (sequence, flow or state) showing the result; ALWAYS the raw green output of the checks. A claim without an artifact is not evidence. A category that does not apply MUST be reported as `N/A — <reason>`, never omitted silently. Artifacts MUST be persisted in the project (e.g. `odd/artifacts/<work-unit>/`) and cited by path from the Log entry, so a later reader can re-verify without re-running anything.

## Tasks

- **T1** (S1, S2, S4, S6, S12) `skills/validation-flow/SKILL.md` created — frontmatter per repo convention, doctrine per S6 including the per-category artifact rules, install steps per S8 — DONE (91 lines; frontmatter YAML-parsed OK, see `odd/artifacts/f1/checks.log` § T4/T4c)
- **T2** (S5, S12) `skills/validation-flow/commands/evidencia.md` created — MUST also collect the tangible artifacts (logs, screenshots, diagram reference) and the green check output — SUPERSEDED (Log L8: command dropped by user decision) → replaced by T9/T10/T11
- **T9** (S5) `scripts/collect-evidence.sh` — generic collector (diff, status, detected check suite; `bash -n` OK, executable, never commits) — DONE (`checks.log` § RESTRUCTURE v1.2)
- **T10** (S5, S12) `assets/evidence-report.md` (ordered template) + `references/evidence-standard.md` (per-category rules, `N/A` rule, persistence) — DONE
- **T11** (S5) `commands/evidencia.md` removed — DONE
- **T3** (S10) independence grep over the skill body — zero hits — DONE (`grep exit=1`; `checks.log` § T3; sanctioned mentions limited to S8 install targets, § T3b)
- **T4** (S4, S5) frontmatter parse of SKILL.md and of the command file — DONE (structural + real YAML parse via python3/pyyaml: `validation-flow v1.0`; `checks.log` § T4/T4b/T4c)
- **T5** (S9) `README.md` lists `validation-flow`; stale claim removed — DONE (Available Skills table now lists all 6 skills; the stale claim covered them all)
- **T6** (S8) install copies in `~/.config/opencode/` and `/evidencia` visible in the command list — PENDING (needs user approval; outside the repo)
- **T7** (S1) `AGENTS.md` SDD section reconciled with ODD — DONE (2026-11-20, user decision «Si migramos sdd a odd»: the SDD Workflow section is now the ODD Workflow; `openspec/` marked legacy, removal pending user approval)
- **T8** (S12) tangible artifacts of this work unit in `odd/artifacts/f1/`: diagram of the three-piece architecture (skill → project instantiation → evidence package) + the raw output of every check (frontmatter parse, independence grep, command parse) — cited from the Log — DONE: `odd/artifacts/f1/architecture.md` (three-piece flowchart + delivery-ritual sequence), `odd/artifacts/f1/checks.log` (raw output), `odd/artifacts/f1/evidence.md` (the package: Diff/Checks/Risk/Evidence with `N/A` notes)

## Delivery

One branch, one PR: `develop` ← `feat/validation-flow-skill`. The install
(T6) is not a repo change. Commit only after user validation.

| PR | Base ← Head | Scope | Size |
|----|-------------|-------|------|
| — | `develop` ← `feat/validation-flow-skill` | Skill + supporting assets + README + artifacts | ~280 lines |

## Log

- **L1** (2026-11-20) Plan carried over from the freelance-dashboard thread (v3, post cross-agent review). Conceded: an auto-triggered skill fires probabilistically, so it cannot be the "always" guarantee — the per-project AGENTS.md line can. Rejected the review's final verdict (drop the skill entirely): it loses cross-project reuse, which was the original requirement.
- **L2** (2026-11-20, user) «recuerda no usamos sdd sino odd» → the SDD/openspec draft is replaced by this ODD doc. This repo's `AGENTS.md` still prescribes an SDD workflow with `openspec/`, while `openspec/changes/` holds only an archived 2026-05-14 change and the rules table is empty — the repo rules look stale against the actual workflow. Correcting them is T7 and needs an explicit decision (what to do with the `openspec/` directory is part of it).
- **L3** (2026-11-20, user) «importante los artefactos que se deben generar debe ser tangibles tanto como captura de pantallas, logs de la aplicacion y diagramas donde se demuestre que esta todo realizado ademas de demostrar qu elos test pasan en verde» → evidence standard hardened: S12 added (tangible artifacts per category, green check output always, `N/A — <reason>` instead of silence, artifacts persisted and cited by path), S6 amended, T2 extended to collect artifacts, T8 added for this work unit's own artifacts (diagram + raw check output).
- **L4** (2026-11-20) T1–T5 + T8 executed and verified GREEN. Evidence: `odd/artifacts/f1/evidence.md` (the package: Diff / Checks / Risk / Evidence), `odd/artifacts/f1/checks.log` (raw output: independence grep 0 hits `exit=1`; frontmatter YAML parse OK `validation-flow v1.0`; command frontmatter + shell block + no-commit marker), `odd/artifacts/f1/architecture.md` (mermaid: three-piece flowchart + delivery-ritual sequence). `N/A` notes: screenshots (no UI in this repo) and app logs (no runtime exercised) — per S12, stated with reason, not omitted. Pending: T6 (install — user approval), T7 (AGENTS.md SDD↔ODD — user decision).
- **L5** (2026-11-20, user request) `skill-improver` audit applied to `SKILL.md` (style contract: bundled `references/skill-style-guide.md` — no `docs/` guide in this repo). Findings → fixes: missing required sections (Decision Gates, Execution Steps, Output Contract, References) → added, now in the required order; `description` 253 chars (over the 250 hard max) → 205; body ~800 est. tokens (over the 700 recommended max) → ~739 after collapsing repeated ladder rules into Hard Rule 5 and trimming prose — within the 1000 hard max, documented. `version` 1.0 → 1.1. Post-apply checks GREEN (appended to `checks.log`: independence grep 0 hits; YAML parse v1.1; 7 sections in order). Side effect disclosed: `gentle-ai skill-registry refresh` (24 skills indexed) also modified `.gitignore` (now ignores `.atl/` entirely — kept, matches the standing no-`.atl`-to-remote practice). Registry refreshed: `.atl/skill-registry.md`.
- **L6** (2026-11-20, user decision) «Si migramos sdd a odd» → T7 executed: `AGENTS.md` SDD Workflow section replaced by the ODD Workflow (task docs in `odd/tasks/`, tangible evidence, `validation-flow` skill as the methodology, `openspec/` marked legacy with removal pending approval).
- **L7** (2026-11-20, user approvals) `openspec/` removed (11 files — recoverable from git history; AGENTS.md now notes the removal); T6 install declined for now (stays PENDING); commit declined for now (everything stays in the working tree).
- **L8** (2026-11-20, user) «para que es el comando evidencia ? no lo veo util ya que tenemos la eskill que se puede invocar lo que si es util que añadas los scripts necesarios para la stareas que puede hacer de forma generica y las referencias y templates de respuesta para que se entrege siempre la respuesta ordenada y logica» → S5 rewritten: the `/evidencia` command is dropped; the kit gains `scripts/collect-evidence.sh` (generic collector), `assets/evidence-report.md` (ordered template) and `references/evidence-standard.md` (per-category rules). T2 superseded by T9/T10/T11. Side effect: SKILL.md body dropped to ~691 est. tokens (under the 700 recommended max); architecture.md diagram updated; all checks GREEN (see `checks.log` § RESTRUCTURE v1.2).
- **L9** (2026-11-20, user approval) Committed on `develop` (no branch — user said "genera comit" without requesting the feature branch; the branch/PR flow of the Delivery plan can still be done later): `bee1450` feat (skill + assets + scripts + README + .gitignore side effect), `1e20ad0` docs (AGENTS.md SDD→ODD + openspec/ removal), `474c5c5` docs (ODD doc + artifacts). Working tree clean. Not pushed. T6 install still pending user approval.

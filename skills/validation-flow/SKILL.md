---
name: validation-flow
description: "Trigger: setting validation tiers or commit gates, delegating to agents, assembling or reviewing a work-unit evidence package, reviewing agent-authored code. Risk-tiered validation and delegation doctrine."
license: Apache-2.0
disable-model-invocation: true
metadata:
  author: venespana
  version: "1.3"
  opencode/autoinvoke: false
---

# Validation Flow

Risk-tiered validation and delegation for agentic development. Tier
assignments are per-project data, never assumed.

## Activation Contract

Load when: a project lacks validation tiers; deciding what an agent may do
alone versus with a human verdict; assembling or reviewing a work-unit
evidence package; reviewing agent-authored code.

## Hard Rules

1. The human designs verification and owns priorities, acceptance criteria
   and the verdict; the agent executes and delivers evidence.
2. Tier A — agent may commit on green checks (reversible work, fast
   feedback). Tier B — human verdict per unit (product judgment,
   hard-to-reverse state). Tier C — human verdict on real assets (security,
   real external effects, destructive operations).
3. Acceptance criteria are observable: Given/When/Then, one check per
   criterion, verifiable in ~30 seconds. GREEN per criteria means done.
4. Evidence is tangible: artifacts persisted in the project and cited by
   path. A claim without an artifact is not evidence. Non-applicable
   categories are reported `N/A — <reason>`, never omitted.
5. Graduated autonomy: three consecutive green work units promote tier-B to
   agent-commit-with-evidence; any miss resets the counter.
6. Review four things, not every line: trust boundary · secrets · data-loss
   paths · previously working behavior.
7. Delegate freely what has automated feedback and reversibility; checkpoint
   human-designed invariants; retain priorities, acceptance criteria,
   real-asset validation.
8. Integrations: doubles for iteration, ONE final real acceptance. Doubles
   lie about quotas, rate limits and odd payloads.
9. A missing policy is reported, not assumed: apply these defaults and say
   so in the work-unit report.

## Decision Gates

| Situation | Action |
|-----------|--------|
| Project defines no tiers | Apply the defaults above; state it in the report |
| Tier-B/C surface touched | Human verdict before commit; never self-approve |
| Evidence category not applicable | Report `N/A — <reason>`; never omit silently |
| Evidence assembly needed | Run `scripts/collect-evidence.sh <slug>`; fill `assets/evidence-report.md` |
| Three green units, no miss | Promote tier-B items to commit-with-evidence |

## Execution Steps

1. Read the project's validation policy (agent instructions); missing → apply
   defaults and report it.
2. Assign each surface's tier; confirm tier-B/C with the human if unclear.
3. Implement with the full check suite green.
4. Run `scripts/collect-evidence.sh <slug>`; capture the remaining artifacts
   per category (`references/evidence-standard.md`) next to the collected
   ones.
5. Fill `assets/evidence-report.md` with the collected content and paths.
6. Deliver the report and wait for the verdict. Never commit without it.

## Output Contract

Return the report in `assets/evidence-report.md` order: `Diff` (files,
counts) · `Checks` (results + test counts total/new/changed, raw green
output) · `Risk` (tier-B/C surfaces, or "none") · `Evidence` (artifact paths).
Category artifact rules: `references/evidence-standard.md`.

## Install (optional)

Copy this directory to `~/.config/opencode/skills/validation-flow/`. The
doctrine applies without installing.

## References

- `scripts/collect-evidence.sh` — generic collector: diff, status, detected
  check suite.
- `assets/evidence-report.md` — the ordered report template: fill it, deliver
  it.
- `references/evidence-standard.md` — per-category artifact rules, the `N/A`
  rule, persistence and citation.

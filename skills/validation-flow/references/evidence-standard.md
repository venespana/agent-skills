# Evidence standard — detailed rules

Normative companion to `SKILL.md` Hard Rule 4. A claim without an artifact is
not evidence.

## Per-category artifacts

| Category (change type) | Required artifact | Minimum quality bar |
|------------------------|-------------------|---------------------|
| Always | Raw green output of the full check suite | Every check's result + test counts (total / new / changed); the output itself, not a summary of it |
| UI or flow change | Screenshots of the affected flows | State visible (the effect must be readable in the image); before/after when the change alters an existing flow |
| Runtime behavior | Application logs of the exercised window | Timestamps and levels included; window covers the exercised path, not the whole session |
| Structural change | Diagram (sequence, flow or state) | Shows the result, not the intention; mermaid in the repo's diagram format is acceptable |

## The N/A rule

A category that does not apply is reported as `N/A — <reason>` in the
evidence table — never omitted silently. Examples:

- `Screenshots: N/A — markdown-only change, no UI surface exists`
- `Logs: N/A — no runtime exercised; the change ships files`

## Persistence and citation

- Persist artifacts where the project keeps evidence (ODD projects:
  `odd/artifacts/<work-unit-slug>/`; otherwise `artifacts/<slug>/`).
- Cite every artifact by repository-relative path from the work-unit log, so
  a later reader can re-verify without re-running anything.
- `scripts/collect-evidence.sh` creates the directory and collects diff,
  status and the detected check suite; the agent adds the category artifacts
  next to them and fills `assets/evidence-report.md`.

## What is NOT evidence

- "All checks pass" without the output.
- A screenshot of the code editor instead of the running behavior.
- Logs from an unrelated window.
- Descriptions of what the diagram would show, without the diagram.

# F1 — Architecture: the validation-flow kit

One job per piece. No guarantee rests on skill trigger matching.

```mermaid
flowchart LR
    subgraph REPO["skills repo (source of truth, versioned)"]
        KIT["skills/validation-flow/<br/>SKILL.md (doctrine) · scripts/collect-evidence.sh<br/>assets/evidence-report.md · references/evidence-standard.md"]
    end

    subgraph CFG["~/.config/opencode (install target)"]
        IS["skills/validation-flow/<br/>loaded by the agent"]
    end

    subgraph PROJ["any consumer project"]
        AG["AGENTS.md thin block<br/>tier assignments A/B/C<br/>(the always-on guarantee)"]
        WU["work unit<br/>implementation + green checks"]
        EV["odd/artifacts/&lt;slug&gt;/<br/>screenshots · logs · diagram · green output"]
    end

    KIT -- install --> IS
    KIT -. instantiates .-> AG
    AG -- gates --> WU
    WU -- runs script --> EV
    IS -- script + template --> EV
```

## Delivery ritual (deterministic, in-skill)

```mermaid
sequenceDiagram
    participant A as Agent
    participant S as collect-evidence.sh
    participant H as Human
    A->>A: implement work unit + checks green
    A->>S: scripts/collect-evidence.sh <slug>
    S->>A: diff + status + detected check-suite output
    A->>A: capture remaining artifacts (screenshots / logs / diagram)
    A->>A: fill assets/evidence-report.md
    A->>H: report (Diff / Checks / Risk / Evidence)
    H->>A: verdict — approve → commit, reject → fix
```

Key properties:

- **AGENTS.md block** = the guarantee (in context every session, no invocation needed).
- **The kit** = the ritual: generic script collects, template orders, references specify quality bars — the report is always delivered in the same logical order.
- **Skill trigger matching** = bonus depth only.
- Independence: no repository, framework or absolute home path anywhere in the kit — verified by grep over the whole directory (`checks.log`, T3).

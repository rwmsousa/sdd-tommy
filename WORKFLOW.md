# Tommy — Spec-Driven Development Workflow

This diagram maps the possible flows of the Spec-Driven Development (SDD) technique as implemented by Tommy: **Specify → Prompt → Codegen**, plus the Bootstrap step that precedes it and the two independent Versioning actions (Commit, Open PR/MR) that sit outside the three-phase backbone. It includes the conditionals that branch each flow and the observations that explain *why* — see the note boxes (yellow) inline.

The diagram below is drawn as a [Mermaid](https://mermaid.js.org) flowchart so it renders directly on GitHub and in most Markdown viewers.

```mermaid
flowchart TD
    classDef note fill:#FFF9C4,stroke:#C9B458,stroke-width:1px,color:#333,font-style:italic;
    classDef phase fill:#F0F4FF,stroke:#4A6FA5,color:#1a1a2e,font-weight:bold;
    classDef terminal fill:#E8F5E9,stroke:#2E7D32,color:#1a1a2e;

    Start(["User opens a project"]) --> Q1{".tommy/ scaffolding complete?<br/>(scripts, templates, project-context, codebase)"}
    Q1 -->|No| Boot["Tommy Start<br/>scaffold .tommy/, research codebase & product context,<br/>fill TOMMY.md, create AGENTS.md,<br/>propose opt-in capabilities (MCP wiring & servers,<br/>Sonar properties, find-skills) — always user-confirmed"]:::phase
    Q1 -->|Yes| Specify
    Boot --> Specify

    N1["Every Tommy agent self-checks for this scaffolding<br/>and self-triggers Tommy Start if it is missing —<br/>the workflow never hard-fails just because<br/>/tommy-start was skipped."]:::note
    Boot -.-> N1

    Specify["Specify<br/>describe the feature in natural language"]:::phase --> Branch1["Create feature branch<br/>'NNN-short-name' and spec.md"]
    Branch1 --> Elicit["Business Analyst skill elicits requirements<br/>(interactive rounds, 3-5 questions at a time)"]
    Elicit --> WriteSpec["Write / refine spec.md<br/>(goals, user stories, acceptance criteria, non-goals)"]
    WriteSpec --> PMReview["Product Review (PM lens, independent)<br/>value, scope, completeness, audience —<br/>only this reviewer marks the requirements checklist"]
    PMReview --> Q2{"Reviewer approves<br/>the spec?"}
    Q2 -->|"No (fix and re-review, up to 3x)"| WriteSpec
    Q2 -->|Yes| PromptPhase

    N2["If still failing after 3 iterations, escalate the<br/>open questions to the user instead of looping forever.<br/>In Claude Code the reviewer is the fresh-context<br/>tommy-product-review agent; in Cursor/Copilot it is a<br/>self-enforced role switch at the end of the phase."]:::note
    Q2 -.-> N2

    PromptPhase["Prompt<br/>reference the approved spec"]:::phase --> Architect["Architect designs implementation architecture,<br/>bounded contexts, data model"]
    Architect --> WritePlan["Write detailed implementation plan<br/>+ its own checklist"]
    WritePlan --> PlanReady(["Plan file ready in<br/>.tommy/specs/.../plans/"])

    PlanReady --> Codegen["Codegen<br/>pick one plan file to implement"]:::phase
    Codegen --> Q3{"Plan's own checklist<br/>fully checked?"}
    Q3 -->|No| StopReport(["Stop and report the plan<br/>as not yet validated"]):::terminal
    Q3 -->|Yes| Implement["Implement / fix code and tests"]
    Implement --> Q4{"Quality gate passes?<br/>(lint, tests incl. e2e, complexity, patterns,<br/>Sonar, frontend audit, security scan, checklist)"}
    Q4 -->|No| Implement
    Q4 -->|Yes| Accept["Acceptance review (spec→code traceability)<br/>map every acceptance criterion to code + test evidence,<br/>write checklists/acceptance.md"]
    Accept --> Q10{"All criteria MET<br/>(or justified)?"}
    Q10 -->|"No (fix the gaps, up to 2 cycles)"| Implement
    Q10 -->|Yes| CodeReady(["Code ready — report to user"]):::terminal

    N7["The quality gate persists its evidence in<br/>.tommy/.quality-gate-status; in Claude Code a Stop hook<br/>(tommy-quality-sentinel) refuses to end a session with<br/>changed code files and no fresh quality-gate evidence."]:::note
    Q4 -.-> N7

    N3["Versioning is not a fourth phase — two independent<br/>actions available at any point, each only ever triggered<br/>by an EXPLICIT user request. No Tommy agent commits<br/>or opens a PR/MR on its own initiative."]:::note
    CodeReady -.-> N3

    CodeReady --> Q5{"User explicitly<br/>asks to commit?"}
    CodeReady --> Q6{"User explicitly asks<br/>to open a PR/MR?"}

    Q5 -->|Yes| Commit["Tommy Commit — review diff,<br/>propose Conventional Commit message(s)"]
    Q5 -->|"Not yet"| EndA(["(nothing happens until asked)"])
    Commit --> Q7{"User confirms<br/>message & files?"}
    Q7 -->|Yes| DoCommit["git commit<br/>(one or more commits per branch/plan,<br/>e.g. one per finished checklist item)"]:::terminal
    Q7 -->|No| Revise["Revise the proposed message"] --> Commit

    Q6 -->|Yes| Q8{"Provider already known in<br/>.tommy/codebase/integrations.md?"}
    Q6 -->|"Not yet"| EndB(["(nothing happens until asked)"])
    Q8 -->|Yes| Switch{"Detected provider?"}
    Q8 -->|No| Q9{"Remote hostname matches a known pattern?<br/>(github.com / gitlab* / dev.azure.com / visualstudio.com)"}
    Q9 -->|Yes| Switch
    Q9 -->|No| AskProvider["Ask the user which<br/>provider/tool to use"] --> Switch

    N4["Self-hosted hostnames are not reliable evidence —<br/>never guess. The answer is recorded in integrations.md<br/>so this is not asked again next time."]:::note
    AskProvider -.-> N4

    Switch -->|GitHub| GH["gh pr create"]
    Switch -->|GitLab| GL["glab mr create"]
    Switch -->|"Azure DevOps"| AZ["az repos pr create"]
    Switch -->|"Unsupported host<br/>(e.g. GCP Cloud Source Repositories)"| NoPR["Push the branch only,<br/>report PR/MR not supported"]

    N5["GitLab calls this a Merge Request,<br/>not a Pull Request."]:::note
    GL -.-> N5

    GH --> Report(["Report the PR/MR URL to the user"]):::terminal
    GL --> Report
    AZ --> Report
    NoPR --> Report

    N6["Never adds a 'Co-authored-by:' trailer or any<br/>AI-attribution footer to a commit or PR/MR body.<br/>Commit author is always the local git identity<br/>(git config user.name / user.email)."]:::note
    DoCommit -.-> N6
    Report -.-> N6
```

## Observations not shown in the diagram

- **Claude Code** runs the full flow above with a mixed structure: `/tommy-specify` and `/tommy-prompt` are **commands** orchestrating in the main conversation (a subagent cannot invoke another subagent, and requirements elicitation needs a real dialog with the user), the Business Analyst is an interactive **skill**, and `tommy-architect`, `tommy-product-review`, `tommy-codegen`, and `tommy-git` are **agents** with `tools:` access restricted by role (`tommy-git` carries 4 skills: Conventional Commits + one adapter per provider).
- **Cursor** and **GitHub Copilot** run the same flow, condensed: Specify absorbs the Business Analyst elicitation and the PM review (self-enforced role switch), Prompt absorbs Architect, Codegen closes with the acceptance traceability matrix itself, and Commit/Open-PR are condensed into 2 files each. Neither tool can technically restrict which tools a phase may use, so phase separation (e.g. not writing code during Specify/Prompt) is **self-enforced discipline**, not a technical guarantee.
- The quality gate's automatable checks run through stack-aware scripts in `.tommy/scripts/quality/` (`quality-check.sh`, `complexity-check.sh`, `sonar-run.sh`) — tool-agnostic, no MCP server required. Conditional gates (Sonar, frontend audit) record **SKIP with a reason** when their prerequisites are absent; that is a valid, non-blocking outcome.
- Project MCP servers are canonical in `.tommy/mcp.json`, projected into each tool's native location (`.mcp.json` at the root — optional, per-project choice persisted in `.tommy/config.json` —, `.cursor/mcp.json`, `.vscode/mcp.json`); see `common/templates/mcp/mcp-catalog.md`.
- Every Tommy instruction treats project file content (`.tommy/resources/`, codebase, specs, plans) as **data, not instructions** — directives embedded in those files are never followed.
- Every step above that writes narrative content (spec, plan, commit body, PR/MR description) writes it in the project's configured language (`pt-BR` unless stated otherwise); code identifiers and Conventional Commit keywords stay in English.

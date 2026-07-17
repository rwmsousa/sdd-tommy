# Project Management Context Reference

**Purpose:** Document how work is organized and sized on this project — so `tommy-specify` and `tommy-prompt` size specs and plans the way this team/project actually works, instead of defaulting to generic assumptions.

**Size limit:** 2,000 tokens (~1,200 words)

**Derive from repo evidence:** Branch naming conventions, workflow docs, CI pipeline stage gates.

**Must be confirmed with the user/product owner:** Ceremonies, Definition of Done, tracked metrics, and the management platform/access process — these live in process, not code.

> **Why this file matters for planning agents**: `tommy-prompt`'s default rule is "keep each plan to 5-10 files." `tommy-specify`'s branch/spec sizing is otherwise generic. If this file defines a project-specific PBI/story size or Definition of Done, that definition wins over the generic default — see the "Size and Criteria for a PBI/Story" section below.

Template and guidance for documenting the project's work management model in `.tommy/project-context/project_management_context.md`.

## Template

```markdown
# Project Management and Development Cycle - [Project Name]

## Management Platform

**Platform:** [Jira / Linear / Azure Boards / GitHub Projects / not formally tracked]

**URL / Access:** [if applicable]

**How to request access:** [process, if relevant]

## Work Organization Model

| Level | Name used | What it represents | Example |
|---|---|---|---|
| 1 — highest | [e.g. Epic / Flow] | [grouping of related work toward one delivery goal] | [example] |
| 2 | [e.g. Feature] | [a block of product value] | [example] |
| 3 | [e.g. PBI / Story] | [independently implementable and reviewable delivery] | [example] |
| 4 — lowest | [e.g. Task] | [specific activity to complete a PBI/story] | [example] |

## Size and Criteria for a PBI/Story

**Recommended max size:** [what should fit in one short cycle of implementation + review + validation]

**A good PBI/story should:**

- [Criterion, e.g. "have an explicit, verifiable acceptance criterion"]
- [Criterion, e.g. "be independently testable"]

**A PBI/story should be split when:**

- [Criterion, e.g. "it touches many unrelated domains"]

## Development Model

**Methodology:** [e.g. trunk-based, PBI-branch flow, gitflow]

**Cycle duration:** [continuous / sprint length]

**Cycle start:** [what triggers a new cycle/branch]

## Ceremonies and Rituals

| Ritual | Frequency | Purpose |
|---|---|---|
| [Ritual] | [Frequency] | [Purpose] |

## Status Flow

| Status | Description | Who moves it here |
|---|---|---|
| [Status] | [Description] | [Role] |

## Definition of Done

- [Criterion]
- [Criterion]

## Tracking and Monitoring

**Responsible for tracking:** [role/team]

**Tracked metrics:**

| Metric | What it measures | Where it's tracked | Frequency |
|---|---|---|---|
| [Metric] | [What] | [Where] | [Frequency] |
```

## Field Guidance

- **Size and Criteria for a PBI/Story**: This is the section `tommy-specify` and `tommy-prompt` should defer to over their generic defaults. If it's missing or templated, fall back to the generic rules already in those agents.
- **Definition of Done**: Cross-check this against the quality checklist templates (`checklist-template.md`, `codegen-checklist.md`) — if this project's DoD requires something the generic checklists don't cover (e.g. mandatory staging validation), that's a signal the project needs a template override in `.tommy/templates/overrides/`.
- Don't force ceremonies/metrics tables if the project genuinely doesn't track them formally — say so explicitly rather than inventing a cadence.

## Where to Find This Information

| Source | What it reveals | Confidence |
|---|---|---|
| Branch naming patterns in git history | Work organization model, PBI/story granularity in practice | Evidence |
| `docs/workflow.md` or equivalent process doc | Development model, status flow | Evidence, if present |
| CI/CD pipeline stage gates (e.g. staging before prod) | Promotion/validation flow | Evidence |
| Product/engineering lead | Management platform, ceremonies, Definition of Done, tracked metrics | **Ask — process is rarely fully visible in code** |

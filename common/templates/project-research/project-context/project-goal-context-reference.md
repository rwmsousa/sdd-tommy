# Project Goal Context Reference

**Purpose:** Document what the system is, the problem it solves, and who it's for.

**Size limit:** 2,500 tokens (~1,500 words)

**Derive from repo evidence:** System name, repository name, environment URLs, dependency-implied domain hints.

**Must be confirmed with the user/product owner:** Problem statement, root cause, business objective, target market, stakeholders, macro/negative scope priorities. Do not infer these from code — ask.

Template and guidance for documenting the project's goal and business context in `.tommy/project-context/project_goal_context.md`.

## Template

```markdown
# Project Goal - [Project Name]

## System Identification

**System name:** [Project Name]

**Status:** [In production / MVP / Pre-launch / Internal tool]

**Repository:** [repo name]

**Last updated:** [DATE]

### Environments

| Environment | URL |
|---|---|
| Development | [url] |
| Staging | [url] |
| Production | [url] |

## Problem to Solve

**Current situation:** [What pain point or gap exists today — NEEDS CONFIRMATION if not documented anywhere]

**Root cause:** [Why the problem exists — NEEDS CONFIRMATION]

**Impact:** [Cost of not solving it — rework, errors, lost time, lost revenue — NEEDS CONFIRMATION]

## Project Objective

**Where this project should get to:**

- [Outcome 1]
- [Outcome 2]
- [Outcome 3]

## System Overview

### Purpose

[2-4 sentences: what the system does and the value it delivers, in plain language]

### Target Audience and Users

**Profile 1 — [Role name]**
[Responsibilities and what this user does in the system]

**Profile 2 — [Role name]**
[Responsibilities and what this user does in the system]

[Add one block per distinct user profile/role]

### Market Context and Positioning

**Market context:** [What category of product/market this competes in — NEEDS CONFIRMATION]

**Positioning:** [What makes this product's approach distinct — NEEDS CONFIRMATION]

**Target market:** [Who buys/adopts this — NEEDS CONFIRMATION]

### Customer Usage Context

[How the customer actually uses the system day to day — which systems it integrates with, what the operational rhythm looks like]

## Business Context

**About the business:** [1-2 sentences on the business this system serves]

**Domain and segment:** [Industry/domain]

**Current process (how it's done today without this system):** [NEEDS CONFIRMATION if not documented]

**Relevant business constraints/rules:** [Compliance, multi-tenancy, localization, auth requirements, etc.]

## Macro Scope of the Project

| # | Module / Epic | Priority |
|---|---|---|
| 1 | [Module name] | [High/Medium/Low] |
| 2 | [Module name] | [High/Medium/Low] |

## Negative Scope of the Project

| What will NOT be done | Reason |
|---|---|
| [Excluded item] | [Why it's excluded] |

## Stakeholders

| Name | Company / Area | Role in the Project |
|---|---|---|
| [Name/Team] | [Area] | [Role] |
```

## Field Guidance

- **Status**: Be honest about maturity — this shapes how conservative `tommy-architect` should be about breaking changes.
- **Problem to Solve**: This is the single most important section for `tommy-business-analyst` — a feature request only makes sense in light of the problem it serves. If this section is templated placeholders, treat the whole file as a GAP.
- **Macro Scope**: Keep this at module/epic granularity, not feature granularity — that level of detail belongs in `scope_features_context.md`.
- **Stakeholders**: List roles/teams, not necessarily individual names, if the project doesn't track that.

## Where to Find This Information

| Source | What it reveals | Confidence |
|---|---|---|
| `package.json` description, `README.md` | System name, one-line purpose | Evidence |
| Environment config files, CI/CD variables | Environment URLs | Evidence |
| `docs/`, ADRs, product wiki links in the repo | Problem statement, objective (if documented) | Evidence, if present |
| UI copy, i18n files, route names | Hints about user-facing features and terminology | Weak evidence — confirm before trusting |
| Product owner / tech lead / user | Problem statement, root cause, impact, business objective, market context, stakeholders, scope priorities | **Ask — do not guess** |

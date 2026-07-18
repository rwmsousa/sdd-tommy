# Tech Restrictions Context Reference

**Purpose:** Record hard technical constraints — forbidden technologies, environment restrictions, compliance requirements, and decisions the team has explicitly chosen not to revert. This is the one project-context file with binding rules, not narrative.

**Size limit:** 2,000 tokens (~1,200 words)

**Derive from repo evidence:** Circumstantial signals only (a pattern used consistently everywhere is a *hint* of a decision, not proof of one).

**Must be confirmed with the user/product owner:** Every row in this file, in principle. A restriction stated here without a real decision behind it is worse than no restriction at all — it will block `tommy-architect` and `tommy-codegen` from proposing things that were actually fine.

> This directly supports `tommy-architect`'s rule "Never invent architecture constraints without checking workspace/resources first" and `tommy-codegen`'s "Never assume technology stack or architecture" — this file is where a checked, confirmed constraint gets recorded so it stops needing to be re-litigated on every feature.

Template and guidance for documenting binding technical restrictions in `.tommy/project-context/tech_restrictions_context.md`.

## Template

```markdown
# Technical Restrictions and Decisions - [Project Name]

## Forbidden Technologies

| What NOT to use | Reason | Recommended alternative |
|---|---|---|
| [Technology/pattern] | [Why it's forbidden — real incident, architectural conflict, licensing, etc.] | [What to use instead] |

## Environment Restrictions

| Restriction | Description | Impact on the project |
|---|---|---|
| [Restriction] | [What it is] | [What it constrains] |

## Security and Compliance Restrictions

| Requirement | Description | How it's met |
|---|---|---|
| [Requirement] | [What it is] | [Concrete mechanism — file/class/pattern that enforces it] |

## Decisions Made and Not to Be Reverted

| Decision | Context | Why not to revert |
|---|---|---|
| [Decision] | [Why it was made] | [Cost/risk of reverting] |
```

## Field Guidance

- **Forbidden Technologies**: Every row must have a *reason*, not just a rule — "don't use X" without justification invites someone to quietly reintroduce X later. If you can't find or confirm a reason, don't add the row; flag it as `[NEEDS CONFIRMATION]` instead of asserting it as fact.
- **Decisions Made and Not to Be Reverted**: This table is the highest-leverage part of the whole `.tommy/project-context/` layer — it's what stops `tommy-architect` from proposing a "cleaner" redesign that the team already deliberately rejected. Keep it current; a stale entry here can block legitimate modernization work.
- If a restriction is only a pattern you observed in code (not a confirmed decision), mark it explicitly as **observed, not confirmed** rather than blending it in as an established rule — `tommy-architect` should treat those differently (worth raising as a question, not enforcing as a constraint).

## Where to Find This Information

| Source | What it reveals | Confidence |
|---|---|---|
| Consistent absence of a common pattern across the whole codebase (e.g., no standalone components at all in an otherwise-current framework) | Circumstantial hint of a deliberate constraint | Weak — confirm before recording as a rule |
| ADRs, `docs/`, `CONTRIBUTING.md`, architecture docs | Explicit, already-documented decisions | Evidence, if present |
| Linter/config rules that actively block a pattern (e.g., an ESLint rule banning an API) | Strong signal of an enforced restriction | Strong evidence |
| Tech lead / architect / product owner | The actual reason behind any restriction, and whether it's still valid | **Ask — this file should not contain unconfirmed guesses** |

# Architecture Definition Context Reference

**Purpose:** Capture the architectural pattern and, critically, the *rationale* behind key decisions — the "why," as opposed to `.tommy/codebase/architecture.md`'s "how."

**Size limit:** 3,000 tokens (~1,800 words)

**Derive from repo evidence:** The pattern itself and how the system is organized — largely the same research as `.tommy/codebase/architecture.md` (Step 3).

**Must be confirmed with the user/product owner:** The *justification* behind each decision, and the evolution guideline for new work — these are judgment calls, not facts visible in code.

> **Scope note**: This file and `.tommy/codebase/architecture.md` cover overlapping ground on purpose. This file is decision-and-rationale oriented (why the pattern was chosen, what must not change casually, how new work should evolve it) and is read by `tommy-architect` when designing a feature. `.tommy/codebase/architecture.md` is structure-and-navigation oriented (layers, data flow diagram, domain-to-folder map) and is read whenever anyone — human or agent — needs to find where something lives. Keep the two views distinct instead of merging them into one file.

Template and guidance for documenting architecture decisions and rationale in `.tommy/project-context/architecture_definition_context.md`.

## Template

```markdown
# Architecture Definition - [Project Name]

## Adopted Architectural Pattern

**Pattern:** [Layered / Hexagonal / Clean Architecture / Modular Monolith / Microservices / ...]

**Justification:**
[Why this pattern fits this project's domain and constraints — not a textbook definition, the actual reasoning for this codebase.]

## How the System Is Organized

[Narrative: entry point, how routing/module loading works, where cross-cutting concerns like auth/state live. Cross-reference `.tommy/codebase/architecture.md` and `.tommy/codebase/structure.md` instead of re-deriving this from scratch.]

## Important Architectural Decisions

| Decision | What was decided | Justification |
|---|---|---|
| [Decision] | [Concrete choice] | [Why] |

## Layer Boundaries

- [Layer]: [responsibility]
- [Layer]: [responsibility]

## Relevant Functional Modules

- [Domain area]: [module paths]

## Diagrams and References

- [Link to any existing architecture diagrams, ADRs, or docs]

## Evolution Guideline

[How new features should extend the architecture — which pattern to follow, where to put new code by default.]

[What counts as a high-impact structural change that requires a formal architectural decision before implementation, rather than being made ad hoc inside a feature.]
```

## Field Guidance

- **Justification**: This is the field most likely to be skipped under time pressure — don't skip it. Without it, `tommy-architect` can only copy the pattern, not reason about when deviating from it is acceptable.
- **Important Architectural Decisions**: Cross-check against `tech_restrictions_context.md`'s "Decisions Made and Not to Be Reverted" table — a decision usually belongs in one or the other, not both, verbatim. Put the *what/why* here; put the *do-not-revert* framing there.
- **Evolution Guideline**: This is what `tommy-architect`'s Rule "Prefer incremental architecture changes over broad refactors" should point back to for project-specific detail — what's a normal incremental change here vs. what needs a formal decision first.

## Where to Find This Information

| Source | What it reveals | Confidence |
|---|---|---|
| Entry point, module/route registration | The pattern and how the system boots | Evidence |
| Folder structure, base classes, shared services | Layer boundaries and domain modules | Evidence |
| ADRs, architecture docs, PR descriptions for large changes | Documented rationale (if it exists) | Evidence, if present |
| Tech lead / architect | The rationale when it's not written down anywhere, and what counts as "high-impact" for this project | **Ask — the "why" is rarely fully recoverable from code alone** |

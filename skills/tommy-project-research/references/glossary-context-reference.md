# Glossary Context Reference

**Purpose:** Establish the shared, unambiguous vocabulary between business language and code — the foundation `tommy-ubiquitous-language` enforces at naming time.

**Size limit:** 2,000 tokens (~1,200 words)

**Derive from repo evidence:** Candidate terms from code identifiers, i18n keys, UI copy, and existing entity/table names.

**Must be confirmed with the user/product owner:** The business-facing definition of each term, and the EN mapping when it's not obvious or already established in code.

Template and guidance for documenting the project's domain glossary in `.tommy/project-context/glossary_context.md`.

## Template

```markdown
# Glossary - [Project Name]

## Domain Terms

| Term | EN Translation | Definition | Avoid (incorrect synonyms) |
|---|---|---|---|
| [Business term] | [Code-facing English term] | [What it means, how it's used, why it matters] | [Terms that look similar but are wrong in this context, and why] |

## Status and Lifecycles

### [Entity Name]

| Status | Description | Allowed Transitions |
|---|---|---|
| [Status] | [What it means] | [Status] -> [Status] / [Status] |

Note: [Where this status comes from — e.g. "the frontend consumes the status returned by the API and must treat it as source of truth."]

[Repeat one subsection per entity that has a meaningful lifecycle]

## Relationships Between Terms

- [Entity A] has/owns/contains [Entity B].
- [Entity B] influences [decision/entity C].

## Acronyms and Abbreviations

| Acronym | Meaning | Context of use |
|---|---|---|

## Change History

| Date | Term | Change | Reason |
|---|---|---|---|
```

## Field Guidance

- **Domain Terms**: This table is what `tommy-ubiquitous-language` and `tommy-entity-relationship-diagram` should check before naming anything — if a term is here, use it exactly, in the case/form given, everywhere (code, ER diagrams, specs).
- **EN Translation**: When the business speaks a language other than English, the code still uses English identifiers (per `tommy-ubiquitous-language`) — this column is the authoritative mapping. Don't invent a new translation if one is already established here.
- **Avoid**: List near-synonyms a non-domain-expert (or an LLM) would naturally reach for, and why they're wrong — this is what prevents `OrderDueDate` and `DueAt` from both existing in the same codebase.
- **Status and Lifecycles**: Only include entities that actually have a state machine — don't force this section for simple CRUD entities.
- Keep this file additive over time — the Change History table exists so later readers understand *why* a term changed, not just that it did.

## Where to Find This Information

| Source | What it reveals | Confidence |
|---|---|---|
| i18n/translation files | Business-facing terminology, often already the definitive source | Strong evidence |
| Entity/model/table names, enum values | Current code-facing terms and candidate status values | Evidence |
| UI copy (labels, buttons, empty states) | How the business actually talks about a concept | Evidence |
| API response status/enum fields | Real lifecycle states and their transitions | Strong evidence |
| Product owner / domain expert | Correct definitions, EN mapping when ambiguous, terms to avoid | **Ask when evidence is ambiguous or contradictory** |

# Scope Features Context Reference

**Purpose:** Break the macro scope from `project_goal_context.md` down into a concrete module/feature roadmap that specs can be checked against.

**Size limit:** 3,000 tokens (~1,800 words)

**Derive from repo evidence:** Existing feature/route/module names, what already exists in the codebase (a strong signal of what's already delivered vs. still on the roadmap).

**Must be confirmed with the user/product owner:** Roadmap order/priority, the business value framing of each feature, and anything not yet built.

Template and guidance for documenting the project's module/feature roadmap in `.tommy/project-context/scope_features_context.md`.

## Template

```markdown
# Scope Detail - [Project Name]

> Product-oriented context document for LLM use and spec planning.

---

## Product Overview

[2-4 sentences: what the product covers end to end, and the desired end state]

---

## Roadmap

| Order | ID | Module | What it delivers to the business |
|---|---|---|---|
| 1 | MODULE-001 | [Module name] | [Business value] |
| 2 | MODULE-002 | [Module name] | [Business value] |

---

## Modules and Features

---

### MODULE-001 — [Module Name]

[1-3 sentences: what this module covers and who uses it]

#### FEATURE-001 — [Feature Name]

[2-4 sentences: what it allows, who it serves, and any hard rule/constraint that matters for anyone implementing it — e.g. access control, data dependency on another feature, required status handling.]

#### FEATURE-002 — [Feature Name]

[Same structure]

---

### MODULE-002 — [Module Name]

[Repeat the same structure per module]

---

## Out of Scope

| Excluded item | Reason |
|---|---|
| [What won't be built] | [Why] |
```

## Field Guidance

- **Roadmap**: This is the single table `tommy-specify` and `tommy-business-analyst` should check first — if a feature request maps to an existing `FEATURE-XXX`, treat it as an evolution of that feature, not a brand-new one.
- **Features**: Keep each feature description to a few sentences — enough to know its purpose, audience, and hard constraints, not a full spec. The actual spec lives in `.tommy/specs/`.
- **Out of Scope**: This is what makes `tommy-business-analyst`'s "Out of scope for this story" filter meaningful at the project level — a story that reintroduces something explicitly excluded here should be flagged back to the user, not silently implemented.
- Number features sequentially across the whole project (`FEATURE-001`, `FEATURE-002`, ...) so they can be referenced unambiguously from specs and plans.

## Where to Find This Information

| Source | What it reveals | Confidence |
|---|---|---|
| Top-level route/module folder names | Candidate module boundaries | Evidence |
| Existing page/screen titles, menu structure, i18n keys | Candidate feature names and what's already built | Evidence |
| `.tommy/codebase/structure.md` (built in Step 2) | Cross-check module boundaries against actual code organization | Evidence |
| Product owner / tech lead | Roadmap order, priority, business value framing, anything not yet built, out-of-scope decisions | **Ask — do not guess** |

# Tech Stack Context Reference

**Purpose:** Give a business/architecture-decision-level narrative of the stack — what kind of system this is and what it depends on — not an exhaustive inventory.

**Size limit:** 2,000 tokens (~1,200 words)

**Derive from repo evidence:** Almost entirely — this file mirrors `.tommy/codebase/stack.md` and `.tommy/codebase/integrations.md` at a higher level, so the same manifest/config research applies.

**Must be confirmed with the user/product owner:** Rarely needed — only when the manifest doesn't disambiguate intent (e.g., a dependency present but not actually wired in yet).

> **Scope note**: This file is a narrative summary for quick orientation and technical-decision context (e.g., "can we add real-time chat without a new infra dependency?"). For the exhaustive, version-pinned dependency inventory, always defer to `.tommy/codebase/stack.md` (built in Step 1) and `.tommy/codebase/integrations.md` (built in Step 5) — do not duplicate maintenance effort keeping two exhaustive lists in sync. If the two ever disagree, `.tommy/codebase/` wins as the deeper technical source.

Template and guidance for documenting the project's stack narrative in `.tommy/project-context/tech_stack_context.md`.

## Template

```markdown
# Technology Stack - [Project Name]

## Language and Runtime

| Item | Technology | Version | Note |
|---|---|---|---|
| Primary language | [language] | [version] | [what it's the base of] |
| Runtime / Platform | [runtime] | [version] | [build/dev usage] |
| Package manager | [npm/pnpm/pip/...] | N/A | [where scripts/deps are defined] |

## Main Frameworks and Libraries

| Layer | Framework / Library | Version | Purpose |
|---|---|---|---|
| [Frontend Core / Backend Core] | [name] | [version] | [purpose] |

## Database

| Type | Technology | Version | Use in the system |
|---|---|---|---|
| Relational | [name or "Not applicable"] | [version] | [purpose] |
| Cache | [name or "Not applicable"] | [version] | [purpose] |
| NoSQL/real-time | [name or "Not applicable"] | [version] | [purpose] |

## Infrastructure and Cloud

| Item | Technology | Note |
|---|---|---|
| Build/CLI | [tool] | [scripts it exposes] |
| CI/CD | [tool] | [config file location] |
| Deploy | [target] | [environments] |

## External Systems and Components

| System / Component | Type | Purpose | How it integrates |
|---|---|---|---|
| [Backend API] | API | [what it provides] | [protocol/client used] |

## Development Tools

| Tool | Purpose |
|---|---|
```

## Field Guidance

- **Keep it a narrative, not an inventory.** If you find yourself listing every dev dependency, stop — that belongs in `.tommy/codebase/stack.md`.
- **Main Frameworks and Libraries**: Only list what shapes architectural decisions (the core framework, state management, UI kit, real-time layer) — not every utility library.
- **External Systems**: This is the table `tommy-architect` scans first when deciding whether a feature needs a new integration or can reuse an existing one.

## Where to Find This Information

| Source | What it reveals | Confidence |
|---|---|---|
| `package.json` / `requirements.txt` / equivalent manifest | Language, framework, key dependencies and versions | Evidence |
| `.tommy/codebase/stack.md`, `.tommy/codebase/integrations.md` | Already-researched exhaustive detail — summarize from there instead of re-researching | Evidence (once those exist) |
| CI/CD config, `Dockerfile`, deploy scripts | Infrastructure and cloud targets | Evidence |
| SDK imports, client instantiations | External systems and how they're consumed | Evidence |

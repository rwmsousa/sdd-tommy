# [Project Name]

This project uses **Tommy**, a spec-driven development workflow: **Specify → Prompt → Codegen**.

- Full project orientation: see `.tommy/TOMMY.md` (tech stack, architecture, code rules, key patterns).
- Business/product context: see `.tommy/project-context/` (goal, scope, glossary, tech restrictions, architecture rationale, work management).
- Technical codebase map: see `.tommy/codebase/` (stack, structure, architecture, conventions, integrations, concerns, testing).
- Feature specs, plans, and quality checklists live under `.tommy/specs/`.
- Domain terms follow the mapping in `.tommy/project-context/glossary_context.md` — do not invent alternate names for existing terms.

**If `.tommy/` is missing or incomplete in this project**, it needs to be bootstrapped before Tommy can work reliably here — see your tool's Tommy bootstrap entry point (`/tommy-start` in Claude Code, `/tommy-start` prompt in Copilot Chat, or the `tommy-start` rule in Cursor) rather than guessing at project context.

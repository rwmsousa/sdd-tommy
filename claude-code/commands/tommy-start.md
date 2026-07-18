---
description: "Cria a base de conhecimento inicial do projeto para o Tommy. Lê o skill tommy-project-research e preenche .tommy/ (scaffolding, project-context, codebase) e TOMMY.md."
---

Create the initial project knowledge base for Tommy. Read the skill `tommy-project-research` (~/.claude/skills/tommy-project-research/SKILL.md) and, in order:

1. If `.tommy/` does not exist at the project root, create it.
2. Ensure the shared scaffolding is present: `.tommy/scripts/` and `.tommy/templates/` (copy the canonical versions from this shared Tommy configuration repository if missing), and `.tommy/resources/` (may be created empty).
3. Create or refresh `.tommy/project-context/` (the 7 product-context files, per each file's reference template) and `.tommy/codebase/` (the 7 technical files).
4. Fill `TOMMY.md`.

This is the command a user runs explicitly on first setup — but every Tommy agent that depends on this scaffolding also checks for it and self-triggers `tommy-project-research` if it's missing, so the workflow doesn't hard-fail on a project where `/tommy-start` was never run.

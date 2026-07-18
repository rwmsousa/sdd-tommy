---
description: "Instrui o agente Tommy Codegen a seguir um plano de implementação e gerar o código correspondente."
---

Plan file: `$ARGUMENTS`

Read the plan file at the path above strictly and follow it step by step. Before implementing, confirm the plan's own checklist (`.tommy/specs/[spec-folder]/checklists/[BRANCH_NAME]-checklist.md`, referenced from the plan file) is fully checked — if it is missing or incomplete, stop and report it instead of implementing. Use the `tommy-codegen` agent with all its skills, tools and best practices to generate code that meets the plan requirements.

Deliver the quality checklist fully completed, with all items checked, and report any blocking issues or decisions found during implementation.

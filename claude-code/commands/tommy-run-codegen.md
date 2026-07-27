---
description: "Instrui o agente Tommy Codegen a seguir um plano de implementação e gerar o código correspondente."
---

Plan file: `$ARGUMENTS`

Read the plan file at the path above strictly and follow it step by step. Before implementing, confirm the plan's own checklist (`.tommy/specs/[spec-folder]/checklists/[BRANCH_NAME]-checklist.md`, referenced from the plan file) is fully checked — if it is missing or incomplete, stop and report it instead of implementing. Use the `tommy-codegen` agent with all its skills, tools and best practices to generate code that meets the plan requirements.

After the codegen agent finishes and its quality gate passes, invoke the `tommy-product-review` agent in **acceptance-review mode**, passing the spec folder (`.tommy/specs/[spec-folder]`) and the list of changed files. It maps every acceptance criterion in `spec.md` to code and test evidence and writes the traceability matrix to `checklists/acceptance.md`. If it returns NEEDS WORK, address the unmet criteria (re-invoking `tommy-codegen` for the gaps) and re-run the acceptance review — escalate to the user after 2 cycles instead of looping.

Deliver the quality checklist fully completed, the acceptance traceability matrix, and report any blocking issues or decisions found during implementation.

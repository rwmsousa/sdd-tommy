---
description: "Instrui o agente Tommy Codegen a seguir um plano de implementação e gerar o código correspondente — o agente cuida de tudo: gates de precondição, implementação, quality gate, matriz de aceite e convergência spec→código."
---

Plan file: `$ARGUMENTS`

Invoke the `tommy-codegen` agent — and only that agent — passing the plan file path above. It owns the whole Codegen phase end to end: precondition gates (plan checklist and plan analysis), implementation and tests, code-graph refresh, the quality gate, and the acceptance + convergence loop against `spec.md`. Do not invoke any other agent and do not run any of those steps yourself in this conversation.

When the agent returns, relay its report to the user: files changed, quality gate results, the acceptance matrix verdict (`checklists/acceptance.md`), and any blocking issue, escalated decision, or UNREQUESTED change awaiting the user's approval.

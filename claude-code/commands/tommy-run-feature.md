---
description: "Atalho: executa o codegen de TODOS os planos de uma feature (número, slug ou pasta), sem interrupção e com paralelismo seguro. Equivale a /tommy-run-codegen <feature>."
---

Feature: `$ARGUMENTS`

Follow exactly the instructions of `/tommy-run-codegen` for a feature input (resolve all plans in `.tommy/specs/<feature>/plans/`, group into waves, run `tommy-codegen` per plan with safe parallelism, no pauses between plans, consolidate acceptance and close with the final quality gate and report). Do not commit or open a PR.

---
description: "Modo manual. Executa o codegen de um plano ou de TODOS os planos de uma feature sem interrupção, via agente tommy-codegen, com paralelismo seguro quando os planos são independentes. Aceita caminho de plano, pasta da feature ou número/slug (ex.: 039)."
---

Input: `$ARGUMENTS` — caminho de um plano (`.../plans/NNN_*.md`), da pasta da feature (`.tommy/specs/NNN-slug`) ou só o número/slug da feature (ex.: `039`).

Invoke the `tommy-codegen` agent — and only that agent — once per plan. It owns each plan's Codegen phase end to end (precondition gates, implementation, tests, quality gate, acceptance + convergence). Do not run those steps yourself in this conversation. Subagents cannot invoke subagents, so the multi-plan orchestration below lives here.

## 1. Resolve the scope

- Input is a single plan file → run only that plan (one invocation).
- Input is a feature (folder, number or slug) → list `.tommy/specs/<feature>/plans/*.md` in numeric order. Skip plans already marked CONVERGED in `checklists/acceptance.md` (allows resuming after a failure).
- Read each plan's `Depends on` / `Parallel` fields and its file list, and group the plans into **waves**: a wave is the set of plans with no pending dependency on one another.

## 2. Execute — without interruption

- Wave with 1 plan: invoke the agent directly.
- Wave with several plans: invoke the agents **in parallel** only if their file sets are disjoint (check each plan's files); use `isolation: "worktree"` per agent, then merge in numeric order and resolve conflicts. On any file overlap or doubt, run sequentially.
- Tell each agent: it is running under this command (no user interaction, take technical defaults and log them), and, when running in parallel, to write its acceptance section to `checklists/acceptance.plan-NNN.md` and to skip the code-graph refresh — the orchestrator consolidates both.
- Do **not** pause between plans or ask for confirmation. Stop only when: a precondition gate fails, an agent escalates a decision that needs the user, or convergence fails after 2 cycles. In that case finish the current wave, record what is pending, and report.
- After each wave: merge `acceptance.plan-NNN.md` sections into `checklists/acceptance.md` (one `## Plan:` section per plan) and run `.tommy/scripts/graph-update.sh --json` once.

## 3. Close (once, at the end)

- Run the quality gate on the combined changes (lint, type-check, tests, relevant e2e).
- Confirm `checklists/acceptance.md` has a CONVERGED section for every plan.
- Final report in the project's language (`pt-BR` by default): plans executed (order/waves), files changed, quality gate results, acceptance matrix verdict per plan, technical defaults decided, UNREQUESTED changes awaiting approval, and pending/blocked plans.
- Do **not** commit or open a PR — that stays with `/tommy-commit` and `/tommy-open-pr`.

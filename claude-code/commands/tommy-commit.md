---
description: "Instrui o agente Tommy Git a analisar as mudanças locais e criar commit(s) seguindo Conventional Commits."
---

Extra context (optional): `$ARGUMENTS`

Use the `tommy-git` agent to review the current local changes (staged and unstaged) and create one or more commits following Conventional Commits, per its Commit workflow. If extra context was given above (a message hint, a scope, or which files to include), take it into account — but still show the proposed commit message(s) and exactly which files each would stage, and get explicit confirmation before running `git commit`.

Commit granularity: when the changes come from a feature with several plans, prefer one commit per plan (or per coherent slice), with the feature scope in the Conventional Commits `type(scope)`. Never add `Co-authored-by:` lines (or any agent attribution) — commits carry only the user's authorship from `git config`.

Never push the branch or open a PR/MR as part of this command — that is `/tommy-open-pr`.

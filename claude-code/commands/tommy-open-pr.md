---
description: "Instrui o agente Tommy Git a detectar o provedor Git do projeto, subir a branch e abrir um Pull/Merge Request."
---

Extra context (optional): `$ARGUMENTS`

Use the `tommy-git` agent to detect the project's VCS provider (GitHub, GitLab, or Azure DevOps — reading `.tommy/codebase/integrations.md` first, falling back to the `origin` remote, asking the user only if still ambiguous) and open a Pull Request (GitHub/Azure DevOps) or Merge Request (GitLab) for the current branch, per its Open Pull/Merge Request workflow. If extra context was given above (target branch, reviewers, draft flag), take it into account.

Confirm with the user before pushing the branch and again before creating the PR/MR — these are visible, hard-to-reverse actions.

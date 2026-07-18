---
name: tommy-git-azure-devops
description: "Tommy Azure DevOps Adapter Skill — commands and conventions for pushing a branch and opening a Pull Request on Azure DevOps Repos via the az CLI. Use when tommy-git has detected or been told the project's VCS provider is Azure DevOps. Triggers on: Azure DevOps, az repos pr create, dev.azure.com remote, visualstudio.com remote."
---

# Tommy Git — Azure DevOps Adapter

This skill is loaded by `tommy-git` after it has determined the project's Git host is Azure DevOps (declared in `.tommy/codebase/integrations.md`, or the `origin` remote hostname is `dev.azure.com`/`visualstudio.com`). It only covers the push + PR step — commit message construction is `tommy-conventional-commits`.

## Prerequisites

1. Check the Azure CLI and its DevOps extension are available: `az extension list -o table` should include `azure-devops`. If missing: `az extension add --name azure-devops`.
2. Check authentication: `az account show`. If not logged in, stop and report the gap (`az login`, then `az devops configure --defaults organization=<org> project=<project>`) instead of attempting a workaround.
3. Azure DevOps PR creation also accepts a PAT via `AZURE_DEVOPS_EXT_PAT` — only use this if the user already has it set; never ask the user to paste a PAT into the chat.

## Push the Branch

```bash
git push -u origin <branch>
```

Never pass `--force`/`--force-with-lease` unless the user explicitly asked for it in this same request.

## Determine the Repository and Base Branch

```bash
az repos show --repository <repo> --org <org-url> --project <project> --query defaultBranch -o tsv
```

Azure DevOps remotes are structured as `https://dev.azure.com/<org>/<project>/_git/<repo>` — parse `<org>`, `<project>`, and `<repo>` from `git remote get-url origin` rather than asking the user, unless the URL doesn't match this shape.

## Create the Pull Request

```bash
az repos pr create \
  --repository "<repo>" \
  --source-branch "<branch>" \
  --target-branch "<base-branch>" \
  --title "<type>(<scope>): <subject>" \
  --description "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>

## Test plan
- [ ] <how this was validated>
EOF
)"
```

- **Title**: reuse the Conventional Commit subject convention from `tommy-conventional-commits` (or a short natural-language summary if the branch has multiple unrelated commits).
- **Description**: build the `## Summary` from `.tommy/specs/<branch>/spec.md` (goals/acceptance criteria) and the latest `tommy-codegen` run's summary; build `## Test plan` from the codegen checklist's validation steps. Never leave these sections generic/empty — if the spec/plan isn't available, ask the user what to summarize instead of writing filler text.
- **Work items**: Azure DevOps PRs commonly link work items via `--work-items <id>`. Only pass this flag if the user gave a work item ID or `.tommy/project-context/project_management_context.md` already records one for this feature — never invent an ID.

## After Creation

Report the PR URL/ID returned by `az repos pr create` back to the user. Do not complete/auto-complete the PR, add reviewers, or set policies unless explicitly asked.

## Attribution

Never add a `Co-authored-by:` trailer to the commit(s) or a "Generated with Claude Code" line to the PR description — see `tommy-conventional-commits` for the full rule.

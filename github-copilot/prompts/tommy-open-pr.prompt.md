---
agent: agent
description: Detect the project's VCS provider (GitHub, GitLab, or Azure DevOps), push the current branch, and open a Pull/Merge Request.
---

# Tommy Open PR/MR

You are acting as Tommy's PR/MR step: push the current branch and open a Pull Request (GitHub, Azure DevOps) or Merge Request (GitLab). This assumes commits already exist ahead of the base branch — commit first with `/tommy-commit`.

## 0. Precondition

`git log <base-branch>..HEAD --oneline` — if empty, stop and report there is nothing to open a PR/MR for.

## 1. Detect the provider

1. Read `.tommy/codebase/integrations.md`'s "Git Hosting (VCS Provider)" section — if it names a provider unambiguously, use it directly, don't re-ask.
2. Otherwise run `git remote get-url origin`: `github.com` → GitHub; `gitlab.com` or a self-hosted host containing `gitlab` → GitLab; `dev.azure.com`/`visualstudio.com` → Azure DevOps.
3. Still ambiguous (unrecognized self-hosted host, multiple conflicting remotes, or no `origin`) — **ask the user** which provider/tool to use, never guess. Offer to persist the answer into `integrations.md` so this isn't asked again.
4. A host with no PR/MR concept (e.g. Google Cloud Source Repositories) — say so plainly, allow commit/push only, and stop before attempting to "open" anything.

## 2. Safety

- Confirm with the user before `git push` and again before creating the PR/MR — both are visible to others.
- Never `--force`/`--force-with-lease` unless the user explicitly asked for it in this same request.
- Never add a `Co-authored-by:` trailer or any AI-attribution line to the PR/MR body.
- Title/description are built from `.tommy/specs/<branch>/spec.md` (goals/acceptance criteria) and the latest `/tommy-codegen` summary for this branch — never generic filler; if the spec/plan isn't available, ask the user what to summarize instead of inventing content.

## 3. Push

```bash
git push -u origin <branch>
```

## 4. Provider adapter

### GitHub

- Prereq: `gh auth status`. Missing/unauthenticated → report the exact gap (install https://cli.github.com, then `gh auth login`) instead of working around it.
- Base branch: `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` (fallback `main`).
- `gh pr create --title "<type>(<scope>): <subject>" --body "..."` using a `## Summary` / `## Test plan` body — or fill `.github/pull_request_template.md` instead, if the repo has one.

### GitLab (say "Merge Request"/"MR", never "PR")

- Prereq: `glab auth status` (self-hosted instances: `glab auth login --hostname <host>`).
- Base branch: `glab repo view --json defaultBranch -q .defaultBranch` (fallback `main`/`master`).
- `glab mr create --title "..." --description "..." --source-branch "<branch>" --target-branch "<base>"` — or fill `.gitlab/merge_request_templates/*.md` instead, if the repo has one.

### Azure DevOps

- Prereq: `az extension list` includes `azure-devops` (else `az extension add --name azure-devops`); `az account show` confirms login (else `az login`).
- Parse `<org>`/`<project>`/`<repo>` from the remote URL (`https://dev.azure.com/<org>/<project>/_git/<repo>`).
- `az repos pr create --repository "<repo>" --source-branch "<branch>" --target-branch "<base>" --title "..." --description "..."`. Only add `--work-items <id>` if the user gave one or `.tommy/project-context/project_management_context.md` already records it — never invent an ID.

## 5. Report

Provider, PR/MR URL, title, target branch. Do not merge, add reviewers, or set labels/policies unless explicitly asked.

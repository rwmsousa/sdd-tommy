---
name: tommy-git-gitlab
description: "Tommy GitLab Adapter Skill — commands and conventions for pushing a branch and opening a Merge Request on GitLab (SaaS or self-hosted) via the glab CLI. Use when tommy-git has detected or been told the project's VCS provider is GitLab. Triggers on: GitLab, glab mr create, merge request, gitlab.com remote, self-hosted GitLab."
---

# Tommy Git — GitLab Adapter

This skill is loaded by `tommy-git` after it has determined the project's Git host is GitLab (declared in `.tommy/codebase/integrations.md`, or the `origin` remote hostname is `gitlab.com` / contains `gitlab`). It only covers the push + MR step — commit message construction is `tommy-conventional-commits`.

## Terminology

GitLab calls this a **Merge Request (MR)**, not a Pull Request. Use "MR"/"merge request" in every user-facing message and command when this adapter is active — do not say "PR" for a GitLab project.

## Prerequisites

1. Check the CLI is available and authenticated: `glab auth status`.
2. If `glab` is not installed, or not authenticated, stop and report the exact gap to the user (install: https://gitlab.com/gitlab-org/cli, then `glab auth login`) instead of attempting a workaround.
3. Self-hosted instances need `glab auth login --hostname <host>` pointed at the correct host — confirm the host with the user if `.tommy/codebase/integrations.md` doesn't already record it.

## Push the Branch

```bash
git push -u origin <branch>
```

Never pass `--force`/`--force-with-lease` unless the user explicitly asked for it in this same request.

## Determine the Base (Target) Branch

```bash
glab repo view --json defaultBranch -q .defaultBranch
```

Fall back to `main` or `master` only if this command fails and the user confirms which one applies.

## Create the Merge Request

```bash
glab mr create \
  --title "<type>(<scope>): <subject>" \
  --description "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>

## Test plan
- [ ] <how this was validated>
EOF
)" \
  --source-branch "<branch>" \
  --target-branch "<base-branch>"
```

- **Title**: reuse the Conventional Commit subject convention from `tommy-conventional-commits` (or a short natural-language summary if the branch has multiple unrelated commits).
- **Description**: build the `## Summary` from `.tommy/specs/<branch>/spec.md` (goals/acceptance criteria) and the latest `tommy-codegen` run's summary; build `## Test plan` from the codegen checklist's validation steps. Never leave these sections generic/empty — if the spec/plan isn't available, ask the user what to summarize instead of writing filler text.
- If the repository has an MR template (`.gitlab/merge_request_templates/*.md`), fill it instead of the generic shape above.

## After Creation

Report the MR URL returned by `glab mr create` back to the user. Do not merge, assign reviewers, or change labels unless explicitly asked.

## Attribution

Never add a `Co-authored-by:` trailer to the commit(s) or a "Generated with Claude Code" line to the MR description — see `tommy-conventional-commits` for the full rule.

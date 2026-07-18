---
name: tommy-git-github
description: "Tommy GitHub Adapter Skill — commands and conventions for pushing a branch and opening a Pull Request on GitHub via the gh CLI. Use when tommy-git has detected or been told the project's VCS provider is GitHub (remote host github.com). Triggers on: GitHub, gh pr create, pull request, github.com remote."
---

# Tommy Git — GitHub Adapter

This skill is loaded by `tommy-git` after it has determined the project's Git host is GitHub (declared in `.tommy/codebase/integrations.md`, or the `origin` remote hostname is `github.com`). It only covers the push + PR step — commit message construction is `tommy-conventional-commits`.

## Prerequisites

1. Check the CLI is available and authenticated: `gh auth status`.
2. If `gh` is not installed, or not authenticated, stop and report the exact gap to the user (install: https://cli.github.com, then `gh auth login`) instead of attempting a workaround.

## Push the Branch

```bash
git push -u origin <branch>
```

Never pass `--force`/`--force-with-lease` unless the user explicitly asked for it in this same request.

## Determine the Base Branch

```bash
gh repo view --json defaultBranchRef -q .defaultBranchRef.name
```

Fall back to `main` only if this command fails and the user confirms it.

## Create the Pull Request

```bash
gh pr create --title "<type>(<scope>): <subject>" --body "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>

## Test plan
- [ ] <how this was validated>
EOF
)"
```

- **Title**: reuse the Conventional Commit subject convention from `tommy-conventional-commits` (or a short natural-language summary if the branch has multiple unrelated commits).
- **Body**: build the `## Summary` from `.tommy/specs/<branch>/spec.md` (goals/acceptance criteria) and the latest `tommy-codegen` run's summary; build `## Test plan` from the codegen checklist's validation steps. Never leave these sections generic/empty — if the spec/plan isn't available, ask the user what to summarize instead of writing filler text.
- If the repository has a PR template (`.github/pull_request_template.md`), fill it instead of the generic `## Summary`/`## Test plan` shape above.

## After Creation

Report the PR URL returned by `gh pr create` back to the user. Do not merge, request reviewers, or change labels unless explicitly asked.

## Attribution

Never add a `Co-authored-by:` trailer to the commit(s) or a "Generated with Claude Code" line to the PR body — see `tommy-conventional-commits` for the full rule.

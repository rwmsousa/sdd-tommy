---
agent: agent
description: Review local changes and create commit(s) following Conventional Commits — format, scope, granularity, and attribution rules.
---

# Tommy Commit

You are acting as Tommy's commit step: turn local changes into well-formed commits. You never push or open a Pull/Merge Request here — that's `/tommy-open-pr`.

## 1. Review changes

`git status` and `git diff` (staged and unstaged). If nothing changed, report that and stop.

## 2. Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **type**: one of `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`. Never invent another.
- **scope**: derive from the branch's `NNN-short-name` (Tommy convention, drop the number) if the branch follows it; otherwise from the most-touched top-level path.
- **subject**: imperative mood, lowercase start, no trailing period, ≤72 characters.
- **body**: explains *why*, not *what* — the diff already shows what; omit if the subject is fully self-explanatory.
- **footer**: `BREAKING CHANGE:` (with `!` after type/scope) only for an actual broken contract — never speculative.
- `type`, `scope`, and the subject stay in English (Conventional Commits keywords); body/footer follow the project's configured language (`pt-BR` unless stated otherwise).

## 3. Granularity

Multiple commits within the same branch/plan are expected — prefer one commit per completed checklist item or cohesive logical change, never a single commit forcing together unrelated concerns. If the diff spans unrelated concerns, propose splitting into separate commits before staging anything.

## 4. Confirm and commit

Show the user the proposed commit message(s) and exactly which files each would stage. Get explicit confirmation before running anything. Stage only those specific files (`git add <files>` — never a blanket `git add -A`/`git add .`), then `git commit -m "..."` per confirmed message.

## 5. Attribution and safety

- Never add a `Co-authored-by:` trailer, a "Generated with ..." line, or any AI-attribution footer — commit author is always the local `git config user.name`/`user.email`.
- Never amend a commit that has already been pushed; never `--no-verify`.

## 6. Report

Commit hash(es) and message(s) created.

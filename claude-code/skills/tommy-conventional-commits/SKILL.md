---
name: tommy-conventional-commits
description: "Tommy Conventional Commits Skill — defines the Conventional Commits message standard (type(scope): subject, body, footer, breaking changes), commit granularity, and author/attribution rules used by tommy-git. Use when writing a commit message, deciding how to split a diff into commits, or validating a commit message against the project's standard. Triggers on: commit message, conventional commits, commit standard, split commits, commit granularity, breaking change footer."
---

# Tommy Conventional Commits

This skill defines how `tommy-git` writes commit messages and decides commit boundaries. It does not run any git command itself — it only produces the message(s) that the agent proposes to the user before committing.

## Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

- **type**: lowercase, one of the allowed types below.
- **scope**: optional, lowercase, no spaces (use `-`). Identifies the affected module/feature.
- **subject**: imperative mood, no capital letter at the start, no trailing period, ≤72 characters.
- **body**: explains *why*, not *what* (the diff already shows what). Omit if the subject is fully self-explanatory.
- **footer**: breaking changes and issue references only.

## Allowed Types

| Type | Use for |
|---|---|
| `feat` | New user-facing capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `style` | Formatting, whitespace — no code meaning change |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `perf` | Performance improvement |
| `test` | Adding or correcting tests |
| `build` | Build system or external dependencies |
| `ci` | CI/CD configuration |
| `chore` | Maintenance that doesn't fit the above |
| `revert` | Reverts a previous commit |

Never invent a type outside this list. If none fits, default to `chore` and explain why in the body.

## Scope Derivation

1. If the current branch follows the Tommy convention `NNN-short-name` (created by `tommy-specify`'s `create-new-spec.sh`), derive `scope` from `short-name` (drop the number, keep the hyphenated words, or the single most relevant word if the full short-name is too long for a natural scope).
2. Otherwise, infer the scope from the most common top-level touched path (e.g. `src/auth/` → `auth`).
3. If changes span unrelated scopes, that's a signal to split into multiple commits (see Granularity below), not to pick a scope that covers everything.

## Language Rule

`type`, `scope`, and the subject line follow Conventional Commits convention and stay in English (these are structural keywords, not narrative). The body and footer follow the project's configured language (`pt-BR` unless `.tommy/TOMMY.md` states otherwise) — same split already used for code identifiers vs. narrative output elsewhere in Tommy.

## Granularity

Multiple commits within the same branch/plan are expected and encouraged — do not force everything into a single squash commit per plan:

- Prefer **one commit per completed checklist item** (from the codegen checklist) or per cohesive logical change, when the diff naturally separates that way.
- Never mix unrelated concerns in one commit (e.g. a bug fix and an unrelated refactor). If `git status`/`git diff` shows this, propose splitting into separate commits and stage (`git add <specific files>`) each subset explicitly — never a blanket `git add -A`/`git add .` that could sweep in unrelated or unintended changes.
- A single checklist item that touches many files is still one commit — granularity follows logical intent, not file count.

## Author & Attribution Rules

- **Never** add a `Co-authored-by:` trailer, a "Generated with Claude Code" line, or any other AI-attribution footer, regardless of which agent or tool produced the change. This applies to every commit and every PR/MR description.
- The commit author is always the local `git config user.name` / `user.email` — never override, impersonate, or add a second author.
- Do not fabricate issue/ticket references in the footer; only include them if the user provided them or they are already established in the branch/spec naming.

## Breaking Changes

Mark with `!` after the type/scope (`feat(auth)!: ...`) **and** a `BREAKING CHANGE:` footer line explaining the impact and migration path. Only use this when the change actually breaks a public contract — never speculatively.

## Examples

```
feat(auth): add refresh token rotation

Rotating refresh tokens on every use reduces the replay window
for a stolen token from the token's full TTL to a single use.
```

```
fix(checkout): prevent double submit on slow network

BREAKING CHANGE: the checkout form now disables the submit button
until the previous request settles; any integration relying on
rapid repeated submits will need to poll order status instead.
```

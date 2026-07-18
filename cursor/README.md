# Tommy for Cursor

This folder is installed **per project**, not globally — into the target repository's `.cursor/` folder:

```
<seu-projeto>/.cursor/
└── rules/
    ├── tommy-core.mdc        (alwaysApply: true)
    ├── tommy-start.mdc
    ├── tommy-specify.mdc
    ├── tommy-prompt.mdc
    ├── tommy-codegen.mdc
    ├── tommy-commit.mdc
    └── tommy-open-pr.mdc
```

## Installation

Run `npx sdd-tommy@latest` at the project root and pick "Cursor" in the prompt (can be combined with Claude Code/Copilot in the same run) — it copies `rules/` into `.cursor/rules/` and also populates `.tommy/scripts/`/`.tommy/templates/` for you (the tool-agnostic Tommy runtime, otherwise `@tommy-start` does it the first time it runs). Manual alternative: copy this folder's contents into `.cursor/` yourself, and `../common/scripts/`/`../common/templates/` into `.tommy/scripts/`/`.tommy/templates/`.

## Usage

`tommy-core.mdc` is always active and will prompt you to pull in `@tommy-start` the first time `.tommy/` is missing. After that:

1. `@tommy-specify` — describe the feature; answer the clarifying questions.
2. `@tommy-prompt` — reference the spec created in step 1.
3. `@tommy-codegen` — reference one plan file at a time from step 2.
4. When ready to version what was generated: `@tommy-commit` (one or more commits, under confirmation) and, when ready, `@tommy-open-pr` (pushes the branch and opens the PR/MR) — see "Versioning" below.

The rules use `description`-based (Agent Requested) activation, so Cursor can also pull them in automatically when your request matches — you don't strictly have to type `@rule-name` every time, unlike Copilot's manual-only `/prompt-name` invocation.

## Versioning (commit and PR/MR)

`tommy-commit.mdc` and `tommy-open-pr.mdc` condense everything Claude Code's `tommy-git` agent does into two rule files — committing and opening a PR/MR are separate, separately-confirmed actions, never chained automatically, and no other rule pulls either of these in on its own:

- **`@tommy-commit`** — reviews `git status`/`git diff`, proposes message(s) in Conventional Commits format, only commits after confirmation. Multiple commits per branch/plan are expected (e.g. one per finished checklist item).
- **`@tommy-open-pr`** — detects the project's Git provider (GitHub, GitLab, or Azure DevOps — reading `.tommy/codebase/integrations.md` first, set during `@tommy-start`'s bootstrap), pushes the branch, and opens the PR (`gh`) or MR (`glab`)/PR (`az repos`), confirming before each visible action.

Each CLI (`gh`/`glab`/`az`) is assumed already installed and authenticated locally — no new credentials go into this repo's config. Never adds a `Co-authored-by:` trailer or similar AI-attribution footer to a commit or PR/MR body.

## What's different from the Claude Code version

Cursor has no concept of a subagent with restricted tool access, so the 5 Claude Code personas (specify, business-analyst, architect, prompt, codegen) are condensed into 3 phase rules + bootstrap here — `tommy-specify` absorbs requirements elicitation, `tommy-prompt` absorbs architecture design. Phase separation (not writing code during the spec/plan phases) is **self-enforced discipline**, not a technical guarantee — see the "Known limitation" note in `tommy-core.mdc`. Cursor's "custom modes" could in principle map to the 3 phases, but they're configured in-app rather than fully filesystem-scriptable, so they're intentionally not part of this setup.

The same applies to versioning: Claude Code's `tommy-git` agent has 4 separate skills (Conventional Commits + one adapter per provider) it loads on demand; here that's condensed into 2 rule files (`tommy-commit.mdc`, `tommy-open-pr.mdc`), with the 3 provider adapters as sections inside `tommy-open-pr.mdc` instead of separate files.

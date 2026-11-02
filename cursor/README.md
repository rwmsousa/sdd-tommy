# Tommy for Cursor

This folder is installed **per project**, not globally — into the target repository's `.cursor/` folder:

```
<seu-projeto>/.cursor/
└── rules/
    ├── tommy-core.mdc        (alwaysApply: true)
    ├── tommy-start.mdc
    ├── tommy.mdc             (default entry point)
    ├── tommy-specify.mdc
    ├── tommy-prompt.mdc
    ├── tommy-codegen.mdc
    ├── tommy-bugfix.mdc
    ├── tommy-commit.mdc
    └── tommy-open-pr.mdc
```

## Installation

Run `npx sdd-tommy@latest` at the project root and pick "Cursor" in the prompt (can be combined with Claude Code/Copilot in the same run) — it copies `rules/` into `.cursor/rules/` and also populates `.tommy/scripts/`/`.tommy/templates/` for you (the tool-agnostic Tommy runtime, otherwise `@tommy-start` does it the first time it runs). Manual alternative: copy this folder's contents into `.cursor/` yourself, and `../common/scripts/`/`../common/templates/` into `.tommy/scripts/`/`.tommy/templates/`.

## Usage

`tommy-core.mdc` is always active and will prompt you to pull in `@tommy-start` the first time `.tommy/` is missing. After that:

1. `@tommy <what you need>` — answer the clarifying questions, then **approve the spec**. From there Tommy plans and implements on its own (architecture, plans, plan analysis, code, quality gate, acceptance) and only stops for a blocking decision. Bugs described to `@tommy` follow the bugfix flow.
2. Manual mode, one phase at a time: `@tommy-specify` (feature → spec), `@tommy-prompt` (spec → plans), `@tommy-codegen` (one plan file at a time).
3. When ready to version what was generated: `@tommy-commit` (one or more commits, under confirmation) and, when ready, `@tommy-open-pr` (pushes the branch and opens the PR/MR) — see "Versioning" below.

Bugs in existing code: `@tommy-bugfix` — describe a bug in existing code (assess → fix → verify).

The rules use `description`-based (Agent Requested) activation, so Cursor can also pull them in automatically when your request matches — you don't strictly have to type `@rule-name` every time, unlike Copilot's manual-only `/prompt-name` invocation.

## Prerequisites (RTK + Graphify)

When Cursor is selected, the installer (after confirmation) installs uv, Graphify and RTK and runs their official Cursor integrations: `rtk init -g --agent cursor --auto-patch` (global `preToolUse` hook in `~/.cursor/hooks.json`) and `graphify cursor install` (project rule `.cursor/rules/graphify.mdc`). The Tommy rules query the code graph (`graphify query`) before grepping and treat RTK-compressed output by its exit code (`rtk bypass <cmd>` for the full output). Check with `npx sdd-tommy@latest --doctor`.

## Versioning (commit and PR/MR)

`tommy-commit.mdc` and `tommy-open-pr.mdc` condense everything Claude Code's `tommy-git` agent does into two rule files — committing and opening a PR/MR are separate, separately-confirmed actions, never chained automatically, and no other rule pulls either of these in on its own:

- **`@tommy-commit`** — reviews `git status`/`git diff`, proposes message(s) in Conventional Commits format, only commits after confirmation. Multiple commits per branch/plan are expected (e.g. one per finished checklist item).
- **`@tommy-open-pr`** — detects the project's Git provider (GitHub, GitLab, or Azure DevOps — reading `.tommy/codebase/integrations.md` first, set during `@tommy-start`'s bootstrap), pushes the branch, and opens the PR (`gh`) or MR (`glab`)/PR (`az repos`), confirming before each visible action.

Each CLI (`gh`/`glab`/`az`) is assumed already installed and authenticated locally — no new credentials go into this repo's config. Never adds a `Co-authored-by:` trailer or similar AI-attribution footer to a commit or PR/MR body.

## What's different from the Claude Code version

Cursor has no concept of a subagent with restricted tool access, so the Claude Code roles (specify + business-analyst elicitation, product-review, architect, prompt, codegen) are condensed into 3 phase rules + bugfix + bootstrap here — `tommy-specify` absorbs requirements elicitation **and** the independent PM review with the domain checklists (as a deliberate, self-enforced role switch at the end of the phase), `tommy-prompt` absorbs architecture design **and** the read-only plan analysis, and `tommy-codegen` closes with the spec→code acceptance & convergence loop. Phase separation (not writing code during the spec/plan phases) is **self-enforced discipline**, not a technical guarantee — see the "Known limitation" note in `tommy-core.mdc`. Cursor's "custom modes" could in principle map to the 3 phases, but they're configured in-app rather than fully filesystem-scriptable, so they're intentionally not part of this setup.

Project MCP servers come from the canonical `.tommy/mcp.json` — Cursor reads its generated projection at `.cursor/mcp.json` (created by the installer/bootstrap as a non-destructive merge; see `common/templates/mcp/mcp-catalog.md`).

The same applies to versioning: Claude Code's `tommy-git` agent has 4 separate skills (Conventional Commits + one adapter per provider) it loads on demand; here that's condensed into 2 rule files (`tommy-commit.mdc`, `tommy-open-pr.mdc`), with the 3 provider adapters as sections inside `tommy-open-pr.mdc` instead of separate files.

# Tommy for GitHub Copilot

This folder is installed **per project**, not globally — into the target repository's `.github/` folder:

```
<seu-projeto>/.github/
├── copilot-instructions.md
└── prompts/
    ├── tommy-start.prompt.md
    ├── tommy.prompt.md          (default entry point)
    ├── tommy-specify.prompt.md
    ├── tommy-prompt.prompt.md
    ├── tommy-codegen.prompt.md
    ├── tommy-bugfix.prompt.md
    ├── tommy-commit.prompt.md
    └── tommy-open-pr.prompt.md
```

## Installation

Run `npx sdd-tommy@latest` at the project root and pick "GitHub Copilot" in the prompt (can be combined with Claude Code/Cursor in the same run) — it copies `prompts/` into `.github/prompts/`, appends `copilot-instructions.md` below a clearly marked section if you already have your own (never overwrites your team's existing instructions), and also populates `.tommy/scripts/`/`.tommy/templates/` for you (otherwise `/tommy-start` does it the first time it runs). Manual alternative: copy this folder's contents into `.github/` yourself, and `../common/scripts/`/`../common/templates/` into `.tommy/scripts/`/`.tommy/templates/`.

## Usage

1. Open Copilot Chat in this project, run `/tommy-start` once.
2. `/tommy <what you need>` — answer the clarifying questions, then **approve the spec**. From there Tommy plans and implements on its own (architecture, plans, plan analysis, code, quality gate, acceptance) and only stops for a blocking decision. Bugs described to `/tommy` follow the bugfix flow.
3. Manual mode, one phase at a time: `/tommy-specify` (feature → spec), `/tommy-prompt` (spec → plans), `/tommy-codegen` (one plan file at a time).
4. When ready to version what was generated: `/tommy-commit` (one or more commits, under confirmation) and, when ready, `/tommy-open-pr` (pushes the branch and opens the PR/MR) — see "Versioning" below.

Bugs in existing code: `/tommy-bugfix` — describe a bug in existing code (assess → fix → verify).

## Prerequisites (RTK + Graphify)

When GitHub Copilot is selected, the installer (after confirmation) installs uv, Graphify and RTK and runs their official Copilot integrations: `rtk init -g --copilot --auto-patch` (global hook in `~/.copilot/hooks/` + user instructions) and `graphify vscode install` (skill in `~/.copilot/skills/graphify/` + a section appended to `.github/copilot-instructions.md`, **below** Tommy's managed section — Tommy's section is bounded by start/end markers, so re-installing Tommy keeps Graphify's section intact). The Tommy prompts query the code graph (`graphify query`) before grepping and treat RTK-compressed output by its exit code (`rtk bypass <cmd>` for the full output). Check with `npx sdd-tommy@latest --doctor`.

## Versioning (commit and PR/MR)

`tommy-commit.prompt.md` and `tommy-open-pr.prompt.md` condense everything Claude Code's `tommy-git` agent does into two prompt files — committing and opening a PR/MR are separate, separately-confirmed actions, never chained automatically, and no other prompt pulls either of these in on its own:

- **`/tommy-commit`** — reviews `git status`/`git diff`, proposes message(s) in Conventional Commits format, only commits after confirmation. Multiple commits per branch/plan are expected (e.g. one per finished checklist item).
- **`/tommy-open-pr`** — detects the project's Git provider (GitHub, GitLab, or Azure DevOps — reading `.tommy/codebase/integrations.md` first, set during `/tommy-start`'s bootstrap), pushes the branch, and opens the PR (`gh`) or MR (`glab`)/PR (`az repos`), confirming before each visible action.

Each CLI (`gh`/`glab`/`az`) is assumed already installed and authenticated locally — no new credentials go into this repo's config. Never adds a `Co-authored-by:` trailer or similar AI-attribution footer to a commit or PR/MR body.

## What's different from the Claude Code version

Copilot has no concept of a subagent with restricted tool access, so the Claude Code roles (specify + business-analyst elicitation, product-review, architect, prompt, codegen) are condensed into 3 prompt files + bugfix + bootstrap here — `tommy-specify` absorbs requirements elicitation **and** the independent PM review with the domain checklists (as a deliberate, self-enforced role switch at the end of the phase), `tommy-prompt` absorbs architecture design **and** the read-only plan analysis, and `tommy-codegen` closes with the spec→code acceptance & convergence loop. Phase separation (not writing code during the spec/plan phases) is **self-enforced discipline**, not a technical guarantee — see the "Known limitation" note in `copilot-instructions.md`. `/tommy` chains the three prompt files in one chat, with the spec approval as the only gate — the Claude Code version does the same with real subagents.

Project MCP servers come from the canonical `.tommy/mcp.json` — VS Code/Copilot reads its generated projection at `.vscode/mcp.json` (created by the installer/bootstrap as a non-destructive merge, in VS Code's `servers` format; see `common/templates/mcp/mcp-catalog.md`).

The same applies to versioning: Claude Code's `tommy-git` agent has 4 separate skills (Conventional Commits + one adapter per provider) it loads on demand; here that's condensed into 2 prompt files (`tommy-commit.prompt.md`, `tommy-open-pr.prompt.md`), with the 3 provider adapters as sections inside `tommy-open-pr.prompt.md` instead of separate files.

# Tommy for GitHub Copilot

This folder is installed **per project**, not globally — copy its contents into the target repository's `.github/` folder:

```
<seu-projeto>/.github/
├── copilot-instructions.md
└── prompts/
    ├── tommy-start.prompt.md
    ├── tommy-specify.prompt.md
    ├── tommy-prompt.prompt.md
    ├── tommy-codegen.prompt.md
    ├── tommy-commit.prompt.md
    └── tommy-open-pr.prompt.md
```

The project also needs the tool-agnostic Tommy runtime — copy `../common/scripts/` and `../common/templates/` into the project's `.tommy/scripts/` and `.tommy/templates/`, or let `/tommy-start` do it for you the first time it runs (it copies from wherever this Tommy installation lives).

## Usage

1. Open Copilot Chat in this project, run `/tommy-start` once.
2. `/tommy-specify` — describe the feature; answer the clarifying questions.
3. `/tommy-prompt` — reference the spec created in step 2.
4. `/tommy-codegen` — reference one plan file at a time from step 3.
5. When ready to version what was generated: `/tommy-commit` (one or more commits, under confirmation) and, when ready, `/tommy-open-pr` (pushes the branch and opens the PR/MR) — see "Versioning" below.

## Versioning (commit and PR/MR)

`tommy-commit.prompt.md` and `tommy-open-pr.prompt.md` condense everything Claude Code's `tommy-git` agent does into two prompt files — committing and opening a PR/MR are separate, separately-confirmed actions, never chained automatically, and no other prompt pulls either of these in on its own:

- **`/tommy-commit`** — reviews `git status`/`git diff`, proposes message(s) in Conventional Commits format, only commits after confirmation. Multiple commits per branch/plan are expected (e.g. one per finished checklist item).
- **`/tommy-open-pr`** — detects the project's Git provider (GitHub, GitLab, or Azure DevOps — reading `.tommy/codebase/integrations.md` first, set during `/tommy-start`'s bootstrap), pushes the branch, and opens the PR (`gh`) or MR (`glab`)/PR (`az repos`), confirming before each visible action.

Each CLI (`gh`/`glab`/`az`) is assumed already installed and authenticated locally — no new credentials go into this repo's config. Never adds a `Co-authored-by:` trailer or similar AI-attribution footer to a commit or PR/MR body.

## What's different from the Claude Code version

Copilot has no concept of a subagent with restricted tool access, so the 5 Claude Code personas (specify, business-analyst, architect, prompt, codegen) are condensed into 3 prompt files + bootstrap here — `tommy-specify` absorbs requirements elicitation, `tommy-prompt` absorbs architecture design. Phase separation (not writing code during the spec/plan phases) is **self-enforced discipline**, not a technical guarantee — see the "Known limitation" note in `copilot-instructions.md`.

The same applies to versioning: Claude Code's `tommy-git` agent has 4 separate skills (Conventional Commits + one adapter per provider) it loads on demand; here that's condensed into 2 prompt files (`tommy-commit.prompt.md`, `tommy-open-pr.prompt.md`), with the 3 provider adapters as sections inside `tommy-open-pr.prompt.md` instead of separate files.

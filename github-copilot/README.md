# Tommy for GitHub Copilot

This folder is installed **per project**, not globally — copy its contents into the target repository's `.github/` folder:

```
<seu-projeto>/.github/
├── copilot-instructions.md
└── prompts/
    ├── tommy-start.prompt.md
    ├── tommy-specify.prompt.md
    ├── tommy-prompt.prompt.md
    └── tommy-codegen.prompt.md
```

The project also needs the tool-agnostic Tommy runtime — copy `../common/scripts/` and `../common/templates/` into the project's `.tommy/scripts/` and `.tommy/templates/`, or let `/tommy-start` do it for you the first time it runs (it copies from wherever this Tommy installation lives).

## Usage

1. Open Copilot Chat in this project, run `/tommy-start` once.
2. `/tommy-specify` — describe the feature; answer the clarifying questions.
3. `/tommy-prompt` — reference the spec created in step 2.
4. `/tommy-codegen` — reference one plan file at a time from step 3.

## What's different from the Claude Code version

Copilot has no concept of a subagent with restricted tool access, so the 5 Claude Code personas (specify, business-analyst, architect, prompt, codegen) are condensed into 3 prompt files + bootstrap here — `tommy-specify` absorbs requirements elicitation, `tommy-prompt` absorbs architecture design. Phase separation (not writing code during the spec/plan phases) is **self-enforced discipline**, not a technical guarantee — see the "Known limitation" note in `copilot-instructions.md`.

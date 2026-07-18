# Tommy for Cursor

This folder is installed **per project**, not globally — copy its contents into the target repository's `.cursor/` folder:

```
<seu-projeto>/.cursor/
└── rules/
    ├── tommy-core.mdc        (alwaysApply: true)
    ├── tommy-start.mdc
    ├── tommy-specify.mdc
    ├── tommy-prompt.mdc
    └── tommy-codegen.mdc
```

The project also needs the tool-agnostic Tommy runtime — copy `../common/scripts/` and `../common/templates/` into the project's `.tommy/scripts/` and `.tommy/templates/`, or let `@tommy-start` do it for you the first time it runs.

## Usage

`tommy-core.mdc` is always active and will prompt you to pull in `@tommy-start` the first time `.tommy/` is missing. After that:

1. `@tommy-specify` — describe the feature; answer the clarifying questions.
2. `@tommy-prompt` — reference the spec created in step 1.
3. `@tommy-codegen` — reference one plan file at a time from step 2.

The four phase rules use `description`-based (Agent Requested) activation, so Cursor can also pull them in automatically when your request matches — you don't strictly have to type `@rule-name` every time, unlike Copilot's manual-only `/prompt-name` invocation.

## What's different from the Claude Code version

Cursor has no concept of a subagent with restricted tool access, so the 5 Claude Code personas (specify, business-analyst, architect, prompt, codegen) are condensed into 3 phase rules + bootstrap here — `tommy-specify` absorbs requirements elicitation, `tommy-prompt` absorbs architecture design. Phase separation (not writing code during the spec/plan phases) is **self-enforced discipline**, not a technical guarantee — see the "Known limitation" note in `tommy-core.mdc`. Cursor's "custom modes" could in principle map to the 3 phases, but they're configured in-app rather than fully filesystem-scriptable, so they're intentionally not part of this setup.

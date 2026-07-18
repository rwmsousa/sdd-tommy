---
agent: agent
description: Bootstrap Tommy for this project — scaffold .tommy/, research the codebase, and produce the initial knowledge base.
---

# Tommy Start — Bootstrap

Run this once per project (or whenever `.tommy/` is missing/incomplete). Do all steps in order — do not skip any, even if a file "seems obvious."

## Step 0 — Scaffold `.tommy/`

If `.tommy/` does not exist at the project root, create it. Ensure these exist — never author new scripts/templates from scratch, they must stay identical across every project using Tommy:

- `.tommy/scripts/` and `.tommy/templates/` — if either is missing, run `npx -y sdd-tommy@latest --sync-runtime` at the project root to populate them (`common.sh`, `create-new-spec.sh`, `create-new-prompt.sh`, `create-codegen-checklist.sh`, `spec-template.md`, `prompt-template.md`, `checklist-template.md`, `prompt-checklist.md`, `codegen-checklist.md`, `agents-md-template.md`, `project-research/`)
- `.tommy/resources/` — may stay empty
- `.tommy/project-context/` and `.tommy/codebase/` — built by the steps below

## Step 1 — Map the Codebase (`.tommy/codebase/`)

For each file below, follow its reference template under `.tommy/templates/project-research/codebase/`. This layer IS evidence-derivable — every claim must be backed by an actual file path, config, or code pattern found in the repo; state explicitly when something can't be determined instead of guessing.

1. `stack.md` — package manifests, lock files, runtime/build configs.
2. `structure.md` — top-level directories, entry points, path aliases, monorepo layout.
3. `architecture.md` — pattern (layered/hexagonal/MVC/etc.), layer boundaries, data flow, domain boundaries.
4. `conventions.md` — linting/formatting, naming, file organization, import patterns, commit conventions.
5. `integrations.md` — databases, external APIs, message brokers, cloud services, CI/CD, and **Git hosting**: run `git remote -v` and match the `origin` hostname (`github.com` → GitHub, `gitlab.com`/self-hosted host containing `gitlab` → GitLab, `dev.azure.com`/`visualstudio.com` → Azure DevOps). If the hostname doesn't match any known pattern, ask the user which provider/tool to use instead of guessing — record the answer here so `/tommy-commit`/`/tommy-open-pr` don't ask again.
6. `concerns.md` — auth, logging, error handling, validation, caching, i18n, security, performance.
7. `testing.md` — test framework, test types, location/naming conventions, coverage tools, scripts.

## Step 2 — Build the Product Context Layer (`.tommy/project-context/`)

Runs after Step 1 on purpose: `tech_stack_context.md` and `architecture_definition_context.md` are narrative summaries of codebase files that must already exist to summarize instead of re-research — don't re-derive the dependency list or re-trace the codebase from scratch a second time, read `stack.md`/`integrations.md` and `architecture.md`/`structure.md` and condense them. The other five files have no codebase-file counterpart.

For each file below, follow its reference template under `.tommy/templates/project-research/project-context/`. **This layer is not purely derivable from code** — business objective, target users, market positioning, roadmap priority, and "decisions not to revert" are facts that live in someone's head. Where evidence is ambiguous or absent, write `[NEEDS CONFIRMATION]` and ask the user — never fabricate a business fact to avoid asking a question.

- `project_goal_context.md`, `scope_features_context.md`, `glossary_context.md`, `tech_stack_context.md`, `architecture_definition_context.md`, `tech_restrictions_context.md`, `project_management_context.md`

## Step 3 — Fill `.tommy/TOMMY.md`

Update `.tommy/TOMMY.md` (create it if absent — **inside `.tommy/`, never at the project root**: `.tommy/` is usually gitignored and not everyone on the project uses Tommy) with a synthesis: project name/purpose, tech stack, architecture entry points and key patterns, 5-10 critical code rules from `conventions.md`, design system if applicable. Keep it under 80 lines — it's a summary, not a dump; the detail lives in `.tommy/codebase/`.

## Step 4 — Create `AGENTS.md`

Create or refresh `AGENTS.md` **at the project root** — the one deliberate exception to "everything lives inside `.tommy/`", because that's the only location Copilot (and Cursor) discover it natively. Generate it from `.tommy/templates/agents-md-template.md`. Keep it short (10-20 lines) and free of anything project-sensitive — it's navigation to `.tommy/TOMMY.md`, not a copy of it.

## Report

Summarize what was created/updated, and list every `[NEEDS CONFIRMATION]` placeholder left behind — those need a follow-up conversation with the user before `/tommy-specify` is run for real feature work.

---
agent: agent
description: Turn a feature description into a Tommy specification (spec.md) — requirements elicitation and business-language spec writing, no implementation detail.
---

# Tommy Specify

You are acting as Tommy's Specify phase: turn a natural-language feature request into a validated `spec.md`. **Never write implementation code in this phase** — see the "Known limitation" note in `copilot-instructions.md`; nothing technically stops you, so don't.

## 0. Bootstrap check

If `.tommy/scripts/`, `.tommy/templates/`, or `.tommy/project-context/` are missing, stop and tell the user to run `/tommy-start` first.

## 1. Read context

Read `.tommy/project-context/project_goal_context.md`, `scope_features_context.md`, and `glossary_context.md` always. Check whether the request maps to an existing `FEATURE-XXX` in the roadmap, or is genuinely new.

## 2. Create the feature branch and files

Run: `.tommy/scripts/create-new-spec.sh "<feature description>" --json --short-name "<2-4 word slug>"`. Use the JSON output's `BRANCH_NAME`, `SPEC_FILE`, `FEATURE_DIR`, `CHECKLIST_FILE` — do not guess paths.

## 3. Elicit requirements

Before writing the spec, ask the user targeted questions (short batches, 3-5 at a time, highest-risk gaps first) covering what's still unclear:

- Problem statement and business objective
- Users and roles; main flows and exceptions
- Business rules and validations; input/output data
- External integrations and dependencies
- Constraints (timeline, regulatory, security, performance)
- Acceptance criteria and success metrics; explicitly out of scope

For each User Story, apply this filter before including it — a story only qualifies if it passes ALL three:

- **Value test**: direct, perceivable benefit to the end user/business, not an internal technical task.
- **Testability test**: a clear, verifiable outcome the client can validate themselves.
- **Independence test**: deliverable and demonstrable in isolation, without depending on unreleased stories.

Split stories that are too large rather than writing a vague one. Never assume a business rule without evidence — confirm with the user or the project-context files.

## 4. Write the spec

Fill `SPEC_FILE` using `.tommy/templates/spec-template.md` — every section, replacing all placeholders (including the `[ORIGINAL_FEATURE_DESCRIPTION]` field and the "Out of scope for this story" line per user story). Write it for business stakeholders: WHAT and WHY, never HOW (no tech stack, APIs, code structure). Success criteria must be measurable, technology-agnostic, user-focused, and verifiable — e.g. "users can complete checkout in under 3 minutes," never "API response time is under 200ms."

Write the spec in the project's configured language (`pt-BR` unless stated otherwise); domain terms that will become code identifiers stay in English per the glossary.

## 5. Validate

Open `CHECKLIST_FILE` and check the spec against every item (no implementation details, testable/unambiguous requirements, measurable + tech-agnostic success criteria, bounded scope, no `[NEEDS CLARIFICATION]` markers remaining). Fix and re-check until everything passes — up to 3 iterations before escalating unresolved items to the user.

## 6. Report

Branch name, spec file path, checklist result, and any open questions still blocking `/tommy-prompt`.

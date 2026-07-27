---
name: 'tommy-quality-gate'
description: "Tommy Quality Gate Skill — ensures the quality of generated code through a systematic validation workflow. Use this skill after generating or modifying code, when asked to validate code quality, check for code smells, verify standards compliance, review generated code, run quality checks, audit frontend accessibility or performance, scan for security issues, or ensure code meets project quality standards. Triggers on: validate code, quality check, review code quality, ensure quality, run quality gate, check code standards, verify code, accessibility audit, performance audit, security scan."
---

# Tommy Quality Gate

This skill defines a systematic workflow for validating the quality of generated or modified code. The quality gate is not a single check — it is a pipeline of gates, each building on the previous one. If any gate fails, the issue must be resolved before proceeding.

This file is the router: it tells you which gates apply and in which order. **Before running a gate, read its reference file** (in `references/`) for the full procedure and pass criteria — do not run a gate from memory.

## When to Use

- After generating new code or modifying existing code.
- When the user explicitly asks to validate or review code quality.
- As the final step in a code generation workflow.
- When investigating code smells, complexity issues, accessibility/performance problems, or security concerns.

## Rules

- Always run every **applicable** gate. **NEVER** skip an applicable gate.
- Conditional gates evaluate their condition first; when not applicable, record **SKIP** with the reason — a SKIP with reason is a valid outcome, a silently missing gate is not.
- If any gate fails, identify the issue, fix it, and re-run the gate until it passes.
- Fill all quality checklist items.

## Gates

Execution order: **0 → 1 → 2 → 3 → 4 → 5 → 7 → 8 → 6**. Gate 6 (checklist) always runs last — it is the final review after every other gate has passed.

| Gate | Applies when | Reference |
| --- | --- | --- |
| 0. Scope Coverage & Diff Analysis | Always | [references/gate-0-scope.md](references/gate-0-scope.md) |
| 1. Static Analysis | Always | [references/gate-1-static-analysis.md](references/gate-1-static-analysis.md) |
| 2. Tests & Coverage | Always | [references/gate-2-tests-coverage.md](references/gate-2-tests-coverage.md) |
| 3. Complexity | Always | [references/gate-3-complexity.md](references/gate-3-complexity.md) |
| 4. Pattern Compliance | Always | [references/gate-4-pattern-compliance.md](references/gate-4-pattern-compliance.md) |
| 5. SonarQube | `sonar-project.properties` present | [references/gate-5-sonarqube.md](references/gate-5-sonarqube.md) |
| 7. Frontend Audit | `.tommy/codebase/stack.md` indicates a frontend UI | [references/gate-7-frontend-audit.md](references/gate-7-frontend-audit.md) |
| 8. Security | Always | [references/gate-8-security.md](references/gate-8-security.md) |
| 6. Checklist Verification | Always (last) | [references/gate-6-checklist.md](references/gate-6-checklist.md) |

## Quality Scripts

Gates 1, 3, and 5 are backed by the project's quality scripts in `.tommy/scripts/quality/` (`quality-check.sh`, `complexity-check.sh`, `sonar-run.sh`), installed by the Tommy runtime sync. If they are missing, restore them with `npx -y sdd-tommy@latest --sync-runtime`; each gate's reference also documents the manual fallback.

## Handling Failures

When a gate fails:

1. Identify the specific issue and its root cause.
2. Fix the issue in the generated code.
3. Re-run the failed gate to confirm the fix.
4. Continue to the next gate only after the current gate passes.
5. If a fix in a later gate could affect an earlier gate (e.g., refactoring to reduce complexity changes test expectations), re-run affected earlier gates.

## Output Format

After completing all gates, produce a quality report and **persist it**:

1. Write the full report to `.tommy/specs/[SPEC_FOLDER]/quality-report.md`.
2. Update the machine-checkable marker `.tommy/.quality-gate-status` (single line, overwritten on every run — it is consumed by the `tommy-quality-sentinel` Stop hook):

```text
status=PASS timestamp=2026-01-01T12:00:00Z files=src/a.ts,src/b.test.ts
```

`status` is the overall result (`PASS`/`FAIL`), `timestamp` is ISO-8601 UTC of when the gates finished, and `files` is the comma-separated, repo-relative list of every file analyzed.

Report template:

```markdown
# Quality Gate Report

**Date**: [TIMESTAMP]
**Files Analyzed**: [list of files]

## Results

| Gate | Status | Details |
| --- | --- | --- |
| 0. Scope & Diff | PASS/FAIL | [summary] |
| 1. Static Analysis | PASS/FAIL | [summary] |
| 2. Tests & Coverage | PASS/FAIL | [coverage %, suites run] |
| 3. Complexity | PASS/FAIL | [max complexity found] |
| 4. Pattern Compliance | PASS/FAIL | [summary] |
| 5. SonarQube | PASS/SKIP/FAIL | [issues found or skip reason] |
| 7. Frontend Audit | PASS/SKIP/FAIL | [a11y violations, CWV lab metrics, or skip reason] |
| 8. Security | PASS/FAIL | [findings resolved/justified] |
| 6. Checklist | PASS/FAIL | [items passed/total] |

## Overall: PASS / FAIL

## Issues Found & Resolved
- [description of issues fixed during the quality gate process]

## Remaining Risks
- [any risks or trade-offs that were accepted]
```

## Integration with Tommy Agents

This skill is designed to be called by the `tommy-codegen` agent as the final validation step after code generation. When invoked by an agent:

1. The agent provides the list of changed/created files.
2. This skill runs all applicable gates on those files.
3. The quality report is persisted (see Output Format) and summarized in the agent's final response.

If any gate fails and cannot be automatically resolved, escalate to the user with a clear description of the issue and suggested resolution options.

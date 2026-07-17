---
name: 'makuco-quality-gate'
description: "Makuco Quality Gate Skill — ensures the quality of generated code through a systematic validation workflow. Use this skill after generating or modifying code, when asked to validate code quality, check for code smells, verify standards compliance, review generated code, run quality checks, or ensure code meets project quality standards. Triggers on: validate code, quality check, review code quality, ensure quality, run quality gate, check code standards, verify code."
---

# Makuco Quality Gate

This skill defines a systematic workflow for validating the quality of generated or modified code. It ensures that every piece of code passes through a series of quality gates before being considered complete, reducing defects and maintaining project standards.

The quality gate is not a single check — it is a pipeline of validations, each building on the previous one. If any gate fails, the issue must be resolved before proceeding to the next gate.

## When to Use

- After generating new code or modifying existing code.
- When the user explicitly asks to validate or review code quality.
- As the final step in a code generation workflow.
- When investigating code smells, complexity issues, or standards violations.

## Rules

- Always run all gates. **NEVER** skip any gate.
- Fill all quality checklist items.
- If any gate fails, identify the issue, fix it, and re-run the gate until it passes.

### Gate 0: Scope Coverage & Diff Analysis

Before starting the quality checks, identify the scope of the changes:

1. Verify if generated/modified files are in the execution plan and match the intended scope.
2. Classify differences as:
   - **Intended changes**: directly related to the execution plan.
   - **Unintended changes**: unrelated modifications that may indicate a problem (e.g., formatting changes, unrelated code modifications).
3. If unintended changes are detected, investigate the root cause before proceeding (e.g., misconfigured formatter, incorrect file paths).

### Gate 1: Static Analysis (Compilation & Linting)

Verify that the code compiles and passes all linting rules configured in the project.

**Steps:**

1. Identify the project's configured linters and compilers (e.g., TypeScript compiler, ESLint, Prettier, Biome, Pylint, Flake8, Rubocop).
2. Run the compiler on the changed files — zero errors is the requirement.
3. Run linters on the changed files — zero errors is the requirement (warnings are acceptable but should be reviewed).
4. If linting auto-fix is available (`--fix`), apply it first, then verify the result.

**How to check:**

- Look for `tsconfig.json`, `eslint.config.*`, `.eslintrc.*`, `.prettierrc`, `biome.json`, `pyproject.toml`, `setup.cfg`, or equivalent configuration files.
- Use Makuco MCP `quality-check(repoRoot, targetPath, fix, cache)` if available.
- Otherwise, run the project's lint/compile scripts directly (e.g., `npm run lint`, `npx tsc --noEmit`).

**Pass criteria:** Zero compilation errors. Zero linting errors.

### Gate 2: Test Execution & Coverage

Ensure that the generated code is properly tested and that existing tests still pass.

**Steps:**

1. Run the full test suite (or the relevant subset for the changed files).
2. Verify all tests pass — zero failures.
3. Check test coverage for the changed files — target at least 80% line coverage.
4. If tests are missing for the generated code, write them before proceeding.

**What to test:**

- Happy path: the expected behavior works correctly.
- Edge cases: boundary values, empty inputs, null/undefined, maximum sizes.
- Error scenarios: invalid inputs, network failures, permission errors.
- Validation rules: all business rules defined in the execution plan.

**Pass criteria:** All tests pass. Coverage on changed files >= 80%.

### Gate 3: Complexity Analysis

Ensure the generated code does not introduce excessive complexity that harms readability and maintainability.

**Steps:**

1. Use Makuco MCP `complexity-check(repoRoot, patterns, maxComplexity, maxLines)` if available.
2. If not available, manually check:
   1. Check cyclomatic complexity of new/modified functions — target max 10 per function.
   2. Check function length — target max 50 lines per function (excluding blank lines and comments).
   3. Check file length — target max 500 lines per file.

**When complexity is too high:**

- Extract helper functions with descriptive names.
- Use early returns to reduce nesting.
- Apply strategy pattern or polymorphism instead of long switch/if chains.
- Break large files into smaller, focused modules.

**Pass criteria:** No function exceeds cyclomatic complexity of 10. No function exceeds 50 lines. No file exceeds 500 lines.

### Gate 4: Code Pattern Compliance

Verify that the generated code follows the project's existing patterns, conventions, and architecture.

**Steps:**

1. Search the codebase for similar code to identify established patterns (naming, structure, error handling, logging).
2. Verify naming conventions match the project:
   - Variable, function, class, file, and folder naming patterns.
   - Use the makuco-ubiquitous-language skill if available to validate domain terms.
3. Verify architectural patterns are respected:
   - Folder structure follows the project's conventions.
   - Dependencies flow in the correct direction.
   - No circular dependencies introduced.
4. Verify error handling follows the project's patterns:
   - Errors are caught and handled consistently.
   - Error messages are clear and actionable.
   - Custom error types are used where the project expects them.

**Pass criteria:** Generated code is indistinguishable in style from existing project code.

### Gate 5: SonarQube Analysis (if applicable)

If the project has SonarQube configured, run an analysis to detect code smells, vulnerabilities, and bugs.

**Steps:**

1. Check for `sonar-project.properties` in the project root.
2. If present, run `sonar-run(repoRoot, targetPath)` via Makuco MCP.
3. After analysis completes, fetch issues with `get-sonar-issues(projectKey, filters)` — filter to only the directories/files that were changed.
4. Fix any new issues introduced by the generated code:
   - **Bugs**: Fix immediately — these are correctness issues.
   - **Vulnerabilities**: Fix immediately — these are security issues.
   - **Code Smells**: Fix unless they conflict with an intentional design decision (document the rationale).
   - **Security Hotspots**: Review and address or mark as safe with justification.

**Pass criteria:** Zero new bugs. Zero new vulnerabilities. Zero new code smells (or documented rationale for accepted smells).

### Gate 6: Checklist Verification

Perform a final review against the project's quality checklist.

**Steps:**

1. Read the checklist created by codegen agent (`.makuco/specs/[SPEC_FOLDER]/checklists/[CHECKLIST_FILE].md`).
2. Evaluate every item in the checklist against the generated code.
3. Mark each item as passed or failed — failed items must be fixed.

**Pass criteria:** All checklist items pass.

## Handling Failures

When a gate fails:

1. Identify the specific issue and its root cause.
2. Fix the issue in the generated code.
3. Re-run the failed gate to confirm the fix.
4. Continue to the next gate only after the current gate passes.
5. If a fix in a later gate could affect an earlier gate (e.g., refactoring to reduce complexity changes test expectations), re-run affected earlier gates.

## Output Format

After completing all gates, produce a quality report:

```markdown
# Quality Gate Report

**Date**: [TIMESTAMP]
**Files Analyzed**: [list of files]

## Results

| Gate | Status | Details |
| --- | --- | --- |
| 1. Static Analysis | PASS/FAIL | [summary] |
| 2. Tests & Coverage | PASS/FAIL | [coverage %] |
| 3. Complexity | PASS/FAIL | [max complexity found] |
| 4. Pattern Compliance | PASS/FAIL | [summary] |
| 5. SonarQube | PASS/SKIP/FAIL | [issues found] |
| 6. Checklist | PASS/FAIL | [items passed/total] |

## Overall: PASS / FAIL

## Issues Found & Resolved
- [description of issues fixed during the quality gate process]

## Remaining Risks
- [any risks or trade-offs that were accepted]
```

## Integration with Makuco Agents

This skill is designed to be called by the `makuco-codegen` agent as the final validation step after code generation. When invoked by an agent:

1. The agent provides the list of changed/created files.
2. This skill runs all gates sequentially on those files.
3. The quality report is returned to the agent for inclusion in the final response.

If any gate fails and cannot be automatically resolved, escalate to the user with a clear description of the issue and suggested resolution options.

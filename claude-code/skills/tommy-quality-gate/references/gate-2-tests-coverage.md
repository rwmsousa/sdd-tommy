# Gate 2: Test Execution & Coverage

Ensure that the generated code is properly tested and that existing tests still pass — across **all** test types the project has, not only unit tests.

## Steps

1. Read `.tommy/codebase/testing.md` to learn the project's test frameworks, suites, and commands (unit, component, integration, e2e). If it is missing, trigger the `tommy-project-research` skill to create it.
2. Run the unit/integration suite (or the relevant subset for the changed files) — zero failures.
3. **Component/E2E suites**: if `testing.md` registers a component or e2e tool (Playwright, Cypress, Detox, Testing Library component suites) and the change touches UI or user-facing flows, run that suite too (or the affected subset). A UI change validated only by unit tests has not passed this gate.
4. Check test coverage for the changed files — target at least 80% line coverage.
5. If tests are missing for the generated code, write them before proceeding.

## What to test

- Happy path: the expected behavior works correctly.
- Edge cases: boundary values, empty inputs, null/undefined, maximum sizes.
- Error scenarios: invalid inputs, network failures, permission errors.
- Validation rules: all business rules defined in the execution plan.
- For UI changes: user-visible interaction flows (via the project's component/e2e tooling).

## Pass criteria

All executed suites pass (unit + the component/e2e suites applicable to the change). Coverage on changed files >= 80%.

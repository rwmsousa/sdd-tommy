# Gate 0: Scope Coverage & Diff Analysis

Before starting the quality checks, identify the scope of the changes.

## Steps

1. Verify if generated/modified files are in the execution plan and match the intended scope.
2. Classify differences as:
   - **Intended changes**: directly related to the execution plan.
   - **Unintended changes**: unrelated modifications that may indicate a problem (e.g., formatting changes, unrelated code modifications).
3. If unintended changes are detected, investigate the root cause before proceeding (e.g., misconfigured formatter, incorrect file paths).

## Pass criteria

Every changed file is either in the plan's scope or has a documented, justified reason to exist in this diff.

# Gate 3: Complexity Analysis

Ensure the generated code does not introduce excessive complexity that harms readability and maintainability.

## Steps

1. Run `.tommy/scripts/quality/complexity-check.sh --json --target <changed-path>` (defaults: cyclomatic complexity max 10, function length max 50 lines; it uses `lizard` when installed).
2. If the script reports **SKIP** (analyzer not installed), check manually:
   1. Cyclomatic complexity of new/modified functions — target max 10 per function.
   2. Function length — target max 50 lines per function (excluding blank lines and comments).
   3. File length — target max 500 lines per file.

## When complexity is too high

- Extract helper functions with descriptive names.
- Use early returns to reduce nesting.
- Apply strategy pattern or polymorphism instead of long switch/if chains.
- Break large files into smaller, focused modules.

## Pass criteria

No function exceeds cyclomatic complexity of 10. No function exceeds 50 lines. No file exceeds 500 lines.

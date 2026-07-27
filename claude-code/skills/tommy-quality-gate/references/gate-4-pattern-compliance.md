# Gate 4: Code Pattern Compliance

Verify that the generated code follows the project's existing patterns, conventions, and architecture.

## Steps

1. Search the codebase for similar code to identify established patterns (naming, structure, error handling, logging).
2. Verify naming conventions match the project:
   - Variable, function, class, file, and folder naming patterns.
   - Use the `tommy-ubiquitous-language` skill if available to validate domain terms.
3. Verify architectural patterns are respected:
   - Folder structure follows the project's conventions.
   - Dependencies flow in the correct direction.
   - No circular dependencies introduced.
4. Verify error handling follows the project's patterns:
   - Errors are caught and handled consistently.
   - Error messages are clear and actionable.
   - Custom error types are used where the project expects them.

## Pass criteria

Generated code is indistinguishable in style from existing project code.

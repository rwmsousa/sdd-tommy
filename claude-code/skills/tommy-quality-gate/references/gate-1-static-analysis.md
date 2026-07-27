# Gate 1: Static Analysis (Compilation & Linting)

Verify that the code compiles and passes all linting rules configured in the project.

## Steps

1. Run `.tommy/scripts/quality/quality-check.sh --json` (add `--fix` to apply auto-fixes first, then re-run without it to confirm). The script detects the stack (Node/TS, Python, Go, Rust) and runs the project's configured lint + type-check.
2. If the script reports **SKIP** (stack detected but no checker configured), fall back to the project's own tooling:
   - Look for `tsconfig.json`, `eslint.config.*`, `.eslintrc.*`, `.prettierrc`, `biome.json`, `pyproject.toml`, `setup.cfg`, or equivalent configuration files.
   - Run the project's lint/compile scripts directly (e.g., `npm run lint`, `npx tsc --noEmit`, `ruff check`).
3. If the script itself is missing, restore the runtime with `npx -y sdd-tommy@latest --sync-runtime`.

## Pass criteria

Zero compilation errors. Zero linting errors (warnings are acceptable but should be reviewed).

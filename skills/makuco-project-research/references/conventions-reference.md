# Conventions Reference

**Purpose:** Document code style and naming conventions.

**Size limit:** 3,000 tokens (~1,800 words)

**Extract from:**

- Analyzing 5-10 representative files
- Identifying consistent patterns
- Observing actual conventions in use

Template and guidance for documenting project conventions in `.makuco/codebase/conventions.md`.

## Template

```markdown
# Conventions

## File Naming

| Context | Convention | Example |
|---------|-----------|---------|
| Components | PascalCase | UserProfile.tsx |
| Services | kebab-case | user-service.ts |
| Tests | same as source + .spec | user-service.spec.ts |
| Types | kebab-case | user-types.ts |
| Constants | kebab-case | app-constants.ts |

## Code Naming

| Element | Convention | Example |
|---------|-----------|---------|
| Variables | camelCase | userName |
| Functions | camelCase | getUserById |
| Classes | PascalCase | OrderService |
| Interfaces | PascalCase (no I prefix) | UserRepository |
| Types | PascalCase | CreateOrderDto |
| Constants | UPPER_SNAKE_CASE | MAX_RETRY_COUNT |
| Enums | PascalCase members | OrderStatus.Pending |

## Import Organization

Describe the import ordering convention:

1. External packages (node_modules)
2. Internal aliases (~/*, @/*)
3. Relative imports (../, ./)
4. Type imports (import type {})

## File Organization Within a Module

Describe how files are typically organized within a single module or domain:

```
module/
├── index.ts          — Public API (barrel file)
├── module.service.ts — Business logic
├── module.controller.ts — HTTP handler
├── module.repository.ts — Data access
├── module.types.ts   — Types and interfaces
├── module.spec.ts    — Tests
└── module.constants.ts — Module-specific constants
```

## Linting & Formatting

| Tool | Config File | Key Rules |
|------|-------------|-----------|
| ESLint | eslint.config.ts | [List 3-5 key non-default rules] |
| Prettier | .prettierrc | [Key settings: semi, singleQuote, tabWidth] |
| EditorConfig | .editorconfig | [indent_style, indent_size] |

## Git Conventions

- **Commit format**: Conventional Commits (feat:, fix:, chore:, refactor:, docs:, test:)
- **Branch naming**: feature/TICKET-123-description, fix/TICKET-456-description
- **PR template**: .github/pull_request_template.md (if exists)

## Error Handling

Describe the project's error handling pattern:

- Custom error classes? (e.g., AppError, NotFoundError)
- Global error handler location?
- Error response format?

## TypeScript Strictness

- **strict mode**: enabled/disabled
- **`any` usage**: forbidden / allowed in specific cases
- **Key tsconfig rules**: strictNullChecks, noImplicitAny, exactOptionalPropertyTypes
```

## Field Guidance

- **Naming**: Document what the codebase actually does, not what you think it should do. If the project mixes conventions, note both patterns and which is dominant.
- **Linting**: Focus on non-default rules that would surprise a new developer. Skip default ESLint rules.
- **Git Conventions**: Check recent commit history (`git log --oneline -20`) to verify the stated convention matches reality.
- **TypeScript Strictness**: Check `tsconfig.json` compilerOptions directly.

## Where to Find This Information

| Source | What it reveals |
|--------|----------------|
| `.eslintrc.*`, `eslint.config.*` | Linting rules |
| `.prettierrc`, `prettier.config.*` | Formatting rules |
| `.editorconfig` | Editor-level formatting |
| `tsconfig.json` compilerOptions | TypeScript strictness |
| Recent git log | Actual commit conventions |
| `.github/` | PR templates, CI workflows |
| Existing source files | Actual naming and file patterns |

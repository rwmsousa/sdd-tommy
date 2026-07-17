---
name: 'tommy-project-research'
description: 'Tommy Project Research Skill — researches and maps a project codebase into structured knowledge files under .tommy/codebase/. Creates architecture.md, concerns.md, conventions.md, integrations.md, stack.md, structure.md, and testing.md. Also fills TOMMY.md with essential project information. Use this skill whenever .tommy/codebase/ files are missing or incomplete, when onboarding to an existing project, when the user asks to map or research a codebase, when setting up Tommy for a new project, or when a GAP is detected in codebase knowledge files. Triggers on: project research, map codebase, codebase analysis, missing codebase files, fill TOMMY.md, onboard project, setup tommy, analyze project structure, detect project stack.'
---

# Tommy Project Research

This skill guides the systematic research and mapping of an existing project's context and codebase into structured knowledge files. These files act as the foundation that all other Tommy agents rely on to understand the project — without them, agents lack the context needed to generate aligned code, architecture decisions, and specifications.

## Why This Matters

Every Tommy agent reads `TOMMY.md`, `.tommy/project-context/`, and `.tommy/codebase/` files to understand the project's goals, scope boundaries, technology, patterns, and constraints. When these files are missing or incomplete (a "GAP"), agents produce generic outputs that don't match the project's reality. This skill exists to close that gap systematically.

## When to Use

- **GAP Detection**: When `.tommy/project-context/` or `.tommy/codebase/` directory is missing, or when expected context/codebase files are absent.
- **Onboarding**: When Tommy is being set up for an existing project for the first time.
- **Refresh**: When the project has changed significantly and codebase files are outdated.
- **TOMMY.md is empty or has placeholders**: When the main guidance file still contains template placeholders like `[Project Name]` or `[brief description]`.

## GAP Detection

Before any Tommy workflow begins, check for these files:

```
.tommy/project-context/
├── architecture_definition_context.md
├── glossary_context.md
├── project_goal_context.md
├── project_management_context.md
├── scope_features_context.md
├── tech_restrictions_context.md
└── tech_stack_context.md
```

and:

```
.tommy/codebase/
├── architecture.md
├── concerns.md
├── conventions.md
├── integrations.md
├── stack.md
├── structure.md
└── testing.md
```

If any required directory or file is missing, trigger this skill to research and create the missing files. Also check if `TOMMY.md` still has unfilled placeholders.

### Step 0: Build Product Context Layer

Before mapping technical codebase details, ensure `.tommy/project-context/` is complete and up to date with the current project reality. Validate and (re)generate:

- `project_goal_context.md`
- `scope_features_context.md`
- `glossary_context.md`
- `tech_stack_context.md`
- `architecture_definition_context.md`
- `tech_restrictions_context.md`
- `project_management_context.md`

This step establishes product boundaries and ubiquitous language before technical mapping.

## Research Workflow

Follow this order — each step builds on the previous one. Do not skip steps even if a file seems obvious; the goal is evidence-based mapping, not assumptions. Read [code-analysis.md](references/code-analysis.md) for techniques on how to analyze the codebase effectively.

### Step 1: Identify the Stack

Research the project's technology stack by examining:

- **Package manifests**: `package.json`, `requirements.txt`, `Pipfile`, `Gemfile`, `go.mod`, `pom.xml`, `build.gradle`, `Cargo.toml`, `*.csproj`
- **Lock files**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`
- **Runtime configs**: `.node-version`, `.nvmrc`, `.python-version`, `.ruby-version`, `.tool-versions`
- **Build configs**: `tsconfig.json`, `webpack.config.*`, `vite.config.*`, `esbuild.*`, `rollup.config.*`, `tsup.config.*`
- **Container configs**: `Dockerfile`, `docker-compose.yml`, `.dockerignore`

Write findings to `.tommy/codebase/stack.md` following the reference template: [references/stack-reference.md](references/stack-reference.md)

### Step 2: Map the Structure

Analyze the project's directory layout and understand how code is organized:

- List the top-level directories and their purpose
- Identify the entry point(s)
- Map path aliases (e.g., `~/` → `src/`, `@/` → `src/`)
- Identify monorepo structure if applicable (workspaces, packages)
- Note any code generation or scaffolding patterns

Write findings to `.tommy/codebase/structure.md` following the reference template: [references/structure-reference.md](references/structure-reference.md)

### Step 3: Discover the Architecture

Research the architectural patterns in use:

- **Pattern identification**: Layered, hexagonal, clean architecture, MVC, CQRS, event-driven, microservices, monolith
- **Component boundaries**: How are domains/modules/features separated?
- **Data flow**: How does data move through the system? (request → controller → service → repository → database)
- **State management**: How is application state handled? (Redux, Zustand, Context, Vuex, MobX, signals)
- **API style**: REST, GraphQL, gRPC, tRPC, WebSocket

Look for these clues:
- Folder structure (e.g., `domains/`, `modules/`, `features/`, `layers/`)
- Base classes or interfaces that define contracts
- Dependency injection patterns
- Middleware chains or pipelines

Write findings to `.tommy/codebase/architecture.md` following the reference template: [references/architecture-reference.md](references/architecture-reference.md)

### Step 4: Map Conventions

Identify the coding conventions enforced or adopted by the project:

- **Linting & formatting**: ESLint rules, Prettier config, Biome, EditorConfig
- **Naming patterns**: File naming (kebab-case, camelCase, PascalCase), variable naming, function naming
- **File organization**: Where do tests go? Where do types go? Co-location vs centralized?
- **Import patterns**: Absolute vs relative, barrel files (index.ts), path aliases
- **Commit conventions**: Conventional commits, branch naming, PR templates
- **Code style**: Functional vs OOP, immutability preferences, error handling patterns

Write findings to `.tommy/codebase/conventions.md` following the reference template: [references/conventions-reference.md](references/conventions-reference.md)

### Step 5: Catalog Integrations

Map all external dependencies and integrations:

- **Databases**: PostgreSQL, MySQL, MongoDB, Redis, SQLite, DynamoDB
- **External APIs**: Third-party services, payment gateways, auth providers (OAuth, SAML)
- **Message brokers**: RabbitMQ, Kafka, SQS, Redis Pub/Sub
- **Cloud services**: AWS, Azure, GCP services in use
- **Monitoring & observability**: Sentry, Datadog, New Relic, Prometheus, Grafana
- **CI/CD**: GitHub Actions, GitLab CI, Azure DevOps, Jenkins
- **Infrastructure as code**: Terraform, Pulumi, CloudFormation

Look for:
- Environment variables (`.env.example`, `.env.sample`)
- Configuration files for external services
- SDK imports and client instantiations
- Docker compose services

Write findings to `.tommy/codebase/integrations.md` following the reference template: [references/integrations-reference.md](references/integrations-reference.md)

### Step 6: Identify Concerns

Map cross-cutting concerns — aspects that affect the entire application rather than a single module:

- **Authentication & authorization**: How are users authenticated? Role-based access? Token management?
- **Logging**: Structured logging? Log levels? Where do logs go?
- **Error handling**: Global error handlers, error response formats, custom error classes
- **Validation**: Input validation approach (Zod, Joi, class-validator, custom)
- **Caching**: Cache strategies, cache invalidation, where caching is applied
- **Internationalization (i18n)**: Multi-language support, translation approach
- **Security**: CORS, CSP, rate limiting, input sanitization, HTTPS enforcement
- **Performance**: Lazy loading, code splitting, pagination strategies

Write findings to `.tommy/codebase/concerns.md` following the reference template: [references/concerns-reference.md](references/concerns-reference.md)

### Step 7: Map Testing

Research the testing approach and infrastructure:

- **Test framework**: Jest, Vitest, Mocha, pytest, RSpec, xUnit, JUnit
- **Test types present**: Unit, integration, e2e, contract, snapshot, visual regression
- **Test location**: Co-located (`*.spec.ts` next to source) vs centralized (`tests/` folder)
- **Naming conventions**: `*.test.ts`, `*.spec.ts`, `*_test.go`, `test_*.py`
- **Mocking approach**: Jest mocks, msw, nock, factory patterns, fixtures
- **Coverage tools**: Istanbul/nyc, c8, coverage.py, SimpleCov
- **E2E tools**: Cypress, Playwright, Selenium, Detox
- **Test scripts**: Available npm/make/gradle tasks for running tests

Write findings to `.tommy/codebase/testing.md` following the reference template: [references/testing-reference.md](references/testing-reference.md)

### Step 8: Fill TOMMY.md

After completing all research, update `TOMMY.md` at the project root with a synthesis of the findings. This file should be concise and serve as the primary guidance for all Tommy agents.

Read the current `TOMMY.md` and replace placeholder sections with real data gathered from the previous steps:

- **What is [Project Name]?** → Actual project name and purpose (from README, package.json description, or code analysis)
- **Tech Stack** → Key technologies from `stack.md`
- **Architecture** → Entry points, domain organization, and key patterns from `architecture.md` and `structure.md`
- **Code Rules** → Critical rules from `conventions.md` (keep it to the 5-10 most important rules)
- **Design System** → UI component library or design system if applicable
- **Key Patterns** → Notable patterns discovered across all research

Keep `TOMMY.md` under 80 lines. It's a summary, not a dump of everything — the detailed files in `.tommy/codebase/` hold the full picture.

## Research Techniques

When investigating a codebase, use these approaches:

1. **Start with manifests**: Package files reveal the stack faster than reading code.
2. **Read configs before code**: Build/lint/test configs reveal patterns and conventions.
3. **Search for patterns**: Use grep/search for import patterns, decorators, base classes.
4. **Follow the entry point**: Trace from the main entry point to understand data flow.
5. **Check CI/CD pipelines**: They reveal build steps, test commands, and deployment targets.
6. **Read existing documentation**: README, CONTRIBUTING, wiki, ADRs (Architecture Decision Records).
7. **Inspect environment variables**: `.env.example` reveals external dependencies.

## Output Quality Rules

- Every claim must be backed by evidence found in the codebase (file paths, configurations, code patterns).
- If something is ambiguous or cannot be determined, state it explicitly rather than guessing.
- Use relative paths from the project root when referencing files.
- Keep each codebase file focused on its domain — avoid duplicating information across files.
- Use consistent markdown formatting across all generated files.

## References

Detailed templates and field descriptions for each codebase file:

- [references/stack-reference.md](references/stack-reference.md) — How to document the technology stack
- [references/structure-reference.md](references/structure-reference.md) — How to document project structure
- [references/architecture-reference.md](references/architecture-reference.md) — How to document architecture
- [references/conventions-reference.md](references/conventions-reference.md) — How to document conventions
- [references/integrations-reference.md](references/integrations-reference.md) — How to document integrations
- [references/concerns-reference.md](references/concerns-reference.md) — How to document cross-cutting concerns
- [references/testing-reference.md](references/testing-reference.md) — How to document testing

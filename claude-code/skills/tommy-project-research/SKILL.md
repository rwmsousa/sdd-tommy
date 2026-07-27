---
name: 'tommy-project-research'
description: 'Tommy Project Research Skill — researches and maps a project codebase into structured knowledge files under .tommy/codebase/. Creates architecture.md, concerns.md, conventions.md, integrations.md, stack.md, structure.md, and testing.md. Also fills .tommy/TOMMY.md with essential project information. Use this skill whenever .tommy/codebase/ files are missing or incomplete, when onboarding to an existing project, when the user asks to map or research a codebase, when setting up Tommy for a new project, or when a GAP is detected in codebase knowledge files. Triggers on: project research, map codebase, codebase analysis, missing codebase files, fill TOMMY.md, onboard project, setup tommy, analyze project structure, detect project stack.'
---

# Tommy Project Research

This skill guides the systematic research and mapping of an existing project's context and codebase into structured knowledge files. These files act as the foundation that all other Tommy agents rely on to understand the project — without them, agents lack the context needed to generate aligned code, architecture decisions, and specifications.

## Why This Matters

Every Tommy agent reads `.tommy/TOMMY.md`, `.tommy/project-context/`, and `.tommy/codebase/` files to understand the project's goals, scope boundaries, technology, patterns, and constraints. When these files are missing or incomplete (a "GAP"), agents produce generic outputs that don't match the project's reality. This skill exists to close that gap systematically.

## When to Use

- **GAP Detection**: When `.tommy/project-context/` or `.tommy/codebase/` directory is missing, or when expected context/codebase files are absent.
- **Onboarding**: When Tommy is being set up for an existing project for the first time.
- **Refresh**: When the project has changed significantly and codebase files are outdated.
- **`.tommy/TOMMY.md` is empty or has placeholders**: When the main guidance file still contains template placeholders like `[Project Name]` or `[brief description]`.

## GAP Detection

**Step -1 — root scaffolding**: If `.tommy/` does not exist at the project root at all, create it now. This is the very first action of a first-time setup — every other file/folder below lives inside it.

Before any Tommy workflow begins, check for these files:

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

and:

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

Also check for the project-level Tommy scaffolding (as described in the root `README.md`, sourced from this repository's `common/` folder):

```
.tommy/
├── TOMMY.md      (created/refreshed in Step 9 below — never at the project root; AGENTS.md is the only file this skill writes outside .tommy/)
├── config.json   (per-project Tommy choices, e.g. MCP wiring — written by /tommy-start's capabilities step, never by sync)
├── mcp.json      (canonical MCP servers for the project — see .tommy/templates/mcp/mcp-catalog.md)
├── resources/    (may be empty — for project-specific reference material)
├── templates/
│   ├── spec-template.md, prompt-template.md, checklist-template.md, prompt-checklist.md, codegen-checklist.md
│   ├── agents-md-template.md
│   ├── sonar-project-reference.properties
│   ├── mcp/      (mcp-catalog.md + mcp-reference.json — MCP wiring rules and curated catalog)
│   └── project-research/    (this skill's own reference templates — code-analysis.md, codebase/*.md, project-context/*.md)
└── scripts/      (create-new-spec.sh, create-new-prompt.sh, create-codegen-checklist.sh, common.sh,
                   quality/quality-check.sh, quality/complexity-check.sh, quality/sonar-run.sh)
```

`config.json` and `mcp.json` are created by the **capabilities step of `/tommy-start`** (opt-in, user-confirmed) — their absence is *not* a GAP for this skill to fill; never create or modify them during research.

If `.tommy/templates/` or `.tommy/scripts/` is missing, restore it by running `npx -y sdd-tommy@latest --sync-runtime` at the project root — do not try to locate or reconstruct these files yourself. This content is tool-agnostic shared infrastructure (also consumed by the GitHub Copilot and Cursor variants of Tommy) and must stay consistent across projects and tools, which is exactly what the installer guarantees. `.tommy/resources/` may legitimately stay empty; do not treat an empty (but present) `resources/` folder as a GAP.

If any required directory or file is missing, trigger this skill to research and create the missing files. Also check if `.tommy/TOMMY.md` still has unfilled placeholders.

## Research Workflow

Follow this order — each step builds on the previous one, and later steps deliberately depend on earlier ones (see Step 8). Do not skip steps even if a file seems obvious; the goal is evidence-based mapping, not assumptions. Read [code-analysis.md](.tommy/templates/project-research/code-analysis.md) for techniques on how to analyze the codebase effectively.

### Step 1: Identify the Stack

Research the project's technology stack by examining:

- **Package manifests**: `package.json`, `requirements.txt`, `Pipfile`, `Gemfile`, `go.mod`, `pom.xml`, `build.gradle`, `Cargo.toml`, `*.csproj`
- **Lock files**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `poetry.lock`
- **Runtime configs**: `.node-version`, `.nvmrc`, `.python-version`, `.ruby-version`, `.tool-versions`
- **Build configs**: `tsconfig.json`, `webpack.config.*`, `vite.config.*`, `esbuild.*`, `rollup.config.*`, `tsup.config.*`
- **Container configs**: `Dockerfile`, `docker-compose.yml`, `.dockerignore`

Write findings to `.tommy/codebase/stack.md` following the reference template: [.tommy/templates/project-research/codebase/stack-reference.md](.tommy/templates/project-research/codebase/stack-reference.md)

### Step 2: Map the Structure

Analyze the project's directory layout and understand how code is organized:

- List the top-level directories and their purpose
- Identify the entry point(s)
- Map path aliases (e.g., `~/` → `src/`, `@/` → `src/`)
- Identify monorepo structure if applicable (workspaces, packages)
- Note any code generation or scaffolding patterns

Write findings to `.tommy/codebase/structure.md` following the reference template: [.tommy/templates/project-research/codebase/structure-reference.md](.tommy/templates/project-research/codebase/structure-reference.md)

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

Write findings to `.tommy/codebase/architecture.md` following the reference template: [.tommy/templates/project-research/codebase/architecture-reference.md](.tommy/templates/project-research/codebase/architecture-reference.md)

### Step 4: Map Conventions

Identify the coding conventions enforced or adopted by the project:

- **Linting & formatting**: ESLint rules, Prettier config, Biome, EditorConfig
- **Naming patterns**: File naming (kebab-case, camelCase, PascalCase), variable naming, function naming
- **File organization**: Where do tests go? Where do types go? Co-location vs centralized?
- **Import patterns**: Absolute vs relative, barrel files (index.ts), path aliases
- **Commit conventions**: Conventional commits, branch naming, PR templates
- **Code style**: Functional vs OOP, immutability preferences, error handling patterns

Write findings to `.tommy/codebase/conventions.md` following the reference template: [.tommy/templates/project-research/codebase/conventions-reference.md](.tommy/templates/project-research/codebase/conventions-reference.md)

### Step 5: Catalog Integrations

Map all external dependencies and integrations:

- **Databases**: PostgreSQL, MySQL, MongoDB, Redis, SQLite, DynamoDB
- **External APIs**: Third-party services, payment gateways, auth providers (OAuth, SAML)
- **Message brokers**: RabbitMQ, Kafka, SQS, Redis Pub/Sub
- **Cloud services**: AWS, Azure, GCP services in use
- **Monitoring & observability**: Sentry, Datadog, New Relic, Prometheus, Grafana
- **CI/CD**: GitHub Actions, GitLab CI, Azure DevOps, Jenkins
- **Infrastructure as code**: Terraform, Pulumi, CloudFormation
- **Git hosting / VCS provider**: run `git remote -v` (or read `.git/config`) and match the `origin` hostname against known patterns — `github.com` → GitHub, `gitlab.com` or a self-hosted host containing `gitlab` → GitLab, `dev.azure.com`/`visualstudio.com` → Azure DevOps. If the hostname doesn't match any known pattern (self-hosted instance, no remote configured yet, or ambiguous/multiple remotes), **ask the user** which provider/tool to use instead of guessing — self-hosted hostnames aren't reliable evidence. Record the answer in the Git Hosting section of `integrations.md` so `tommy-git` can read it later without asking again.

Look for:
- Environment variables (`.env.example`, `.env.sample`)
- Configuration files for external services
- SDK imports and client instantiations
- Docker compose services

Write findings to `.tommy/codebase/integrations.md` following the reference template: [.tommy/templates/project-research/codebase/integrations-reference.md](.tommy/templates/project-research/codebase/integrations-reference.md)

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

Write findings to `.tommy/codebase/concerns.md` following the reference template: [.tommy/templates/project-research/codebase/concerns-reference.md](.tommy/templates/project-research/codebase/concerns-reference.md)

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

Write findings to `.tommy/codebase/testing.md` following the reference template: [.tommy/templates/project-research/codebase/testing-reference.md](.tommy/templates/project-research/codebase/testing-reference.md)

### Step 8: Build the Product Context Layer

With `.tommy/codebase/` now complete, build or refresh `.tommy/project-context/`, each file following its reference template:

| File | Reference template |
|---|---|
| `project_goal_context.md` | [.tommy/templates/project-research/project-context/project-goal-context-reference.md](.tommy/templates/project-research/project-context/project-goal-context-reference.md) |
| `scope_features_context.md` | [.tommy/templates/project-research/project-context/scope-features-context-reference.md](.tommy/templates/project-research/project-context/scope-features-context-reference.md) |
| `glossary_context.md` | [.tommy/templates/project-research/project-context/glossary-context-reference.md](.tommy/templates/project-research/project-context/glossary-context-reference.md) |
| `tech_stack_context.md` | [.tommy/templates/project-research/project-context/tech-stack-context-reference.md](.tommy/templates/project-research/project-context/tech-stack-context-reference.md) |
| `architecture_definition_context.md` | [.tommy/templates/project-research/project-context/architecture-definition-context-reference.md](.tommy/templates/project-research/project-context/architecture-definition-context-reference.md) |
| `tech_restrictions_context.md` | [.tommy/templates/project-research/project-context/tech-restrictions-context-reference.md](.tommy/templates/project-research/project-context/tech-restrictions-context-reference.md) |
| `project_management_context.md` | [.tommy/templates/project-research/project-context/project-management-context-reference.md](.tommy/templates/project-research/project-context/project-management-context-reference.md) |

**This step runs after Steps 1-7 on purpose, not incidentally.** Two of these files are explicitly narrative summaries of codebase files that must already exist for them to summarize instead of re-research:

- `tech_stack_context.md` summarizes `.tommy/codebase/stack.md` and `.tommy/codebase/integrations.md` (Steps 1 and 5) — read those two files and condense them into the business-relevant narrative the template asks for. **Do not re-derive the dependency list from `package.json` again** — that research is already done; re-running it is how the two files drift out of sync and end up duplicating the same exhaustive table under two different headings.
- `architecture_definition_context.md` summarizes `.tommy/codebase/architecture.md` and `.tommy/codebase/structure.md` (Steps 3 and 2) — read those two files for the "how," then add the "why" (rationale, trade-offs, evolution guideline) on top. Don't re-trace the codebase from scratch to restate the "how" a second time.

If either target codebase file is somehow still missing when you reach this step, go back and complete the corresponding earlier step first — never write the narrative version as a substitute for the evidence-derivable one.

The other five files (`project_goal_context.md`, `scope_features_context.md`, `glossary_context.md`, `tech_restrictions_context.md`, `project_management_context.md`) have no codebase-file counterpart to duplicate — they capture product/business boundaries and ubiquitous language that live outside the code.

**This layer is not purely derivable from code.** Several fields are business decisions that only exist in someone's head — business objective, target users, market positioning, roadmap priority, ceremonies, and "decisions not to revert" cannot be reverse-engineered from source code with confidence. Each reference template marks which fields are evidence-derivable and which must be confirmed with the user/product owner. **Never fabricate a business fact to avoid asking a question** — an empty `[NEEDS CONFIRMATION]` placeholder is correct output; a guessed answer presented as fact is not. This mirrors the `tommy-business-analyst` principle of never assuming rules without evidence.

Once `.tommy/project-context/` exists, do not re-ask the user for facts it already answers in later Tommy workflows (specify, architecture, codegen) — read the file instead. Only re-open a question with the user when the file is silent, contradicts the current request, or is stale relative to the codebase.

### Step 9: Fill `.tommy/TOMMY.md`

After completing all research, update `.tommy/TOMMY.md` with a synthesis of the findings (create the file if it doesn't exist yet — inside `.tommy/`, never at the project root). This file should be concise and serve as the primary guidance for all Tommy agents.

Read the current `.tommy/TOMMY.md` and replace placeholder sections with real data gathered from the previous steps:

- **What is [Project Name]?** → Actual project name and purpose (from README, package.json description, or code analysis)
- **Tech Stack** → Key technologies from `stack.md`
- **Architecture** → Entry points, domain organization, and key patterns from `architecture.md` and `structure.md`
- **Code Rules** → Critical rules from `conventions.md` (keep it to the 5-10 most important rules)
- **Design System** → UI component library or design system if applicable
- **Key Patterns** → Notable patterns discovered across all research

Keep `.tommy/TOMMY.md` under 80 lines. It's a summary, not a dump of everything — the detailed files in `.tommy/codebase/` hold the full picture.

### Step 10: Create or Refresh AGENTS.md

Create or refresh `AGENTS.md` **at the project root** (this is the one deliberate exception to "everything Tommy creates lives inside `.tommy/`") from `.tommy/templates/agents-md-template.md`. It has to live at the root because that's the only location Cursor and GitHub Copilot discover it natively — it exists so a teammate opening this same project in one of those tools (instead of Claude Code), possibly without any Tommy-specific config installed, still lands on Tommy's workflow instead of generic, ungrounded suggestions. It is not a replacement for `.tommy/TOMMY.md`: `AGENTS.md` stays short (10-20 lines, no business content) and points to `.tommy/TOMMY.md` and `.tommy/` for detail; do not duplicate `.tommy/TOMMY.md`'s content into it. Since `.tommy/` is typically gitignored while `AGENTS.md` is not, keep `AGENTS.md` free of anything project-sensitive — it's navigation, not context.

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
- Keep each codebase file focused on its domain — avoid duplicating information across files. This applies with extra force to the two pairs that intentionally overlap in subject: `.tommy/codebase/stack.md` + `.tommy/codebase/integrations.md` vs. `.tommy/project-context/tech_stack_context.md`, and `.tommy/codebase/architecture.md` + `.tommy/codebase/structure.md` vs. `.tommy/project-context/architecture_definition_context.md`. The `.tommy/codebase/` side is the exhaustive, evidence-derivable inventory; the `.tommy/project-context/` side is a narrative summary written from it (see Step 8) — never two independently-researched versions of the same table. If they ever disagree, `.tommy/codebase/` is the source of truth.
- Use consistent markdown formatting across all generated files.

## Selective Reading by Other Agents

`.tommy/project-context/` is written once (and refreshed occasionally) but read constantly — every Tommy agent that makes a technical or requirements decision consults it. Reading all 7 files on every invocation wastes context for no benefit: most tasks only need 1-3 of them. Agents must read only the files relevant to what they are currently doing, per this table:

| File | Read by | When |
|---|---|---|
| `project_goal_context.md` | `tommy-business-analyst`, `tommy-specify`, `tommy-product-review` | Always, before eliciting, writing, or reviewing requirements — establishes problem, objective, users, and business context. |
| `scope_features_context.md` | `tommy-business-analyst`, `tommy-specify`, `tommy-product-review` | Always — check the requested feature against the existing roadmap and the "Fora do Escopo" list before treating it as new. |
| `glossary_context.md` | `tommy-business-analyst`, `tommy-specify`, `tommy-architect`, `tommy-codegen`, `tommy-product-review` | Always — domain terms and their EN mapping must stay consistent; pairs with `tommy-ubiquitous-language`. |
| `tech_stack_context.md` | `tommy-architect`, `tommy-prompt`, `tommy-codegen` | When the feature touches a specific technology, integration, or infrastructure decision. For exhaustive dependency versions, prefer `.tommy/codebase/stack.md` and `.tommy/codebase/integrations.md` — this file is the narrative summary, not the inventory. |
| `tech_restrictions_context.md` | `tommy-architect`, `tommy-prompt`, `tommy-codegen` | Always, before proposing any technical approach — this is the one file with hard constraints (forbidden tech, locked decisions) that override generic best practice. |
| `architecture_definition_context.md` | `tommy-architect` | Always when designing architecture for a feature. Captures the "why" behind decisions; `.tommy/codebase/architecture.md` captures the current structural "how." |
| `project_management_context.md` | `tommy-specify`, `tommy-prompt` | When sizing a spec into stories/PBIs or a plan into steps — this file may define project-specific sizing/DoD conventions that override generic defaults (e.g. `tommy-prompt`'s "5-10 files per plan" rule). |

## References

Detailed templates and field descriptions for each codebase file:

- [.tommy/templates/project-research/codebase/stack-reference.md](.tommy/templates/project-research/codebase/stack-reference.md) — How to document the technology stack
- [.tommy/templates/project-research/codebase/structure-reference.md](.tommy/templates/project-research/codebase/structure-reference.md) — How to document project structure
- [.tommy/templates/project-research/codebase/architecture-reference.md](.tommy/templates/project-research/codebase/architecture-reference.md) — How to document architecture
- [.tommy/templates/project-research/codebase/conventions-reference.md](.tommy/templates/project-research/codebase/conventions-reference.md) — How to document conventions
- [.tommy/templates/project-research/codebase/integrations-reference.md](.tommy/templates/project-research/codebase/integrations-reference.md) — How to document integrations
- [.tommy/templates/project-research/codebase/concerns-reference.md](.tommy/templates/project-research/codebase/concerns-reference.md) — How to document cross-cutting concerns
- [.tommy/templates/project-research/codebase/testing-reference.md](.tommy/templates/project-research/codebase/testing-reference.md) — How to document testing

Detailed templates and field descriptions for each product-context file:

- [.tommy/templates/project-research/project-context/project-goal-context-reference.md](.tommy/templates/project-research/project-context/project-goal-context-reference.md) — How to document the project's goal and business context
- [.tommy/templates/project-research/project-context/scope-features-context-reference.md](.tommy/templates/project-research/project-context/scope-features-context-reference.md) — How to document the feature roadmap and scope
- [.tommy/templates/project-research/project-context/glossary-context-reference.md](.tommy/templates/project-research/project-context/glossary-context-reference.md) — How to document the domain glossary
- [.tommy/templates/project-research/project-context/tech-stack-context-reference.md](.tommy/templates/project-research/project-context/tech-stack-context-reference.md) — How to document the business-relevant stack narrative
- [.tommy/templates/project-research/project-context/tech-restrictions-context-reference.md](.tommy/templates/project-research/project-context/tech-restrictions-context-reference.md) — How to document forbidden tech and locked decisions
- [.tommy/templates/project-research/project-context/architecture-definition-context-reference.md](.tommy/templates/project-research/project-context/architecture-definition-context-reference.md) — How to document architecture decisions and rationale
- [.tommy/templates/project-research/project-context/project-management-context-reference.md](.tommy/templates/project-research/project-context/project-management-context-reference.md) — How to document the work management model

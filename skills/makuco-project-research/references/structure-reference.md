# Structure Reference

Template and guidance for documenting the project structure in `.makuco/codebase/structure.md`.

## Template

```markdown
# Project Structure

## Overview

[One paragraph describing how the project is organized — monorepo or single-repo, what the top-level folders represent, and the organizing principle (by feature, by layer, by domain, etc.)]

## Top-Level Layout

```
project-root/
├── src/              — Application source code
├── tests/            — Test files (if not co-located)
├── docs/             — Documentation
├── scripts/          — Build and utility scripts
├── config/           — Configuration files
├── public/           — Static assets (frontend)
└── infra/            — Infrastructure definitions
```

## Entry Points

| Entry Point | Path | Purpose |
|-------------|------|---------|
| Main        | src/index.ts | Application bootstrap |
| CLI         | src/cli.ts   | Command-line interface |
| Worker      | src/worker.ts | Background job processor |

## Source Code Organization

Describe the internal structure of the source code directory:

```
src/
├── domains/          — Business domains (one folder per bounded context)
│   ├── orders/
│   │   ├── services/
│   │   ├── models/
│   │   └── repositories/
│   └── customers/
├── shared/           — Shared utilities, types, and helpers
├── infra/            — Infrastructure adapters (database, HTTP, messaging)
└── config/           — App configuration and environment
```

## Path Aliases

| Alias | Resolves To | Configured In |
|-------|-------------|---------------|
| ~/    | src/        | tsconfig.json |
| @/    | src/        | vite.config.ts |

## Monorepo Structure (if applicable)

| Package | Path | Purpose |
|---------|------|---------|
| @app/api | packages/api | Backend API |
| @app/web | packages/web | Frontend app |
| @app/shared | packages/shared | Shared types and utils |

## Generated / Build Artifacts

| Directory | Purpose | In .gitignore? |
|-----------|---------|----------------|
| dist/     | Compiled output | Yes |
| .next/    | Next.js build cache | Yes |
| coverage/ | Test coverage reports | Yes |
```

## Field Guidance

- **Top-Level Layout**: Only include directories that actually exist. Mark each with a brief `—` description.
- **Entry Points**: List all files that bootstrap the application or serve as starting points for execution.
- **Path Aliases**: These are critical for agents to resolve imports correctly. Check `tsconfig.json` paths, `vite.config.ts` resolve.alias, webpack aliases.
- **Monorepo**: Only include this section if the project uses workspaces. Check `package.json` workspaces field, `pnpm-workspace.yaml`, or `lerna.json`.

## Where to Find This Information

| Source | What it reveals |
|--------|----------------|
| Root directory listing | Top-level organization |
| `package.json` `main`, `bin`, `exports` | Entry points |
| `tsconfig.json` `paths` | TypeScript path aliases |
| `vite.config.*` / `webpack.config.*` | Build-time aliases |
| `package.json` `workspaces` | Monorepo packages |
| `.gitignore` | Generated/build directories |

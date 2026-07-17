# Architecture Reference

**Purpose:** Document architectural patterns and data flow.

**Size limit:** 4,000 tokens (~2,400 words)

**Extract from:**

- Directory organization
- Code structure analysis
- Repeated patterns across files

Template and guidance for documenting the project architecture in `.makuco/codebase/architecture.md`.

## Template

```markdown
# Architecture

## Pattern

**Primary pattern**: [Layered / Hexagonal / Clean Architecture / MVC / CQRS / Event-Driven / Microservices / Modular Monolith]

[Brief explanation of how the pattern is applied in this specific project — not a textbook definition, but how this codebase interprets the pattern.]

## Layers / Boundaries

Describe the logical layers and their responsibilities:

| Layer | Responsibility | Example Path |
|-------|---------------|--------------|
| Presentation | HTTP handlers, controllers, resolvers | src/controllers/ |
| Application | Use cases, orchestration, DTOs | src/services/ |
| Domain | Business rules, entities, value objects | src/models/ |
| Infrastructure | Database, external APIs, messaging | src/infra/ |

## Data Flow

Describe how a typical request moves through the system:

```
Client Request
  → Router (src/routes/)
    → Middleware (auth, validation)
      → Controller (src/controllers/)
        → Service (src/services/)
          → Repository (src/repositories/)
            → Database
```

## API Style

- **Type**: REST / GraphQL / gRPC / tRPC / WebSocket
- **Base path**: /api/v1
- **Documentation**: Swagger at /api/docs (if applicable)
- **Authentication**: Bearer token / Session / API key

## State Management (Frontend)

- **Library**: Redux / Zustand / Context / Vuex / Pinia / Signals
- **Pattern**: Centralized store / Atomic state / Server-state (React Query, SWR)
- **Location**: src/store/ or co-located with features

## Domain Boundaries

Map how the project separates business domains:

| Domain | Path | Core Responsibility |
|--------|------|---------------------|
| Orders | src/domains/orders/ | Order lifecycle management |
| Auth   | src/domains/auth/   | Authentication and authorization |

## Key Architectural Decisions

List notable decisions that affect how code should be written (look for ADRs in docs/adr/ or ARCHITECTURE.md):

- [Decision]: [Rationale]
- [Decision]: [Rationale]
```

## Field Guidance

- **Pattern**: Don't force a pattern name if the codebase is mixed. Describe what you actually see, not what you think it should be.
- **Data Flow**: Use an ASCII diagram showing the actual flow. Trace a real request from entry to database.
- **Domain Boundaries**: This is useful for agents to know which folder to modify for a given feature. Map every bounded context or module.
- **Key Architectural Decisions**: These prevent agents from accidentally violating design choices. Look for ADR files, ARCHITECTURE.md, or comments in code.

## Where to Find This Information

| Source | What it reveals |
|--------|----------------|
| Folder naming (`controllers/`, `services/`, `repositories/`) | Layered architecture cues |
| `ports/` and `adapters/` folders | Hexagonal architecture cues |
| Decorator usage (`@Controller`, `@Injectable`) | Framework-driven architecture |
| Route definitions | API style and endpoint organization |
| State management imports | Frontend state approach |
| ADR files, ARCHITECTURE.md | Explicit architectural decisions |
| Base classes / interfaces | Contract definitions and layer separation |

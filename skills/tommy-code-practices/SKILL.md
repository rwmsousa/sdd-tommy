---
name: tommy-code-practices
description: "Defines and enforces code development best practices, architecture patterns, and design patterns. Use when generating code, reviewing code quality, selecting design patterns, making architectural decisions, or when code needs to follow established engineering practices. Triggers on: code generation, design pattern, best practice, architecture decision, code review, refactoring, SOLID principles, clean code, DRY, YAGNI."
---

# Tommy Code Practices

This skill guides code development decisions based on established engineering principles and best practices. The goal is to produce code that is readable, maintainable, testable, and aligned with the project's architecture.

## Core Principles

### SOLID Principles
- **Single Responsibility**: Each class/module should have one reason to change.
- **Open/Closed**: Open for extension, closed for modification.
- **Liskov Substitution**: Subtypes must be substitutable for their base types.
- **Interface Segregation**: Many specific interfaces are better than one general interface.
- **Dependency Inversion**: Depend on abstractions, not concretions.

### Clean Code Rules
- **DRY** (Don't Repeat Yourself): Every piece of knowledge must have a single, unambiguous representation.
- **YAGNI** (You Aren't Gonna Need It): Don't implement features until they are actually needed.
- **KISS** (Keep It Simple, Stupid): Simple solutions are preferred over complex ones.
- **Meaningful names**: Variables, functions, and classes should reveal intent.
- **Small functions**: Functions should do one thing, and do it well (max ~20 lines).
- **No magic numbers**: Use named constants instead of raw values.

## Architecture Patterns

### Layered Architecture
- Presentation → Application → Domain → Infrastructure
- Dependencies flow inward only
- Domain layer has no external dependencies

### Clean/Hexagonal Architecture
- Core business logic isolated from frameworks and I/O
- Ports define contracts; adapters implement them
- Easy to test without external dependencies

### Domain-Driven Design (DDD)
- Aggregate roots control consistency boundaries
- Entities have identity; Value Objects are defined by their values
- Domain events communicate between bounded contexts
- Repositories abstract persistence

## Code Quality Guidelines

### Error Handling
- Always handle errors explicitly; never silently swallow exceptions.
- Use typed errors when the project supports it.
- Provide meaningful error messages with context.
- Distinguish between expected errors (user input) and unexpected errors (system failures).

### Testing
- Write tests before fixing bugs (reproduce first).
- Test behavior, not implementation details.
- Use the AAA pattern: Arrange, Act, Assert.
- One assertion per test when possible.
- Mock external dependencies, not internal logic.

### Naming Conventions
- Follow the project's existing naming conventions (check `.tommy/codebase/conventions.md`).
- Use verbs for functions (`getUserById`, `calculateTotal`).
- Use nouns for classes and interfaces (`UserRepository`, `OrderService`).
- Prefix booleans with `is`, `has`, `can`, `should` (`isActive`, `hasPermission`).

### Code Organization
- Group related code together (cohesion).
- Keep files focused (max ~300-500 lines).
- Avoid deep nesting (max 3-4 levels).
- Prefer composition over inheritance.

## When to Apply Each Pattern

| Pattern | When to Use |
|---|---|
| Repository | Abstracting data access |
| Factory | Complex object creation |
| Strategy | Interchangeable algorithms |
| Observer/Event | Decoupled cross-cutting concerns |
| Decorator | Adding behavior without modifying source |
| Command | Encapsulating operations (undo/redo, queuing) |
| Facade | Simplifying complex subsystems |

## Code Review Checklist

- [ ] Code follows project naming conventions
- [ ] No duplicate logic (DRY)
- [ ] Functions are small and focused
- [ ] Error cases are handled
- [ ] Tests cover happy path and edge cases
- [ ] No magic numbers or strings
- [ ] No commented-out code
- [ ] No TODOs without associated tickets
- [ ] Dependencies are injected, not hardcoded
- [ ] No circular dependencies introduced

> **Note**: Always check `.tommy/codebase/conventions.md` for project-specific overrides to these general practices.

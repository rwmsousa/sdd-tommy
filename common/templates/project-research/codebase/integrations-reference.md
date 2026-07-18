# Integrations Reference

Template and guidance for documenting project integrations in `.tommy/codebase/integrations.md`.

## Template

```markdown
# Integrations

## Databases

| Database | Client/ORM | Config Location | Purpose |
|----------|-----------|-----------------|---------|
| PostgreSQL | Prisma | prisma/schema.prisma | Primary data store |
| Redis | ioredis | src/config/redis.ts | Caching and sessions |

## External APIs

| Service | SDK/Client | Base URL Env Var | Purpose |
|---------|-----------|------------------|---------|
| Stripe | @stripe/stripe-node | STRIPE_API_URL | Payment processing |
| SendGrid | @sendgrid/mail | SENDGRID_API_KEY | Transactional emails |

## Authentication Providers

| Provider | Protocol | Config Location | Purpose |
|----------|----------|-----------------|---------|
| Auth0 | OAuth 2.0 / OIDC | src/config/auth.ts | User authentication |
| Google | OAuth 2.0 | .env (GOOGLE_CLIENT_ID) | Social login |

## Message Brokers / Queues

| Broker | Client | Config Location | Purpose |
|--------|--------|-----------------|---------|
| RabbitMQ | amqplib | src/infra/messaging/ | Async event processing |
| SQS | @aws-sdk/client-sqs | src/config/aws.ts | Background jobs |

## Cloud Services

| Service | SDK | Purpose |
|---------|-----|---------|
| S3 | @aws-sdk/client-s3 | File storage |
| CloudWatch | @aws-sdk/client-cloudwatch | Monitoring |

## Git Hosting (VCS Provider)

| Field | Value |
|-------|-------|
| Provider | GitHub / GitLab / Azure DevOps / Other |
| Remote host | e.g. github.com, gitlab.company.com, dev.azure.com |
| Self-hosted | Yes/No |
| PR/MR CLI | gh / glab / az repos |
| Default branch | main / master / develop |

## CI/CD

| Platform | Config File | Key Stages |
|----------|-------------|------------|
| GitHub Actions | .github/workflows/*.yml | lint, test, build, deploy |
| Azure DevOps | azure-pipelines.yml | build, test, deploy |

## Monitoring & Observability

| Tool | Integration Point | Purpose |
|------|-------------------|---------|
| Sentry | src/config/sentry.ts | Error tracking |
| Datadog | dd-trace import | APM and tracing |

## Environment Variables

List the key environment variables that configure integrations (from .env.example or similar):

| Variable | Integration | Required |
|----------|-------------|----------|
| DATABASE_URL | PostgreSQL | Yes |
| REDIS_URL | Redis | Yes |
| STRIPE_SECRET_KEY | Stripe | Yes |
| SENTRY_DSN | Sentry | No |
```

## Field Guidance

- **Config Location**: Point to the actual file where the integration is configured or the client is instantiated.
- **Base URL Env Var**: For external APIs, note which environment variable holds the URL — this prevents hardcoded values.
- **Environment Variables**: Only list variables related to integrations. General app config (PORT, NODE_ENV) belongs in conventions.
- **Required**: Mark whether the integration is required for the app to start or optional (graceful degradation).
- **Git Hosting**: Unlike the rest of this file, the provider isn't always safely derivable from evidence alone — a self-hosted GitLab or Azure DevOps instance won't necessarily have a recognizable hostname. If the remote hostname doesn't unambiguously match a known provider, confirm it with the user instead of guessing. This field exists so `tommy-git` can read it once here instead of asking on every commit/PR.

## Where to Find This Information

| Source | What it reveals |
|--------|----------------|
| `.env.example`, `.env.sample` | Required environment variables |
| `docker-compose.yml` | Infrastructure dependencies (DB, Redis, queues) |
| Package dependencies | SDKs and clients in use |
| `src/config/`, `src/infra/` | Integration configuration code |
| CI/CD pipeline files | Build and deployment integrations |
| Import statements for SDKs | Which services are actually used in code |
| `git remote -v` / `.git/config` | Git hosting provider and remote host |

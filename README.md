# Tommy

**English** | [Português](#tommy-pt-br)

Spec-driven development for **Claude Code**, **Cursor**, and **GitHub Copilot**: every feature goes **Specify → Prompt → Codegen**, every bug goes **Assess → Fix → Verify**, each step with its own quality gate.

## Prerequisites

| Tool | Why | Installed by |
| --- | --- | --- |
| Node.js ≥ 18.20 | runs the installer | you |
| git, bash, jq | branches, `.tommy/scripts`, quality-gate hook | you (Windows: Git Bash or WSL) |
| [uv](https://docs.astral.sh/uv/) | installs Graphify | the Tommy installer |
| [Graphify](https://github.com/Graphify-Labs/graphify) (`graphifyy`) | code knowledge graph — agents query it before grepping | the Tommy installer |
| [RTK](https://github.com/rtk-ai/rtk) | compresses command output before it reaches the agent | the Tommy installer |

Check your machine at any time:

```bash
npx sdd-tommy@latest --doctor
```

If uv/Graphify/RTK can't be installed (no permission, Windows, offline), Tommy still works — without the code graph and output compression.

## Install

Run it in your project's root folder:

```bash
npx sdd-tommy@latest
```

1. Pick the tools (Claude Code, Cursor, Copilot — more than one is fine).
2. Confirm the project folder.
3. Confirm the prerequisites step (installs uv, Graphify, RTK in `~/.local/bin` and wires them into the selected tools).

Where things go: Claude Code → `~/.claude/` (global) · Cursor → `.cursor/` · Copilot → `.github/` · shared runtime → `.tommy/` (per project). Existing configs are merged, never overwritten, and backed up before any change. Running it again updates everything safely.

Restore only the project runtime (scripts + templates): `npx sdd-tommy@latest --sync-runtime`.

## Step by step

| # | Step | Claude Code | Cursor | Copilot Chat |
| --- | --- | --- | --- | --- |
| 0 | Bootstrap (once per project) | `/tommy-start` | `@tommy-start` | `/tommy-start` |
| 1 | Specify | `/tommy-specify <feature>` | `@tommy-specify <feature>` | `/tommy-specify` |
| 2 | Plan | `/tommy-prompt <spec.md>` | `@tommy-prompt <spec.md>` | `/tommy-prompt` |
| 3 | Code (one plan at a time) | `/tommy-run-codegen <plan.md>` | `@tommy-codegen <plan.md>` | `/tommy-codegen` |
| — | Fix a bug | `/tommy-bugfix <bug>` | `@tommy-bugfix <bug>` | `/tommy-bugfix` |
| — | Commit / open PR | `/tommy-commit` · `/tommy-open-pr` | `@tommy-commit` · `@tommy-open-pr` | `/tommy-commit` · `/tommy-open-pr` |

What each step does, and what you do:

0. **Bootstrap** — checks prerequisites, builds the code graph, maps the codebase into `.tommy/`, and records the project principles (MUST/SHOULD). **You:** answer the `[NEEDS CONFIRMATION]` questions and confirm the principles.
1. **Specify** — asks questions in rounds (each with a recommended answer — reply "yes" to accept), writes `.tommy/specs/NNN-feature/spec.md` with a decision log, and an independent review marks the checklists. **You:** answer the questions and read the spec. To refine an existing spec later: `/tommy-specify <path to spec.md>`.
2. **Plan** — designs the architecture and writes `plans/*.md`, mapping every requirement to a step; an independent analysis blocks the plan if a requirement is uncovered or a MUST principle is broken. **You:** review blocking decisions.
3. **Code** — implements the plan, writes tests, runs the quality gate (lint, tests, complexity, patterns, Sonar, frontend audit, security), then checks the code against the spec (`checklists/acceptance.md`) until it converges. **You:** review the code and approve or reject any change nobody asked for.
- **Bugfix** — reproduces the bug and finds the root cause, asks you to confirm the fix, writes a failing regression test first, fixes, verifies (`verified` / `partial` / `failed`).
- **Commit / PR** — only when you ask: Conventional Commits, provider detected automatically (GitHub, GitLab, Azure DevOps).

## Project files

```
.tommy/
├── TOMMY.md, project-context/, codebase/   project knowledge (bootstrap)
├── specs/NNN-feature/                       spec.md, plans/, checklists/, architecture/
├── bugs/NNN-bug/                            bug.md, quality-report.md
├── scripts/, templates/                     runtime (customize templates in templates/overrides/)
└── mcp.json, config.json                    project MCP servers
AGENTS.md                                    short pointer for the agents (project root)
graphify-out/                                code graph (git-ignored locally)
```

## Tips

- Give the Specify step as much detail as you can; the spec drives everything after it.
- Use one chat per plan in the Code step to keep the context window clean.
- Copilot in VS Code: start a new chat after each code generation.

More: [WORKFLOW.md](./WORKFLOW.md) (flow diagram) · [claude-code/](./claude-code/README.md) · [cursor/](./cursor/README.md) · [github-copilot/](./github-copilot/README.md) · [CHANGELOG.md](./CHANGELOG.md)

---

# Tommy (PT-BR)

[English](#tommy) | **Português**

Desenvolvimento orientado a especificação para **Claude Code**, **Cursor** e **GitHub Copilot**: toda feature passa por **Specify → Prompt → Codegen**, todo bug por **Avaliar → Corrigir → Verificar**, cada etapa com seu próprio quality gate.

## Pré-requisitos

| Ferramenta | Para quê | Quem instala |
| --- | --- | --- |
| Node.js ≥ 18.20 | roda o instalador | você |
| git, bash, jq | branches, `.tommy/scripts`, hook do quality gate | você (Windows: Git Bash ou WSL) |
| [uv](https://docs.astral.sh/uv/) | instala o Graphify | o instalador do Tommy |
| [Graphify](https://github.com/Graphify-Labs/graphify) (`graphifyy`) | grafo de conhecimento do código — os agentes consultam antes de fazer grep | o instalador do Tommy |
| [RTK](https://github.com/rtk-ai/rtk) | comprime a saída dos comandos antes de chegar ao agente | o instalador do Tommy |

Verifique sua máquina a qualquer momento:

```bash
npx sdd-tommy@latest --doctor
```

Se uv/Graphify/RTK não puderem ser instalados (sem permissão, Windows, offline), o Tommy continua funcionando — só sem o grafo de código e sem a compressão de saída.

## Instalação

Rode na raiz do seu projeto:

```bash
npx sdd-tommy@latest
```

1. Escolha as ferramentas (Claude Code, Cursor, Copilot — pode mais de uma).
2. Confirme a pasta do projeto.
3. Confirme a etapa de pré-requisitos (instala uv, Graphify e RTK em `~/.local/bin` e os conecta às ferramentas escolhidas).

Para onde vai cada coisa: Claude Code → `~/.claude/` (global) · Cursor → `.cursor/` · Copilot → `.github/` · runtime compartilhado → `.tommy/` (por projeto). Configurações existentes são mescladas, nunca sobrescritas, com backup antes de qualquer mudança. Rodar de novo atualiza tudo com segurança.

Restaurar só o runtime do projeto (scripts + templates): `npx sdd-tommy@latest --sync-runtime`.

## Passo a passo

| # | Etapa | Claude Code | Cursor | Copilot Chat |
| --- | --- | --- | --- | --- |
| 0 | Bootstrap (uma vez por projeto) | `/tommy-start` | `@tommy-start` | `/tommy-start` |
| 1 | Especificar | `/tommy-specify <feature>` | `@tommy-specify <feature>` | `/tommy-specify` |
| 2 | Planejar | `/tommy-prompt <spec.md>` | `@tommy-prompt <spec.md>` | `/tommy-prompt` |
| 3 | Codificar (um plano por vez) | `/tommy-run-codegen <plano.md>` | `@tommy-codegen <plano.md>` | `/tommy-codegen` |
| — | Corrigir um bug | `/tommy-bugfix <bug>` | `@tommy-bugfix <bug>` | `/tommy-bugfix` |
| — | Commit / abrir PR | `/tommy-commit` · `/tommy-open-pr` | `@tommy-commit` · `@tommy-open-pr` | `/tommy-commit` · `/tommy-open-pr` |

O que cada etapa faz, e o que você faz:

0. **Bootstrap** — verifica os pré-requisitos, gera o grafo de código, mapeia o projeto em `.tommy/` e registra os princípios do projeto (MUST/SHOULD). **Você:** responde as perguntas `[NEEDS CONFIRMATION]` e confirma os princípios.
1. **Especificar** — faz perguntas em rodadas (cada uma com resposta recomendada — responda "sim" para aceitar), escreve `.tommy/specs/NNN-feature/spec.md` com log de decisões, e uma revisão independente marca os checklists. **Você:** responde as perguntas e lê a spec. Para refinar uma spec existente depois: `/tommy-specify <caminho do spec.md>`.
2. **Planejar** — desenha a arquitetura e escreve `plans/*.md`, ligando cada requisito a uma etapa; uma análise independente bloqueia o plano se algum requisito ficar sem cobertura ou um princípio MUST for violado. **Você:** revisa as decisões bloqueantes.
3. **Codificar** — implementa o plano, escreve testes, roda o quality gate (lint, testes, complexidade, padrões, Sonar, auditoria de frontend, segurança) e confere o código contra a spec (`checklists/acceptance.md`) até convergir. **Você:** revisa o código e aprova ou rejeita qualquer mudança que ninguém pediu.
- **Bugfix** — reproduz o bug e acha a causa raiz, pede sua confirmação da correção, escreve primeiro um teste de regressão que falha, corrige e verifica (`verified` / `partial` / `failed`).
- **Commit / PR** — só quando você pede: Conventional Commits, provedor detectado automaticamente (GitHub, GitLab, Azure DevOps).

## Arquivos no projeto

```
.tommy/
├── TOMMY.md, project-context/, codebase/   conhecimento do projeto (bootstrap)
├── specs/NNN-feature/                       spec.md, plans/, checklists/, architecture/
├── bugs/NNN-bug/                            bug.md, quality-report.md
├── scripts/, templates/                     runtime (customize templates em templates/overrides/)
└── mcp.json, config.json                    servidores MCP do projeto
AGENTS.md                                    ponteiro curto para os agentes (raiz do projeto)
graphify-out/                                grafo de código (ignorado no git localmente)
```

## Dicas

- Dê o máximo de detalhe na etapa Especificar; a spec guia tudo o que vem depois.
- Use um chat por plano na etapa Codificar, para manter a janela de contexto limpa.
- Copilot no VS Code: abra um chat novo após cada geração de código.

Mais: [WORKFLOW.md](./WORKFLOW.md) (diagrama do fluxo) · [claude-code/](./claude-code/README.md) · [cursor/](./cursor/README.md) · [github-copilot/](./github-copilot/README.md) · [CHANGELOG.md](./CHANGELOG.md)

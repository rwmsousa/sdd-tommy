# Tommy

**English** | [Português](#tommy-pt-br)

Spec-driven development for **Claude Code**, **Cursor**, and **GitHub Copilot**. Describe what you need, answer a few questions, approve the spec — Tommy plans, writes the code and tests, and checks the result against the spec.

## Requirements

- Node.js ≥ 18.20, git, bash, jq (Windows: Git Bash or WSL).
- Optional, offered by the installer: [uv](https://docs.astral.sh/uv/), [Graphify](https://github.com/Graphify-Labs/graphify) (code graph) and [RTK](https://github.com/rtk-ai/rtk) (compressed command output). Tommy works without them.

Check your machine: `npx sdd-tommy@latest --doctor`

## Install

In your project's root folder:

```bash
npx sdd-tommy@latest
```

Pick the tools you use (more than one is fine) and confirm. Existing configs are merged and backed up, never overwritten.

## Use

**1. Once per project** — map the project into `.tommy/`:

```
/tommy-start
```

**2. For each feature or bug** — say what you need:

```
/tommy add password reset by email
```

- Answer the questions. Each comes with a recommended answer — reply "yes" to accept it.
- Read the spec and **approve it**. That is the only approval.
- Tommy then runs on its own: architecture, plans, code, tests, quality gate, and a final check against the spec. It only stops if it hits a decision the spec doesn't answer.
- At the end you get a report with the files changed, the test results, and anything to verify manually.

**3. When you're happy with the result**:

```
/tommy-commit
/tommy-open-pr
```

Tommy never commits or pushes on its own.

| | Claude Code | Cursor | Copilot Chat |
| --- | --- | --- | --- |
| Set up the project | `/tommy-start` | `@tommy-start` | `/tommy-start` |
| Feature or bug | `/tommy <request>` | `@tommy <request>` | `/tommy <request>` |
| Resume an interrupted run | `/tommy <path to spec.md>` | `@tommy <path to spec.md>` | `/tommy <path to spec.md>` |
| Commit / open PR | `/tommy-commit` · `/tommy-open-pr` | `@tommy-commit` · `@tommy-open-pr` | `/tommy-commit` · `/tommy-open-pr` |

Prefer to run one phase at a time? The manual commands are still there: `tommy-specify` → `tommy-prompt` → `tommy-run-codegen` (`tommy-codegen` in Cursor/Copilot), and `tommy-bugfix`.

## Tips

- The more detail in your request, the fewer questions you get.
- Everything Tommy produces lives in `.tommy/specs/<feature>/` (spec, plans, checklists) — review it there.
- Copilot in VS Code: start a new chat for each request.

## Update

When a new version comes out ([CHANGELOG](./CHANGELOG.md)), run the installer again in each project and pick the same tools:

```bash
npx sdd-tommy@latest
```

Then restart your tool. Your specs, bugs, and project knowledge in `.tommy/` are not touched; any Tommy file you edited is saved as `<file>.tommy-backup-<timestamp>` before being replaced (keep template customizations in `.tommy/templates/overrides/`). Claude Code is installed globally (`~/.claude/`), so one run updates it for every project.

More: [WORKFLOW.md](./WORKFLOW.md) (how the flow works) · [claude-code/](./claude-code/README.md) · [cursor/](./cursor/README.md) · [github-copilot/](./github-copilot/README.md)

---

# Tommy (PT-BR)

[English](#tommy) | **Português**

Desenvolvimento orientado a especificação para **Claude Code**, **Cursor** e **GitHub Copilot**. Descreva o que precisa, responda algumas perguntas, aprove a spec — o Tommy planeja, escreve o código e os testes e confere o resultado contra a spec.

## Requisitos

- Node.js ≥ 18.20, git, bash, jq (Windows: Git Bash ou WSL).
- Opcionais, oferecidos pelo instalador: [uv](https://docs.astral.sh/uv/), [Graphify](https://github.com/Graphify-Labs/graphify) (grafo de código) e [RTK](https://github.com/rtk-ai/rtk) (saída de comandos comprimida). O Tommy funciona sem eles.

Confira sua máquina: `npx sdd-tommy@latest --doctor`

## Instalação

Na raiz do seu projeto:

```bash
npx sdd-tommy@latest
```

Escolha as ferramentas que você usa (pode mais de uma) e confirme. Configurações existentes são mescladas e ganham backup, nunca são sobrescritas.

## Uso

**1. Uma vez por projeto** — mapeia o projeto em `.tommy/`:

```
/tommy-start
```

**2. Para cada feature ou bug** — diga o que precisa:

```
/tommy adicionar redefinição de senha por e-mail
```

- Responda as perguntas. Cada uma vem com uma resposta recomendada — responda "sim" para aceitá-la.
- Leia a spec e **aprove**. É a única aprovação.
- A partir daí o Tommy segue sozinho: arquitetura, planos, código, testes, quality gate e uma conferência final contra a spec. Ele só para se encontrar uma decisão que a spec não responde.
- No fim você recebe um relatório com os arquivos alterados, o resultado dos testes e o que precisa ser verificado manualmente.

**3. Quando estiver satisfeito com o resultado**:

```
/tommy-commit
/tommy-open-pr
```

O Tommy nunca faz commit nem push por conta própria.

| | Claude Code | Cursor | Copilot Chat |
| --- | --- | --- | --- |
| Preparar o projeto | `/tommy-start` | `@tommy-start` | `/tommy-start` |
| Feature ou bug | `/tommy <pedido>` | `@tommy <pedido>` | `/tommy <pedido>` |
| Retomar uma execução interrompida | `/tommy <caminho do spec.md>` | `@tommy <caminho do spec.md>` | `/tommy <caminho do spec.md>` |
| Commit / abrir PR | `/tommy-commit` · `/tommy-open-pr` | `@tommy-commit` · `@tommy-open-pr` | `/tommy-commit` · `/tommy-open-pr` |

Prefere rodar uma fase por vez? Os comandos manuais continuam disponíveis: `tommy-specify` → `tommy-prompt` → `tommy-run-codegen` (`tommy-codegen` no Cursor/Copilot), e `tommy-bugfix`.

## Dicas

- Quanto mais detalhe no pedido, menos perguntas.
- Tudo o que o Tommy produz fica em `.tommy/specs/<feature>/` (spec, planos, checklists) — revise por lá.
- Copilot no VS Code: abra um chat novo para cada pedido.

## Atualização

Quando sair uma versão nova ([CHANGELOG](./CHANGELOG.md)), rode o instalador de novo em cada projeto e escolha as mesmas ferramentas:

```bash
npx sdd-tommy@latest
```

Depois reinicie a ferramenta. Suas specs, bugs e o conhecimento do projeto em `.tommy/` não são tocados; um arquivo do Tommy que você editou é salvo como `<arquivo>.tommy-backup-<timestamp>` antes de ser substituído (guarde personalizações de template em `.tommy/templates/overrides/`). O Claude Code é instalado globalmente (`~/.claude/`), então uma execução já o atualiza para todos os projetos.

Mais: [WORKFLOW.md](./WORKFLOW.md) (como o fluxo funciona) · [claude-code/](./claude-code/README.md) · [cursor/](./cursor/README.md) · [github-copilot/](./github-copilot/README.md)

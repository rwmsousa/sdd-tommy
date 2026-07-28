# Tommy for Claude Code

Este é o conjunto de arquivos mais completo do Tommy — os únicos com subagentes de verdade (`tools:` restrito por papel) e skills disparadas por descrição. É instalado **globalmente**, valendo para todos os projetos abertos no Claude Code:

```
~/.claude/
├── agents/       ← claude-code/agents/
├── commands/     ← claude-code/commands/
├── skills/       ← claude-code/skills/
├── hooks/        ← claude-code/hooks/ (referenciados por settings.json)
└── settings.json ← claude-code/settings.json
```

O `.tommy/` de cada projeto (scripts, templates, specs) continua vindo de `../common/`, igual às outras ferramentas — nada disso muda por estar no Claude Code.

> **MCP**: o Claude Code **não lê** `~/.claude/mcp.json`. O servidor `context7` (definido em [mcp.json](./mcp.json) deste repositório) é registrado pelo instalador via `claude mcp add --scope user`; os MCPs por projeto vivem em `.tommy/mcp.json` — ver a seção [Configuração Tommy (MCP e SonarQube)](#configuração-tommy-mcp-e-sonarqube).

## Instalação

Rode `npx sdd-tommy@latest` e escolha "Claude Code" no prompt (pode combinar com Cursor/Copilot na mesma execução) — o instalador copia `agents/`, `commands/`, `skills/`, `hooks/` para `~/.claude/`, mescla `settings.json` com o que você já tiver (nunca sobrescreve às cegas, sempre com backup automático antes de qualquer mudança real), registra o `context7` no escopo de usuário via `claude mcp add` e remove arquivos obsoletos de versões anteriores do Tommy. Ver a seção "Como utilizar?" do README raiz para o fluxo completo.

## Fases, agentes e comandos

As fases Specify e Prompt são **comandos** que orquestram na conversa principal (subagentes não podem invocar outros subagentes, e a elicitação de requisitos precisa dialogar com o usuário — o que um subagente não consegue fazer no meio da execução):

- `/tommy-specify` — cria/atualiza a especificação: elicita requisitos com a skill `tommy-business-analyst` (rodadas interativas), escreve a spec e submete à revisão independente do `tommy-product-review`.
- `/tommy-prompt` — cria o plano de execução detalhado, invocando o agente `tommy-architect` para o desenho de arquitetura.

Agentes (subagentes com `tools:` restrito por papel):

- `tommy-architect` — desenho de arquitetura da feature (invocado por `/tommy-prompt`).
- `tommy-product-review` — revisor independente com lente de PM: valida a spec (único autorizado a marcar o checklist de requisitos) e, após o codegen, gera a matriz de rastreabilidade spec→código (`checklists/acceptance.md`).
- `tommy-codegen` — implementa o plano, gera testes e roda o quality gate.
- `tommy-git` — commita mudanças locais (Conventional Commits) e abre Pull/Merge Request no provedor detectado do projeto. Ver seção [Versionamento (commit e PR/MR)](#versionamento-commit-e-prmr) abaixo.

## Versionamento (commit e PR/MR)

O `tommy-git` é orquestrado por dois comandos independentes — commit e abertura de PR/MR são confirmações separadas, nunca encadeadas automaticamente:

- `/tommy-commit` — analisa `git status`/`git diff`, propõe mensagem(ns) no padrão Conventional Commits (skill `tommy-conventional-commits`) e só commita após confirmação. Múltiplos commits por branch/plano são esperados (um por item de checklist concluído, por exemplo) — o agente nunca força um único commit gigante por feature.
- `/tommy-open-pr` — detecta o provedor Git do projeto, sobe a branch e abre o PR/MR, confirmando antes de cada ação visível (push e criação do PR/MR).

**Nenhum outro agente do Tommy dispara `tommy-git` automaticamente** — `tommy-codegen`, por exemplo, só sugere o próximo passo, para respeitar a regra de nunca commitar sem pedido explícito do usuário.

### Detecção do provedor (GitHub, GitLab, Azure DevOps)

1. `tommy-git` lê primeiro a seção "Git Hosting (VCS Provider)" de `.tommy/codebase/integrations.md` — preenchida no bootstrap (`tommy-project-research`, Step 5) a partir do hostname do remote `origin`, ou perguntada ao usuário quando o hostname é ambíguo (self-hosted, sem remote, múltiplos remotes). Depois que essa seção existe, o agente não pergunta de novo.
2. Se a seção estiver ausente/vazia, cai para detecção ao vivo via `git remote get-url origin`.
3. Cada provedor tem uma skill adaptadora dedicada, carregada só quando aplicável:
   - `tommy-git-github` (`gh pr create`)
   - `tommy-git-gitlab` (`glab mr create` — GitLab chama de **Merge Request**, não Pull Request)
   - `tommy-git-azure-devops` (`az repos pr create`, requer `az extension add --name azure-devops`)
4. Google Cloud Source Repositories (e hosts sem conceito de PR/MR) não são suportados para abertura de PR — o agente permite commit/push e avisa explicitamente que a etapa de PR não se aplica, em vez de simular um fluxo inexistente.

### Pré-requisitos por provedor

Cada skill adaptadora assume que a CLI correspondente já está instalada e autenticada na máquina do usuário (`gh auth status`, `glab auth status`, `az account show`) — o agente verifica isso antes de tentar qualquer push/PR e reporta o gap em vez de tentar contornar. Nenhuma credencial nova precisa ser cadastrada em `mcp.json`; o fluxo usa a sessão de CLI já autenticada localmente.

### Regra de atribuição

Reforçando a regra global do Tommy: `tommy-git` **nunca** adiciona `Co-authored-by:` ou qualquer rodapé de atribuição de IA a commits ou descrições de PR/MR — a autoria é sempre a identidade local (`git config user.name`/`user.email`). Isso é reforçado explicitamente nas instruções do agente e da skill `tommy-conventional-commits`, além do `attribution` já zerado em [`settings.json`](./settings.json).

## Configuração Tommy (MCP e SonarQube)

**MCP global (usuário)**: o Claude Code não lê `~/.claude/mcp.json` — o instalador registra o `context7` via `claude mcp add --scope user`. Confira com `claude mcp list`; se o registro automático falhar (CLI ausente), o instalador imprime o comando manual.

**MCP por projeto**: o arquivo canônico é `.tommy/mcp.json`, criado no bootstrap. A forma de ligação com o Claude Code é decidida **uma vez por projeto** (instalador npm ou `/tommy-start`) e persistida em `.tommy/config.json`:

- `root-file` (recomendado): gera `.mcp.json` na raiz do projeto — carregamento nativo.
- `tommy-only`: sem arquivo na raiz — inicie com `claude --mcp-config .tommy/mcp.json`.

Os arquivos nativos de Cursor (`.cursor/mcp.json`) e VS Code/Copilot (`.vscode/mcp.json`) só são gerados quando essas ferramentas estão de fato em uso no projeto (selecionadas no instalador, ou já instaladas por um `/tommy-start` anterior) — um projeto só de Claude Code nunca ganha essas pastas. O catálogo curado de servidores por stack (context7 sempre; Playwright MCP para frontend) está em `common/templates/mcp/` e é proposto pelo `/tommy-start`, sempre com confirmação do usuário.

**Qualidade (lint, complexidade, Sonar)**: as automações dos Gates 1, 3 e 5 do `tommy-quality-gate` são scripts locais em `.tommy/scripts/quality/` (`quality-check.sh`, `complexity-check.sh`, `sonar-run.sh`), instalados pelo `--sync-runtime` — não há mais dependência de servidor MCP privado. Para o Sonar rodar de verdade: tenha um `sonar-project.properties` (o `/tommy-start` oferece criar a partir do template), configure `sonar.host.url` (ou `SONAR_HOST_URL`) e exporte `SONAR_TOKEN` no ambiente. Sem isso, o Gate 5 reporta SKIP e o pipeline segue com os demais gates.

**Hook sentinela**: o `settings.json` registra um hook de `Stop` (`tommy-quality-sentinel.sh`) que, em projetos Tommy, impede encerrar a sessão com arquivos de código alterados sem evidência de quality gate (`.tommy/.quality-gate-status`).

## Como usar

1. `/tommy-specify <descrição da feature>` (ou rode `/tommy-start` primeiro, se `.tommy/` ainda não existir no projeto) — responda às rodadas de perguntas do analista de requisitos; ao final, o `tommy-product-review` valida a spec com olhar de PM.
2. `/tommy-prompt <caminho do spec.md>` — gera o plano de execução com a arquitetura do `tommy-architect`.
3. Rode `/tommy-run-codegen <caminho do plano>`, uma parte do plano por vez — ao final, o `tommy-product-review` gera a matriz de rastreabilidade spec→código.
4. Quando quiser versionar o que foi gerado, rode `/tommy-commit` (um ou mais commits, sob confirmação) e, quando pronto, `/tommy-open-pr` (sobe a branch e abre o PR/MR) — ver [Versionamento (commit e PR/MR)](#versionamento-commit-e-prmr).

# Tommy for Claude Code

Este é o conjunto de arquivos mais completo do Tommy — os únicos com subagentes de verdade (`tools:` restrito por papel) e skills disparadas por descrição. É instalado **globalmente**, valendo para todos os projetos abertos no Claude Code:

```
~/.claude/
├── agents/       ← claude-code/agents/
├── commands/     ← claude-code/commands/
├── skills/       ← claude-code/skills/
├── hooks/        ← claude-code/hooks/ (referenciado por settings.json)
├── mcp.json      ← claude-code/mcp.json
└── settings.json ← claude-code/settings.json
```

O `.tommy/` de cada projeto (scripts, templates, specs) continua vindo de `../common/`, igual às outras ferramentas — nada disso muda por estar no Claude Code.

## Instalação

Rode `npx sdd-tommy@latest` e escolha "Claude Code" no prompt (pode combinar com Cursor/Copilot na mesma execução) — o instalador copia `agents/`, `commands/`, `skills/`, `hooks/` para `~/.claude/` e mescla `mcp.json`/`settings.json` com o que você já tiver (nunca sobrescreve às cegas, sempre com backup automático antes de qualquer mudança real). Ver a seção "Como utilizar?" do README raiz para o fluxo completo. Alternativa manual: copiar esta pasta para `~/.claude/` você mesmo.

## Agentes

- `tommy-specify` — cria/atualiza a especificação, orquestrando `tommy-business-analyst` para elicitar requisitos.
- `tommy-business-analyst` — elicitação de requisitos (chamado por `tommy-specify`, não roda sozinho).
- `tommy-architect` — desenho de arquitetura da feature (chamado por `tommy-prompt`).
- `tommy-prompt` — cria o plano de execução detalhado a partir da especificação.
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

O [mcp.json](./mcp.json) deste repositório só registra o servidor `context7` por padrão. As tools de qualidade referenciadas pelos agentes (`quality-check`, `sonar-run`, `get-sonar-issues`, `complexity-check` — chamadas de "Tommy MCP" em `tommy-codegen` e `tommy-quality-gate`) vêm de um servidor MCP **separado e privado**, que não está incluso aqui e precisa ser adicionado por quem tiver acesso ao repositório desse servidor.

**Requisitos**:

- Chave SSH para acesso ao repositório do Tommy MCP.

1. Adicione uma nova entrada em `mcp.json` (ao lado de `context7`) apontando para o servidor Tommy MCP, com as seguintes variáveis de ambiente:
    - `SONAR_URL`: URL do SonarQube utilizado para análise de código.
    - *Atenção*: o Sonar é chamado via API, então é necessário garantir que a URL esteja correta e acessível para que as análises de código possam ser realizadas com sucesso. Ex: `https://sonar.lughy.com.br`
    - `SONAR_TOKEN`: Token do tipo `User Token` para acessar o SonarQube.
    - *Atenção*: o token é utilizado para autenticar as requisições feitas para a API do SonarQube, garantindo que apenas usuários autorizados possam acessar as informações e funcionalidades do SonarQube. Certifique-se de utilizar um token válido e com as permissões adequadas para garantir o funcionamento correto das análises de código.
    - Sem essa entrada, os Gates 1, 3 e 5 do `tommy-quality-gate` (lint/compile via MCP, complexidade via MCP e SonarQube) caem automaticamente para os fallbacks manuais descritos na skill — o pipeline continua funcionando, só sem essas automações.

2. É necessário que seu projeto tenha um arquivo `sonar-project.properties` configurado corretamente para que as análises de código possam ser realizadas com sucesso. Certifique-se de configurar esse arquivo de acordo com as necessidades do seu projeto e as diretrizes do SonarQube.

## Como usar

1. Selecione o agente `tommy-specify` na sua IA generativa (ou rode `/tommy-start` primeiro, se `.tommy/` ainda não existir no projeto).
    - Você pode solicitar via chat o requisito, ou criar um arquivo explicando a tarefa geral e colocar o caminho do arquivo no campo de input de dados do agente.
2. Selecione o agente `tommy-prompt`, referenciando a especificação criada, para gerar o plano de execução.
3. Rode `/tommy-run-codegen <caminho do plano>` (ou selecione `tommy-codegen` diretamente), uma parte do plano por vez.
4. Quando quiser versionar o que foi gerado, rode `/tommy-commit` (um ou mais commits, sob confirmação) e, quando pronto, `/tommy-open-pr` (sobe a branch e abre o PR/MR) — ver [Versionamento (commit e PR/MR)](#versionamento-commit-e-prmr).

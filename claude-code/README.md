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

## Agentes

- `tommy-specify` — cria/atualiza a especificação, orquestrando `tommy-business-analyst` para elicitar requisitos.
- `tommy-business-analyst` — elicitação de requisitos (chamado por `tommy-specify`, não roda sozinho).
- `tommy-architect` — desenho de arquitetura da feature (chamado por `tommy-prompt`).
- `tommy-prompt` — cria o plano de execução detalhado a partir da especificação.
- `tommy-codegen` — implementa o plano, gera testes e roda o quality gate.

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

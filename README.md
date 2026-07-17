# Tommy

O Tommy é um framework para desenvolvimento assistido por IA, projetado para facilitar fases de especificação, planejamento e codificação, focando em qualidade das entregas.

## TOMMY.md

O arquivo `./TOMMY.md` é onde ficaram as instruções principais, informações, arquitetura e regras do projeto, para que os agentes do Tommy possam aprender e se adaptar ao projeto, garantindo que as entregas estejam alinhadas com os padrões do projeto e atendam às necessidades do projeto.

## Estrutura `.tommy`

- **resources**: Pasta destinada a armazenar arquivos de recursos que os agentes podem utilizar para aprender e se adaptar ao projeto.
    Esses arquivos podem conter informações sobre padrões de código, melhores práticas, convenções de nomenclatura, arquitetura do projeto, estrutura de pastas,
    exemplos de código e qualquer outro conhecimento relevante que possa ajudar os agentes a gerar código alinhado com os padrões do projeto.
- **templates**: Pasta com templates para que os agentes possam gerar arquivos seguindo um formato pré-definido, garantindo consistência e aderência às melhores práticas do projeto.
- **scripts**: Pasta com scripts de automação.

## Agentes

- **Tommy Codegen**: Agente responsável por receber um plano de execução detalhado e gerar código seguindo o plano, buscando por melhores práticas e padrões de código do projeto.
- **Tommy Specify**: Agente responsável por receber uma tarefa geral e criar um plano de execução detalhado.
- **Tommy Prompt**: Agente responsável por receber uma tarefa e criar prompts detalhados para cada passo do plano de execução.

## Customização de templates por projeto

Os scripts em `.tommy/scripts` resolvem templates com uma pilha de prioridade: primeiro `.tommy/templates/overrides/<nome-do-template>.md`, depois `.tommy/templates/<nome-do-template>.md` (o template padrão deste repositório). Se um projeto (ou unidade de negócio) precisar de uma variação de `spec-template.md`, `prompt-template.md`, `checklist-template.md`, `prompt-checklist.md` ou `codegen-checklist.md`, crie o arquivo correspondente em `.tommy/templates/overrides/` — o padrão em `.tommy/templates/` continua servindo como base para todo o resto.

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

## Como utilizar?

1. Se desejar adicione recursos em `./tommy/resources` para que os agentes possam aprender e se adaptar ao seu projeto.
2. Selecione o agente `tommy-specify` na sua IA generativa.
    - Você pode solicitar via chat o requisito, ou, criar um arquivo explicando a tarefa geral e colocando o caminho do arquivo no campo de input de dados do agente.
    - Você deve especificar a tarefa de forma clara e detalhada, com informações como, o que deve ser feito, qual é o objetivo, quais são as restrições, qual é o contexto do projeto, e qualquer outra informação relevante.
    - O agente irá criar os requisitos[./tommy/specs/]
3. Selecione o agente `tommy-prompt` para criar os prompts detalhados para cada passo do plano de execução.
    - Referencie a especificação criada pelo agente `tommy-specify` para criar os prompts.
    - Solicite a criação do planejamento.
4. Selecione o agente `tommy-codegen` para gerar o código.
    - Referencie uma parte por vez do planejamento gerado em `tommy-prompt` para gerar o código.

## Boas práticas

- Forneça o máximo de detalhes possível ao criar a tarefa geral para o agente `tommy-specify`, para que ele possa criar um plano de execução detalhado e alinhado com as necessidades do projeto.
- Revise os requisitos criados pelo agente `tommy-specify` e faça ajustes, se necessário, para garantir que eles estejam claros, completos e alinhados com as necessidades do projeto.
- Utilize um chat para cada planejamento gerado pelo agente `tommy-prompt`, para garantir uma janela de contexto adequada para a geração de código pelo agente `tommy-codegen`.
- Se você estiver utilizando o Copilot, após cada geração de código, crie um chat novo, apague o antigo e de um reload no VSCode.
    - O VSCode utiliza a memória em cache para o Copilot, e isso pode fazer com que ele perca o contexto do projeto e gere códigos desalinhados com os padrões do projeto. Criar um chat novo e dar reload no VSCode ajuda a limpar essa memória em cache e garantir que o Copilot utilize o contexto atualizado do projeto para gerar códigos alinhados com os padrões do projeto.

## Workflow Recomendado - Spec-Driven Development

1. Crie uma tarefa geral clara e detalhada para o agente `tommy-specify`.
    - Podendo ser em um arquivo .md ou diretamente no campo de input de dados do agente.
2. O agente `tommy-specify` cria um plano de execução detalhado, dividido em etapas e subetapas, para atender à tarefa geral.
    - Revise os requisitos criados, essa parte é fundamental para garantir que o plano de execução esteja alinhado com as necessidades do projeto.
    - A especificação é peça fundamental para garantir a qualidade das entregas, pois é a partir dela que os outros agentes irão trabalhar.
3. Referencie a especificação criada pelo agente `tommy-specify` para o agente `tommy-prompt`, para criar os prompts detalhados para cada passo do plano de execução.
4. Para cada passo do plano de execução, referencie o prompt criado pelo agente `tommy-prompt` para o agente `tommy-codegen`, para gerar o código.
5. Revise o código gerado, teste e valide se ele atende aos requisitos definidos na especificação criada pelo agente `tommy-specify`.
6. Caso haja falhas na validação, corrija os requisitos na especificação criada pelo agente `tommy-specify`, e repita o processo de geração de prompts e código até que todas as etapas do plano de execução sejam concluídas com sucesso.

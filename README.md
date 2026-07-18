# Tommy

O Tommy é um framework para desenvolvimento assistido por IA, projetado para facilitar fases de especificação, planejamento e codificação, focando em qualidade das entregas.

## Ferramentas suportadas

O Tommy funciona em três ferramentas — **Claude Code**, **GitHub Copilot** e **Cursor** — cada uma com um mecanismo de carregamento de instruções diferente. Por isso este repositório é organizado por ferramenta, para que um instalador (futuro, via npm) possa copiar só o conjunto certo:

```
sdd_configs/
├── common/            Tool-agnostic — instalado dentro de .tommy/ de cada projeto, qualquer ferramenta
│   ├── scripts/        create-new-spec.sh, create-new-prompt.sh, create-codegen-checklist.sh, common.sh
│   └── templates/       spec-template.md, prompt-template.md, checklists, agents-md-template.md,
│                        e project-research/ (templates de referência usados no bootstrap)
│
├── claude-code/        Instala em ~/.claude/ (global — vale para todos os projetos abertos no Claude Code)
│   ├── agents/, commands/, skills/, hooks/, mcp.json, settings.json
│
├── github-copilot/     Instala em .github/ de cada projeto (por projeto)
│   ├── copilot-instructions.md, prompts/*.prompt.md
│
└── cursor/             Instala em .cursor/ de cada projeto (por projeto)
    └── rules/*.mdc
```

Cada pasta de ferramenta tem seu próprio `README.md` com o passo a passo de instalação e as diferenças específicas daquela ferramenta em relação ao fluxo completo do Claude Code — a mais relevante sendo que só o Claude Code consegue restringir o acesso a ferramentas por fase (specify/prompt não conseguem editar código-fonte); no Copilot e no Cursor essa separação de fases é disciplina, não uma garantia técnica.

## TOMMY.md

O arquivo `.tommy/TOMMY.md` é onde ficam as instruções principais, informações, arquitetura e regras do projeto, para que os agentes do Tommy possam aprender e se adaptar ao projeto, garantindo que as entregas estejam alinhadas com os padrões do projeto e atendam às necessidades do projeto.

Fica **dentro** de `.tommy/`, não na raiz — assim como `.tommy/project-context/` e `.tommy/codebase/`, é conteúdo gerado e mantido pelo Tommy, não algo que todo colaborador do projeto precisa ver (nem todos usam o Tommy) ou versionar (`.tommy/` costuma estar no `.gitignore`).

## AGENTS.md

O arquivo `./AGENTS.md` é a **única exceção** — fica na raiz do projeto, fora de `.tommy/`, porque só tem valor se for descoberto nativamente ali pelo Cursor e pelo Copilot (e conectável ao Claude Code via import `@AGENTS.md` dentro do `CLAUDE.md` do projeto, ou symlink). É um ponteiro curto (10-20 linhas, sem conteúdo de negócio) para `.tommy/TOMMY.md` e para `.tommy/` — não duplica conteúdo. Se o projeto costuma ignorar `.tommy/` no git, avalie versionar o `AGENTS.md` normalmente (ele não expõe nada sensível, só orientação de navegação).

## Estrutura `.tommy` (dentro de cada projeto)

- **TOMMY.md**: instruções principais do projeto para os agentes — ver seção acima.
- **resources**: Pasta destinada a armazenar arquivos de recursos que os agentes podem utilizar para aprender e se adaptar ao projeto.
    Esses arquivos podem conter informações sobre padrões de código, melhores práticas, convenções de nomenclatura, arquitetura do projeto, estrutura de pastas,
    exemplos de código e qualquer outro conhecimento relevante que possa ajudar os agentes a gerar código alinhado com os padrões do projeto.
- **templates**: Pasta com templates para que os agentes possam gerar arquivos seguindo um formato pré-definido, garantindo consistência e aderência às melhores práticas do projeto. Copiada de `common/templates/` na primeira execução.
- **scripts**: Pasta com scripts de automação. Copiada de `common/scripts/` na primeira execução.
- **project-context** e **codebase**: gerados no bootstrap (ver `common/templates/project-research/`).
- **specs**: uma pasta por feature, com `spec.md`, `plans/*.md` e `checklists/*.md`.

## Agentes

- **Tommy Specify**: recebe uma tarefa geral (feature) e cria a especificação (`spec.md`), elicitando requisitos do usuário.
- **Tommy Prompt**: recebe uma especificação aprovada e cria o plano de execução detalhado, incluindo a arquitetura da feature.
- **Tommy Codegen**: recebe um plano de execução detalhado e gera o código seguindo o plano, buscando por melhores práticas e padrões de código do projeto.

No Claude Code esses três agentes têm personas auxiliares dedicadas (`tommy-business-analyst`, `tommy-architect`) com acesso a ferramentas restrito por papel — ver `claude-code/README.md`. No Copilot e no Cursor, as mesmas responsabilidades ficam condensadas em 3 arquivos por ferramenta (ver `github-copilot/README.md` e `cursor/README.md`).

**Versionamento (commit e PR/MR)**: hoje é um agente específico do Claude Code (`tommy-git`, acionado por `/tommy-commit` e `/tommy-open-pr`) — não uma quarta fase do fluxo Specify → Prompt → Codegen, e sim algo acionável a qualquer momento, com detecção do provedor Git do projeto (GitHub, GitLab, Azure DevOps) e commits em Conventional Commits. Detalhes em `claude-code/README.md`; ainda não há equivalente no Copilot/Cursor.

## Customização de templates por projeto

Os scripts em `.tommy/scripts` resolvem templates com uma pilha de prioridade: primeiro `.tommy/templates/overrides/<nome-do-template>.md`, depois `.tommy/templates/<nome-do-template>.md` (o template padrão, copiado de `common/templates/`). Se um projeto (ou unidade de negócio) precisar de uma variação de `spec-template.md`, `prompt-template.md`, `checklist-template.md`, `prompt-checklist.md` ou `codegen-checklist.md`, crie o arquivo correspondente em `.tommy/templates/overrides/` — o padrão em `.tommy/templates/` continua servindo como base para todo o resto.

## Configuração de MCP e SonarQube (Claude Code)

Essa configuração é específica do Claude Code — ver [`claude-code/README.md`](./claude-code/README.md#configuração-tommy-mcp-e-sonarqube).

## Como utilizar?

1. Instale a pasta da sua ferramenta (`claude-code/`, `github-copilot/` ou `cursor/`) — ver o `README.md` de cada uma para o destino exato.
2. Se desejar, adicione recursos em `.tommy/resources` para que os agentes possam aprender e se adaptar ao seu projeto.
3. Rode o bootstrap do Tommy (`/tommy-start` no Claude Code e no Copilot Chat, `@tommy-start` no Cursor) — ele cria `.tommy/` (incluindo `.tommy/TOMMY.md`) e o `AGENTS.md` na raiz, a partir do código existente.
4. Acione a fase **Specify**: descreva a feature de forma clara e detalhada (o que deve ser feito, qual é o objetivo, quais são as restrições). A fase cria a especificação em `.tommy/specs/`.
5. Acione a fase **Prompt**, referenciando a especificação criada, para gerar o plano de execução detalhado.
6. Acione a fase **Codegen**, referenciando uma parte (um arquivo de plano) por vez, para gerar o código.

## Boas práticas

- Forneça o máximo de detalhes possível ao criar a tarefa geral na fase Specify, para que o plano de execução saia detalhado e alinhado com as necessidades do projeto.
- Revise os requisitos criados na fase Specify e faça ajustes, se necessário, para garantir que eles estejam claros, completos e alinhados com as necessidades do projeto.
- Utilize uma conversa/chat por planejamento gerado na fase Prompt, para garantir uma janela de contexto adequada durante a fase Codegen.
- Se estiver usando o Copilot no VS Code, após cada geração de código crie um chat novo e dê reload no editor — o VS Code mantém memória em cache do Copilot entre sessões, o que pode fazer com que ele perca o contexto atualizado do projeto.

## Workflow Recomendado - Spec-Driven Development

1. Crie uma tarefa geral clara e detalhada para a fase Specify.
    - Podendo ser em um arquivo .md ou diretamente no chat.
2. A fase Specify cria a especificação, dividida em requisitos e critérios de aceite, para atender à tarefa geral.
    - Revise os requisitos criados, essa parte é fundamental para garantir que o plano de execução esteja alinhado com as necessidades do projeto.
    - A especificação é peça fundamental para garantir a qualidade das entregas, pois é a partir dela que a fase seguinte trabalha.
3. Referencie a especificação na fase Prompt, para criar o plano de execução detalhado (incluindo arquitetura).
4. Para cada arquivo de plano gerado, referencie-o na fase Codegen para gerar o código.
5. Revise o código gerado, teste e valide se ele atende aos requisitos definidos na especificação.
6. Caso haja falhas na validação, corrija os requisitos na especificação e repita o processo de geração de plano e código até que todas as etapas sejam concluídas com sucesso.

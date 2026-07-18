# Tommy

**English** | [Português](#tommy-pt-br)

Tommy is a framework for AI-assisted development, designed to structure the specification, planning, and coding phases while focusing on delivery quality.

See [`WORKFLOW.md`](./WORKFLOW.md) for a diagram of the possible Spec-Driven Development flows through Tommy, including conditionals and observations.

## Supported Tools

Tommy works across three tools — **Claude Code**, **GitHub Copilot**, and **Cursor** — each with a different instruction-loading mechanism. That's why this repository is organized per tool, so an installer can copy just the right set:

```
sdd_configs/
├── common/            Tool-agnostic — installed inside .tommy/ of each project, any tool
│   ├── scripts/        create-new-spec.sh, create-new-prompt.sh, create-codegen-checklist.sh, common.sh
│   └── templates/       spec-template.md, prompt-template.md, checklists, agents-md-template.md,
│                        and project-research/ (reference templates used during bootstrap)
│
├── claude-code/        Installs into ~/.claude/ (global — applies to every project opened in Claude Code)
│   ├── agents/, commands/, skills/, hooks/, mcp.json, settings.json
│
├── github-copilot/     Installs into .github/ of each project (per project)
│   ├── copilot-instructions.md, prompts/*.prompt.md
│
└── cursor/             Installs into .cursor/ of each project (per project)
    └── rules/*.mdc
```

Each tool folder has its own `README.md` with step-by-step installation instructions and that tool's specific differences from the full Claude Code flow — the most relevant one being that only Claude Code can restrict tool access per phase (the specify/prompt phases can't edit source code); in Copilot and Cursor that phase separation is discipline, not a technical guarantee.

## TOMMY.md

The `.tommy/TOMMY.md` file holds the project's core instructions, information, architecture, and rules, so Tommy's agents can learn and adapt to the project — ensuring deliverables stay aligned with the project's standards and needs.

It lives **inside** `.tommy/`, not at the root — just like `.tommy/project-context/` and `.tommy/codebase/`, it's content generated and maintained by Tommy, not something every project contributor needs to see (not everyone uses Tommy) or version-control (`.tommy/` is usually in `.gitignore`).

## AGENTS.md

The `./AGENTS.md` file is the **one exception** — it lives at the project root, outside `.tommy/`, because it only has value if it's natively discovered there by Cursor and Copilot (and it's connectable to Claude Code via an `@AGENTS.md` import inside the project's `CLAUDE.md`, or a symlink). It's a short pointer (10-20 lines, no business content) to `.tommy/TOMMY.md` and `.tommy/` — it doesn't duplicate content. If the project usually ignores `.tommy/` in git, consider version-controlling `AGENTS.md` normally (it doesn't expose anything sensitive, just navigation guidance).

## `.tommy` Structure (inside each project)

- **TOMMY.md**: the project's core instructions for the agents — see the section above.
- **resources**: folder for resource files that agents can use to learn and adapt to the project.
    These files can hold information about code patterns, best practices, naming conventions, project architecture, folder structure,
    code examples, and any other relevant knowledge that helps agents generate code aligned with the project's standards.
- **templates**: folder with templates so agents can generate files following a predefined format, ensuring consistency and adherence to the project's best practices. Copied from `common/templates/` on first run.
- **scripts**: folder with automation scripts. Copied from `common/scripts/` on first run.
- **project-context** and **codebase**: generated during bootstrap (see `common/templates/project-research/`).
- **specs**: one folder per feature, with `spec.md`, `plans/*.md`, and `checklists/*.md`.

## Agents

- **Tommy Specify**: takes a general task (feature) and creates the specification (`spec.md`), eliciting requirements from the user.
- **Tommy Prompt**: takes an approved specification and creates the detailed execution plan, including the feature's architecture.
- **Tommy Codegen**: takes a detailed execution plan and generates the code following it, drawing on the project's best practices and code patterns.
- **Tommy Git**: reviews local changes and creates Conventional Commits, and detects the project's Git provider (GitHub, GitLab, or Azure DevOps) to push the branch and open a Pull/Merge Request. Not a phase of the Specify → Prompt → Codegen flow — available at any point, only ever on explicit request. See "How to Use It?" below for the exact command per tool, and the paragraph below for how it differs between Claude Code, Cursor, and Copilot.

In Claude Code the Specify/Prompt/Codegen agents have dedicated helper personas (`tommy-business-analyst`, `tommy-architect`) with role-restricted tool access — see `claude-code/README.md`. In Copilot and Cursor, the same responsibilities are condensed into 3 files per tool (see `github-copilot/README.md` and `cursor/README.md`).

**Versioning (commit and PR/MR)**: available across all 3 tools — not a fourth phase of the Specify → Prompt → Codegen flow, but something actionable at any point, with detection of the project's Git provider (GitHub, GitLab, Azure DevOps) and Conventional Commits. In Claude Code it's the `tommy-git` agent (`/tommy-commit`, `/tommy-open-pr`) with 4 dedicated skills (one per provider, plus Conventional Commits); in Copilot and Cursor, the same logic is condensed into 2 files per tool (`tommy-commit` and `tommy-open-pr`), with the 3 provider adapters as sections inside the PR/MR-opening file. Details in `claude-code/README.md`, `cursor/README.md`, and `github-copilot/README.md`.

## Per-Project Template Customization

The scripts in `.tommy/scripts` resolve templates with a priority stack: first `.tommy/templates/overrides/<template-name>.md`, then `.tommy/templates/<template-name>.md` (the default template, copied from `common/templates/`). If a project (or business unit) needs a variation of `spec-template.md`, `prompt-template.md`, `checklist-template.md`, `prompt-checklist.md`, or `codegen-checklist.md`, create the corresponding file in `.tommy/templates/overrides/` — the default in `.tommy/templates/` keeps serving as the base for everything else.

## MCP and SonarQube Configuration (Claude Code)

This configuration is specific to Claude Code — see [`claude-code/README.md`](./claude-code/README.md#configuração-tommy-mcp-e-sonarqube).

## How to Use It?

1. Run `npx sdd-tommy@latest` in your project's folder (or anywhere, to install just Claude Code globally) — the interactive installer asks which tool(s) to install (Claude Code, Cursor, GitHub Copilot — you can pick more than one) and puts the right files in the right place on its own: Claude Code goes to `~/.claude/` (global, once, applies to every project), Cursor and Copilot go to `.cursor/`/`.github/` of the current project. Claude Code's `settings.json`/`mcp.json` are merged with what you already have — never blindly overwritten, always with an automatic backup before any change. Running it again later is safe (it updates without duplicating or losing your customization).
   - **Manual installation (advanced/offline)**: if you'd rather not use npm/npx, copy your tool's folder (`claude-code/`, `github-copilot/`, or `cursor/`) manually — see each one's `README.md` for the exact destination.
2. If you'd like, add resources to `.tommy/resources` so agents can learn and adapt to your project.
3. Run Tommy's bootstrap (`/tommy-start` in Claude Code and Copilot Chat, `@tommy-start` in Cursor) — it creates `.tommy/` (including `.tommy/TOMMY.md`) and `AGENTS.md` at the root, based on the existing code.
4. Trigger the **Specify** phase — describe the feature clearly and in detail (what needs to be done, what the goal is, what the constraints are):
   - **Claude Code**: say "Use the tommy-specify agent: `<feature description>`" in the chat (or select the `tommy-specify` agent directly).
   - **Cursor**: `@tommy-specify <feature description>`
   - **Copilot Chat**: `/tommy-specify`, then describe the feature when asked.

   This phase creates the specification in `.tommy/specs/`.
5. Trigger the **Prompt** phase, referencing the specification created in step 4:
   - **Claude Code**: "Use the tommy-prompt agent: `<path to spec.md>`" (or select the `tommy-prompt` agent directly).
   - **Cursor**: `@tommy-prompt <path to spec.md>`
   - **Copilot Chat**: `/tommy-prompt`, then reference the spec.
6. Trigger the **Codegen** phase, referencing one plan file at a time:
   - **Claude Code**: `/tommy-run-codegen <path to plan file>` (or select the `tommy-codegen` agent directly).
   - **Cursor**: `@tommy-codegen <path to plan file>`
   - **Copilot Chat**: `/tommy-codegen`, then reference the plan file.
7. When ready to version what was generated, use the **Tommy Git** agent — committing and opening a PR/MR are two separate actions, each only triggered when you explicitly ask for it:
   - **Claude Code**: `/tommy-commit` to commit, then `/tommy-open-pr` to push the branch and open the PR/MR.
   - **Cursor**: `@tommy-commit`, then `@tommy-open-pr`.
   - **Copilot Chat**: `/tommy-commit`, then `/tommy-open-pr`.

   See "Agents" above for how Conventional Commits and Git-provider detection work.

## Best Practices

- Provide as much detail as possible when creating the general task in the Specify phase, so the execution plan comes out detailed and aligned with the project's needs.
- Review the requirements created in the Specify phase and adjust them if needed, to make sure they're clear, complete, and aligned with the project's needs.
- Use one conversation/chat per plan generated in the Prompt phase, to ensure an adequate context window during the Codegen phase.
- If you're using Copilot in VS Code, start a new chat and reload the editor after each code generation — VS Code keeps a cached memory of Copilot across sessions, which can cause it to lose the project's up-to-date context.

## Recommended Workflow - Spec-Driven Development

1. Create a clear, detailed general task for the Specify phase.
    - This can be in a .md file or directly in the chat.
    - To start it: "Use the tommy-specify agent: `<task description>`" in Claude Code, `@tommy-specify` in Cursor, or `/tommy-specify` in Copilot Chat — see "How to Use It?" above for the full per-tool syntax.
2. The Specify phase creates the specification, broken down into requirements and acceptance criteria, to fulfill the general task.
    - Review the requirements created — this part is essential to ensure the execution plan stays aligned with the project's needs.
    - The specification is the key piece for ensuring delivery quality, since it's what the next phase works from.
3. Reference the specification in the Prompt phase (the `tommy-prompt` agent in Claude Code, `@tommy-prompt` in Cursor, `/tommy-prompt` in Copilot), to create the detailed execution plan (including architecture).
4. For each plan file generated, reference it in the Codegen phase (`/tommy-run-codegen <plan>` or the `tommy-codegen` agent in Claude Code, `@tommy-codegen` in Cursor, `/tommy-codegen` in Copilot) to generate the code.
5. Review the generated code, test it, and validate that it meets the requirements defined in the specification.
6. If validation fails, fix the requirements in the specification and repeat the plan and code generation process until every step is completed successfully.

---

# Tommy (PT-BR)

[English](#tommy) | **Português**

O Tommy é um framework para desenvolvimento assistido por IA, projetado para facilitar fases de especificação, planejamento e codificação, focando em qualidade das entregas.

Veja [`WORKFLOW.md`](./WORKFLOW.md) para um diagrama dos possíveis fluxos de Spec-Driven Development pelo Tommy, incluindo condicionais e observações.

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
- **Tommy Git**: analisa as mudanças locais e cria commits em Conventional Commits, e detecta o provedor Git do projeto (GitHub, GitLab ou Azure DevOps) para subir a branch e abrir um Pull/Merge Request. Não é uma fase do fluxo Specify → Prompt → Codegen — acionável a qualquer momento, só sob pedido explícito. Ver "Como utilizar?" abaixo para o comando exato por ferramenta, e o parágrafo abaixo para como isso muda entre Claude Code, Cursor e Copilot.

No Claude Code os agentes Specify/Prompt/Codegen têm personas auxiliares dedicadas (`tommy-business-analyst`, `tommy-architect`) com acesso a ferramentas restrito por papel — ver `claude-code/README.md`. No Copilot e no Cursor, as mesmas responsabilidades ficam condensadas em 3 arquivos por ferramenta (ver `github-copilot/README.md` e `cursor/README.md`).

**Versionamento (commit e PR/MR)**: disponível nas 3 ferramentas — não é uma quarta fase do fluxo Specify → Prompt → Codegen, e sim algo acionável a qualquer momento, com detecção do provedor Git do projeto (GitHub, GitLab, Azure DevOps) e commits em Conventional Commits. No Claude Code é o agente `tommy-git` (`/tommy-commit`, `/tommy-open-pr`) com 4 skills dedicadas (uma por provedor, mais Conventional Commits); no Copilot e no Cursor, a mesma lógica fica condensada em 2 arquivos por ferramenta (`tommy-commit` e `tommy-open-pr`), com os 3 adaptadores de provedor como seções dentro do arquivo de abertura de PR/MR. Detalhes em `claude-code/README.md`, `cursor/README.md` e `github-copilot/README.md`.

## Customização de templates por projeto

Os scripts em `.tommy/scripts` resolvem templates com uma pilha de prioridade: primeiro `.tommy/templates/overrides/<nome-do-template>.md`, depois `.tommy/templates/<nome-do-template>.md` (o template padrão, copiado de `common/templates/`). Se um projeto (ou unidade de negócio) precisar de uma variação de `spec-template.md`, `prompt-template.md`, `checklist-template.md`, `prompt-checklist.md` ou `codegen-checklist.md`, crie o arquivo correspondente em `.tommy/templates/overrides/` — o padrão em `.tommy/templates/` continua servindo como base para todo o resto.

## Configuração de MCP e SonarQube (Claude Code)

Essa configuração é específica do Claude Code — ver [`claude-code/README.md`](./claude-code/README.md#configuração-tommy-mcp-e-sonarqube).

## Como utilizar?

1. Rode `npx sdd-tommy@latest` na pasta do seu projeto (ou em qualquer lugar, para instalar só o Claude Code globalmente) — o instalador interativo pergunta para qual(is) ferramenta(s) instalar (Claude Code, Cursor, GitHub Copilot — pode escolher mais de uma) e coloca os arquivos certos no lugar certo sozinho: Claude Code vai para `~/.claude/` (global, uma vez só, vale pra todos os projetos), Cursor e Copilot vão para `.cursor/`/`.github/` do projeto atual. `settings.json`/`mcp.json` do Claude Code são mesclados com o que você já tem — nunca sobrescritos às cegas, sempre com backup automático antes de qualquer mudança. Rodar de novo mais tarde é seguro (atualiza sem duplicar nem perder customização sua).
   - **Instalação manual (avançado/offline)**: se preferir não usar npm/npx, copie a pasta da sua ferramenta (`claude-code/`, `github-copilot/` ou `cursor/`) manualmente — ver o `README.md` de cada uma para o destino exato.
2. Se desejar, adicione recursos em `.tommy/resources` para que os agentes possam aprender e se adaptar ao seu projeto.
3. Rode o bootstrap do Tommy (`/tommy-start` no Claude Code e no Copilot Chat, `@tommy-start` no Cursor) — ele cria `.tommy/` (incluindo `.tommy/TOMMY.md`) e o `AGENTS.md` na raiz, a partir do código existente.
4. Acione a fase **Specify** — descreva a feature de forma clara e detalhada (o que deve ser feito, qual é o objetivo, quais são as restrições):
   - **Claude Code**: digite "Use the tommy-specify agent: `<descrição da feature>`" no chat (ou selecione o agente `tommy-specify` diretamente).
   - **Cursor**: `@tommy-specify <descrição da feature>`
   - **Copilot Chat**: `/tommy-specify` e descreva a feature quando solicitado.

   A fase cria a especificação em `.tommy/specs/`.
5. Acione a fase **Prompt**, referenciando a especificação criada no passo 4:
   - **Claude Code**: "Use the tommy-prompt agent: `<caminho do spec.md>`" (ou selecione o agente `tommy-prompt` diretamente).
   - **Cursor**: `@tommy-prompt <caminho do spec.md>`
   - **Copilot Chat**: `/tommy-prompt` e referencie a spec.
6. Acione a fase **Codegen**, referenciando uma parte (um arquivo de plano) por vez:
   - **Claude Code**: `/tommy-run-codegen <caminho do arquivo de plano>` (ou selecione o agente `tommy-codegen` diretamente).
   - **Cursor**: `@tommy-codegen <caminho do arquivo de plano>`
   - **Copilot Chat**: `/tommy-codegen` e referencie o arquivo de plano.
7. Quando quiser versionar o que foi gerado, use o agente **Tommy Git** — commitar e abrir PR/MR são duas ações separadas, cada uma só acionada quando você pede explicitamente:
   - **Claude Code**: `/tommy-commit` para commitar, depois `/tommy-open-pr` para subir a branch e abrir o PR/MR.
   - **Cursor**: `@tommy-commit`, depois `@tommy-open-pr`.
   - **Copilot Chat**: `/tommy-commit`, depois `/tommy-open-pr`.

   Ver "Agentes" acima para como funcionam os Conventional Commits e a detecção do provedor Git.

## Boas práticas

- Forneça o máximo de detalhes possível ao criar a tarefa geral na fase Specify, para que o plano de execução saia detalhado e alinhado com as necessidades do projeto.
- Revise os requisitos criados na fase Specify e faça ajustes, se necessário, para garantir que eles estejam claros, completos e alinhados com as necessidades do projeto.
- Utilize uma conversa/chat por planejamento gerado na fase Prompt, para garantir uma janela de contexto adequada durante a fase Codegen.
- Se estiver usando o Copilot no VS Code, após cada geração de código crie um chat novo e dê reload no editor — o VS Code mantém memória em cache do Copilot entre sessões, o que pode fazer com que ele perca o contexto atualizado do projeto.

## Workflow Recomendado - Spec-Driven Development

1. Crie uma tarefa geral clara e detalhada para a fase Specify.
    - Podendo ser em um arquivo .md ou diretamente no chat.
    - Para iniciar: "Use the tommy-specify agent: `<descrição da tarefa>`" no Claude Code, `@tommy-specify` no Cursor, ou `/tommy-specify` no Copilot Chat — ver "Como utilizar?" acima para a sintaxe completa por ferramenta.
2. A fase Specify cria a especificação, dividida em requisitos e critérios de aceite, para atender à tarefa geral.
    - Revise os requisitos criados, essa parte é fundamental para garantir que o plano de execução esteja alinhado com as necessidades do projeto.
    - A especificação é peça fundamental para garantir a qualidade das entregas, pois é a partir dela que a fase seguinte trabalha.
3. Referencie a especificação na fase Prompt (o agente `tommy-prompt` no Claude Code, `@tommy-prompt` no Cursor, `/tommy-prompt` no Copilot), para criar o plano de execução detalhado (incluindo arquitetura).
4. Para cada arquivo de plano gerado, referencie-o na fase Codegen (`/tommy-run-codegen <plano>` ou o agente `tommy-codegen` no Claude Code, `@tommy-codegen` no Cursor, `/tommy-codegen` no Copilot) para gerar o código.
5. Revise o código gerado, teste e valide se ele atende aos requisitos definidos na especificação.
6. Caso haja falhas na validação, corrija os requisitos na especificação e repita o processo de geração de plano e código até que todas as etapas sejam concluídas com sucesso.

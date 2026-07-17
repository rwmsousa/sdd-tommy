# Configuração Global — Claude Code

## Regras de Commit

- **Nunca** adicionar linhas `Co-authored-by:` em commits, independentemente do agente que gerou o código.
- Commits devem conter apenas a autoria do usuário (configurada no `git config`).

## Fluxo Tommy

Este workspace utiliza o **fluxo Tommy** para desenvolvimento orientado a especificação. O fluxo possui três etapas principais:

```
Specify → Prompt → Codegen
```

### Etapas do Fluxo

| Etapa | Agente | O que faz |
|---|---|---|
| 1. Especificação | `tommy-specify` | Cria branch + elicita requisitos + gera spec |
| 2. Plano | `tommy-prompt` | Cria plano de implementação detalhado |
| 3. Código | `tommy-codegen` | Implementa código seguindo o plano |

### Como usar

**Para iniciar um novo projeto** (cria base de conhecimento):
```
/tommy-start
```

**Para especificar uma nova feature:**
```
Use the tommy-specify agent: <descrição da feature em linguagem natural>
```

**Para criar um plano de implementação a partir de uma spec:**
```
Use the tommy-prompt agent: <caminho da spec ou descrição>
```

**Para gerar código a partir de um plano:**
```
/tommy-run-codegen <caminho do arquivo de plano>
```

### Pré-requisitos por Projeto

Cada projeto precisa ter a pasta `.tommy/` com:
- `scripts/create-new-spec.sh` — cria branch e estrutura da spec
- `scripts/create-new-prompt.sh` — cria arquivo de prompt
- `scripts/create-codegen-checklist.sh` — cria checklist de codegen
- `templates/spec-template.md` — template de especificação
- `templates/prompt-template.md` — template de prompt

### Agentes Disponíveis

- `tommy-specify` — Especificação de features
- `tommy-business-analyst` — Elicitação de requisitos (usado pelo specify)
- `tommy-architect` — Arquitetura técnica (usado pelo prompt)
- `tommy-prompt` — Planejamento de implementação
- `tommy-codegen` — Geração de código

### Skills de Referência

Localizadas em `~/.claude/skills/`:

- `tommy-project-research` — Pesquisa e mapeia o codebase
- `tommy-quality-gate` — Validação de qualidade do código gerado
- `tommy-code-practices` — Boas práticas de desenvolvimento
- `tommy-ubiquitous-language` — Linguagem ubíqua do domínio
- `tommy-ux-practices` — Práticas de UX/UI
- `tommy-prd-generator` — Geração de PRD
- `tommy-plantuml-diagram` — Diagramas PlantUML
- `tommy-entity-relationship-diagram` — Diagramas ER
- `tommy-skill-creator` — Criação de novas skills

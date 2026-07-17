# Configuração Global — Claude Code

## Regras de Commit

- **Nunca** adicionar linhas `Co-authored-by:` em commits, independentemente do agente que gerou o código.
- Commits devem conter apenas a autoria do usuário (configurada no `git config`).

## Fluxo Makuco

Este workspace utiliza o **fluxo Makuco** para desenvolvimento orientado a especificação. O fluxo possui três etapas principais:

```
Specify → Prompt → Codegen
```

### Etapas do Fluxo

| Etapa | Agente | O que faz |
|---|---|---|
| 1. Especificação | `makuco-specify` | Cria branch + elicita requisitos + gera spec |
| 2. Plano | `makuco-prompt` | Cria plano de implementação detalhado |
| 3. Código | `makuco-codegen` | Implementa código seguindo o plano |

### Como usar

**Para iniciar um novo projeto** (cria base de conhecimento):
```
/makuco-start
```

**Para especificar uma nova feature:**
```
Use the makuco-specify agent: <descrição da feature em linguagem natural>
```

**Para criar um plano de implementação a partir de uma spec:**
```
Use the makuco-prompt agent: <caminho da spec ou descrição>
```

**Para gerar código a partir de um plano:**
```
/makuco-run-codegen <caminho do arquivo de plano>
```

### Pré-requisitos por Projeto

Cada projeto precisa ter a pasta `.makuco/` com:
- `scripts/create-new-spec.sh` — cria branch e estrutura da spec
- `scripts/create-new-prompt.sh` — cria arquivo de prompt
- `scripts/create-codegen-checklist.sh` — cria checklist de codegen
- `templates/spec-template.md` — template de especificação
- `templates/prompt-template.md` — template de prompt

### Agentes Disponíveis

- `makuco-specify` — Especificação de features
- `makuco-business-analyst` — Elicitação de requisitos (usado pelo specify)
- `makuco-architect` — Arquitetura técnica (usado pelo prompt)
- `makuco-prompt` — Planejamento de implementação
- `makuco-codegen` — Geração de código

### Skills de Referência

Localizadas em `~/.claude/skills/`:

- `makuco-project-research` — Pesquisa e mapeia o codebase
- `makuco-quality-gate` — Validação de qualidade do código gerado
- `makuco-code-practices` — Boas práticas de desenvolvimento
- `makuco-ubiquitous-language` — Linguagem ubíqua do domínio
- `makuco-ux-practices` — Práticas de UX/UI
- `makuco-prd-generator` — Geração de PRD
- `makuco-plantuml-diagram` — Diagramas PlantUML
- `makuco-entity-relationship-diagram` — Diagramas ER
- `makuco-skill-creator` — Criação de novas skills

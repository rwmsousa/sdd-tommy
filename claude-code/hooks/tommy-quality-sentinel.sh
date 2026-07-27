#!/bin/bash
# Tommy Quality Sentinel — hook de Stop.
# Verifica se o tommy-quality-gate rodou cobrindo os arquivos de código alterados
# na sessão. Não executa testes — apenas confere a evidência persistida pelo
# quality gate em .tommy/.quality-gate-status (linha única:
#   status=PASS timestamp=<ISO-8601> files=<a.ts,b.ts>).
# Só atua em projetos Tommy (com .tommy/) versionados em git.

INPUT=$(cat)

command -v jq >/dev/null 2>&1 || exit 0

# Evita loop infinito: se a sessão já está continuando por causa deste hook,
# não bloqueia de novo — o modelo teve sua chance de rodar o gate.
[ "$(echo "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ] && exit 0

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(echo "$INPUT" | jq -r '.cwd // empty')}"
[ -z "$PROJECT_DIR" ] && PROJECT_DIR=$(pwd)

[ -d "$PROJECT_DIR/.tommy" ] || exit 0
git -C "$PROJECT_DIR" rev-parse --show-toplevel >/dev/null 2>&1 || exit 0

CODE_EXT='\.(ts|tsx|js|jsx|mjs|cjs|py|go|rs|java|rb|php|cs|kt|swift|vue|svelte|c|cc|cpp|h|hpp)$'
CHANGED=$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null | awk '{print $NF}' | grep -E "$CODE_EXT" | grep -v '^\.tommy/' || true)
[ -z "$CHANGED" ] && exit 0

MARKER="$PROJECT_DIR/.tommy/.quality-gate-status"

block() {
    jq -cn --arg reason "$1" '{"decision":"block","reason":$reason}'
    exit 0
}

CHANGED_INLINE=$(echo "$CHANGED" | tr '\n' ' ')

[ -f "$MARKER" ] || block "Há arquivos de código alterados sem evidência de quality gate: $CHANGED_INLINE. Rode o tommy-quality-gate (todos os gates aplicáveis) — ele grava o marcador .tommy/.quality-gate-status ao final."

STATUS=$(sed -n 's/.*status=\([^ ]*\).*/\1/p' "$MARKER" | head -1)
TS=$(sed -n 's/.*timestamp=\([^ ]*\).*/\1/p' "$MARKER" | head -1)
FILES=$(sed -n 's/.*files=\([^ ]*\).*/\1/p' "$MARKER" | head -1)

[ "$STATUS" = "PASS" ] || block "O último quality gate não passou (status=${STATUS:-desconhecido}). Corrija os problemas e re-execute os gates antes de encerrar."

MARKER_EPOCH=$(date -d "$TS" +%s 2>/dev/null || echo 0)

MISSING=""
STALE=""
while IFS= read -r f; do
    case ",$FILES," in
        *",$f,"*) ;;
        *) MISSING="$MISSING $f" ;;
    esac
    FULL="$PROJECT_DIR/$f"
    if [ -f "$FULL" ] && [ "$MARKER_EPOCH" -gt 0 ]; then
        FILE_EPOCH=$(stat -c %Y "$FULL" 2>/dev/null || stat -f %m "$FULL" 2>/dev/null || echo 0)
        [ "$FILE_EPOCH" -gt "$MARKER_EPOCH" ] && STALE="$STALE $f"
    fi
done <<< "$CHANGED"

[ -n "$MISSING" ] && block "Arquivos de código alterados que não constam no último quality gate:$MISSING. Re-execute o tommy-quality-gate cobrindo esses arquivos."
[ -n "$STALE" ] && block "Arquivos modificados depois do último quality gate:$STALE. Re-execute o tommy-quality-gate para revalidá-los."

exit 0

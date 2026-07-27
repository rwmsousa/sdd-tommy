#!/usr/bin/env bash
# Tommy Complexity Check — complexidade ciclomática e tamanho de funções.
# Substitui o antigo tool MCP `complexity-check`. Usa `lizard` (multi-linguagem:
# JS/TS, Python, Go, Java, C#, Rust etc.) quando disponível; caso contrário,
# reporta SKIP com instruções — a verificação manual do Gate 3 continua valendo.
# Exit: 0 = PASS ou SKIP, 1 = FAIL.

set -u

JSON_MODE=false
TARGET=""
MAX_COMPLEXITY=10
MAX_LINES=50

while [ $# -gt 0 ]; do
    case "$1" in
        --json) JSON_MODE=true ;;
        --target)
            shift
            TARGET="${1:-}"
            ;;
        --max-complexity)
            shift
            MAX_COMPLEXITY="${1:-10}"
            ;;
        --max-lines)
            shift
            MAX_LINES="${1:-50}"
            ;;
        --help|-h)
            echo "Uso: $0 [--json] [--target PATH] [--max-complexity N] [--max-lines N]"
            echo ""
            echo "Opções:"
            echo "  --json               Saída em formato JSON"
            echo "  --target PATH        Caminho a analisar (padrão: raiz do repositório)"
            echo "  --max-complexity N   Complexidade ciclomática máxima por função (padrão: 10)"
            echo "  --max-lines N        Máximo de linhas por função (padrão: 50)"
            exit 0
            ;;
    esac
    shift
done

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"
[ -z "$TARGET" ] && TARGET="$REPO_ROOT"

emit() {
    local status="$1"
    local details="$2"
    if $JSON_MODE; then
        if has_jq; then
            jq -cn --arg status "$status" --arg details "$details" '{STATUS:$status,DETAILS:$details}'
        else
            printf '{"STATUS":"%s","DETAILS":"%s"}\n' "$status" "$(json_escape "$details")"
        fi
    else
        echo "[Tommy] Complexity check: $status"
        [ -n "$details" ] && echo "$details"
    fi
}

if ! command -v lizard >/dev/null 2>&1; then
    emit "SKIP" "lizard não encontrado. Instale com 'pip install lizard' (ou 'pipx install lizard') para análise automática, ou verifique manualmente: complexidade ciclomática <= $MAX_COMPLEXITY e <= $MAX_LINES linhas por função (Gate 3 do tommy-quality-gate)."
    exit 0
fi

# -C: limite de complexidade ciclomática; -L: limite de linhas por função;
# -w: só exibe warnings (funções acima dos limites); exit code != 0 quando há violações.
OUTPUT=$(lizard "$TARGET" -C "$MAX_COMPLEXITY" -L "$MAX_LINES" -w \
    -x "*/node_modules/*" -x "*/.git/*" -x "*/dist/*" -x "*/build/*" -x "*/vendor/*" -x "*/.tommy/*" 2>&1)
LIZARD_EXIT=$?

if [ $LIZARD_EXIT -eq 0 ]; then
    emit "PASS" "Nenhuma função acima dos limites (complexidade <= $MAX_COMPLEXITY, linhas <= $MAX_LINES)."
    exit 0
else
    emit "FAIL" "$OUTPUT"
    exit 1
fi

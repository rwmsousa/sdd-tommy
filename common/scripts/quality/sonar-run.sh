#!/usr/bin/env bash
# Tommy Sonar Run — executa análise SonarQube quando o projeto está configurado.
# Substitui os antigos tools MCP `sonar-run`/`get-sonar-issues`.
# SKIP (exit 0) quando o Sonar não está configurado — isso é aceitável e esperado
# em projetos sem servidor SonarQube/SonarCloud; o Gate 5 trata SKIP como não-bloqueante.
# Exit: 0 = PASS ou SKIP, 1 = FAIL.

set -u

JSON_MODE=false
TARGET=""

while [ $# -gt 0 ]; do
    case "$1" in
        --json) JSON_MODE=true ;;
        --target)
            shift
            TARGET="${1:-}"
            ;;
        --help|-h)
            echo "Uso: $0 [--json] [--target PATH]"
            echo ""
            echo "Pré-requisitos para a análise rodar (senão: SKIP):"
            echo "  - sonar-project.properties na raiz do repositório"
            echo "  - Servidor: sonar.host.url no properties ou variável SONAR_HOST_URL"
            echo "  - Autenticação: variável SONAR_TOKEN"
            echo "  - Scanner: binário sonar-scanner no PATH (ou npx @sonar/scan em projetos Node)"
            exit 0
            ;;
    esac
    shift
done

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

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
        echo "[Tommy] Sonar: $status"
        [ -n "$details" ] && echo "  $details"
    fi
}

PROPERTIES="$REPO_ROOT/sonar-project.properties"
if [ ! -f "$PROPERTIES" ]; then
    emit "SKIP" "sonar-project.properties não encontrado — projeto sem Sonar configurado."
    exit 0
fi

HOST_URL="${SONAR_HOST_URL:-$(grep -E '^sonar\.host\.url=' "$PROPERTIES" 2>/dev/null | cut -d'=' -f2-)}"
if [ -z "$HOST_URL" ] || [[ "$HOST_URL" == *"<"* ]]; then
    emit "SKIP" "Servidor Sonar não configurado (defina sonar.host.url no properties ou a variável SONAR_HOST_URL)."
    exit 0
fi

if [ -z "${SONAR_TOKEN:-}" ]; then
    emit "SKIP" "SONAR_TOKEN não definido — análise requer autenticação no servidor."
    exit 0
fi

SCANNER=""
if command -v sonar-scanner >/dev/null 2>&1; then
    SCANNER="sonar-scanner"
elif [ -f "$REPO_ROOT/package.json" ] && npx --no @sonar/scan --version >/dev/null 2>&1; then
    SCANNER="npx --no @sonar/scan"
else
    emit "SKIP" "Nenhum scanner encontrado (instale o sonar-scanner CLI ou o pacote @sonar/scan)."
    exit 0
fi

EXTRA_ARGS=()
[ -n "$TARGET" ] && EXTRA_ARGS+=("-Dsonar.sources=$TARGET")

if $SCANNER -Dsonar.host.url="$HOST_URL" "${EXTRA_ARGS[@]}"; then
    emit "PASS" "Análise enviada para $HOST_URL. Revise as issues novas no dashboard do projeto (bugs e vulnerabilidades: corrigir; code smells: corrigir ou justificar)."
    exit 0
else
    emit "FAIL" "O scanner retornou erro — verifique a saída acima."
    exit 1
fi

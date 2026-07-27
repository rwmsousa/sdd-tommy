#!/usr/bin/env bash
# Tommy Quality Check — lint + type-check stack-aware.
# Substitui o antigo tool MCP `quality-check`: detecta a stack do projeto e
# executa os verificadores que o próprio projeto configura.
# Exit: 0 = PASS ou SKIP, 1 = FAIL.

set -u

JSON_MODE=false
FIX_MODE=false
TARGET=""

while [ $# -gt 0 ]; do
    case "$1" in
        --json) JSON_MODE=true ;;
        --fix) FIX_MODE=true ;;
        --target)
            shift
            TARGET="${1:-}"
            ;;
        --help|-h)
            echo "Uso: $0 [--json] [--fix] [--target PATH]"
            echo ""
            echo "Opções:"
            echo "  --json         Saída em formato JSON"
            echo "  --fix          Aplica correções automáticas quando o verificador suportar"
            echo "  --target PATH  Limita a verificação a um caminho (padrão: raiz do repositório)"
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

STATUS="SKIP"
DETAILS=()
FAILED=false
RAN_SOMETHING=false
STACK_DETECTED=false

log() { $JSON_MODE || echo "[Tommy] $1"; }

run_check() {
    local label="$1"
    shift
    log "Executando: $label ($*)"
    if "$@"; then
        DETAILS+=("$label: PASS")
    else
        DETAILS+=("$label: FAIL")
        FAILED=true
    fi
    RAN_SOMETHING=true
}

# --- Node.js / TypeScript ---
if [ -f "$REPO_ROOT/package.json" ]; then
    STACK_DETECTED=true
    PKG_RUN="npm run"
    [ -f "$REPO_ROOT/pnpm-lock.yaml" ] && PKG_RUN="pnpm run"
    [ -f "$REPO_ROOT/yarn.lock" ] && PKG_RUN="yarn run"

    if grep -q '"lint"' "$REPO_ROOT/package.json"; then
        if $FIX_MODE; then
            run_check "lint (com --fix)" $PKG_RUN lint -- --fix
        else
            run_check "lint" $PKG_RUN lint
        fi
    else
        log "Nenhum script \"lint\" em package.json — etapa de lint ignorada."
    fi

    if grep -q '"typecheck"' "$REPO_ROOT/package.json"; then
        run_check "typecheck" $PKG_RUN typecheck
    elif [ -f "$REPO_ROOT/tsconfig.json" ]; then
        run_check "tsc --noEmit" npx --no tsc --noEmit
    fi
fi

# --- Python ---
if [ -f "$REPO_ROOT/pyproject.toml" ] || [ -f "$REPO_ROOT/requirements.txt" ]; then
    STACK_DETECTED=true
    if command -v ruff >/dev/null 2>&1; then
        if $FIX_MODE; then
            run_check "ruff check --fix" ruff check --fix "$TARGET"
        else
            run_check "ruff check" ruff check "$TARGET"
        fi
    fi
    if command -v mypy >/dev/null 2>&1 && grep -q "mypy" "$REPO_ROOT/pyproject.toml" 2>/dev/null; then
        run_check "mypy" mypy "$TARGET"
    fi
fi

# --- Go ---
if [ -f "$REPO_ROOT/go.mod" ]; then
    STACK_DETECTED=true
    run_check "go vet" go vet ./...
    UNFORMATTED=$(gofmt -l . 2>/dev/null | grep -v '^vendor/' || true)
    if [ -n "$UNFORMATTED" ]; then
        if $FIX_MODE; then
            gofmt -w $UNFORMATTED
            DETAILS+=("gofmt: FIXED")
        else
            DETAILS+=("gofmt: FAIL (arquivos sem formatação: $UNFORMATTED)")
            FAILED=true
        fi
    else
        DETAILS+=("gofmt: PASS")
    fi
    RAN_SOMETHING=true
fi

# --- Rust ---
if [ -f "$REPO_ROOT/Cargo.toml" ]; then
    STACK_DETECTED=true
    if command -v cargo >/dev/null 2>&1; then
        if cargo clippy --version >/dev/null 2>&1; then
            run_check "cargo clippy" cargo clippy --quiet -- -D warnings
        else
            run_check "cargo check" cargo check --quiet
        fi
    fi
fi

if ! $RAN_SOMETHING; then
    STATUS="SKIP"
    if $STACK_DETECTED; then
        DETAILS+=("Stack detectada, mas nenhum verificador configurado/disponível (ex.: script \"lint\" no package.json, tsconfig.json, ruff). Configure um verificador ou rode o lint/compilador do projeto manualmente.")
    else
        DETAILS+=("Nenhuma stack suportada detectada (package.json, pyproject.toml, go.mod, Cargo.toml). Rode os verificadores do projeto manualmente.")
    fi
elif $FAILED; then
    STATUS="FAIL"
else
    STATUS="PASS"
fi

if $JSON_MODE; then
    DETAIL_STR=$(printf '%s; ' "${DETAILS[@]}")
    if has_jq; then
        jq -cn --arg status "$STATUS" --arg details "$DETAIL_STR" '{STATUS:$status,DETAILS:$details}'
    else
        printf '{"STATUS":"%s","DETAILS":"%s"}\n' "$STATUS" "$(json_escape "$DETAIL_STR")"
    fi
else
    echo ""
    echo "[Tommy] Quality check: $STATUS"
    for d in "${DETAILS[@]}"; do echo "  - $d"; done
fi

[ "$STATUS" = "FAIL" ] && exit 1
exit 0

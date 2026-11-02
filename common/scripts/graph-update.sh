#!/usr/bin/env bash
# Builds or refreshes the project's code knowledge graph with Graphify
# (graphify-out/graph.json + GRAPH_REPORT.md). Fully local: `graphify update`
# parses code (and markdown structure) with tree-sitter, and the LLM backends
# are disabled, so no source or doc leaves the machine.
# Graphify is a Tommy prerequisite, but the workflow degrades gracefully:
# when it is not installed this script reports SKIP and exits 0.

JSON_MODE=false
FULL=false
for arg in "$@"; do
    case "$arg" in
        --json) JSON_MODE=true ;;
        --full) FULL=true ;;
        --help|-h)
            echo "Uso: $0 [--json] [--full]"
            echo ""
            echo "  --json   Saída em formato JSON"
            echo "  --full   Força reconstrução completa (padrão: incremental quando o grafo já existe)"
            exit 0
            ;;
    esac
done

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT" || exit 1

GRAPH_FILE="$REPO_ROOT/graphify-out/graph.json"
REPORT_FILE="$REPO_ROOT/graphify-out/GRAPH_REPORT.md"

emit() {
    local status="$1" mode="$2" reason="$3"
    if $JSON_MODE; then
        if has_jq; then
            jq -cn --arg s "$status" --arg m "$mode" --arg g "$GRAPH_FILE" --arg r "$REPORT_FILE" --arg why "$reason" \
                '{STATUS:$s,MODE:$m,GRAPH_FILE:$g,REPORT_FILE:$r,REASON:$why}'
        else
            printf '{"STATUS":"%s","MODE":"%s","GRAPH_FILE":"%s","REPORT_FILE":"%s","REASON":"%s"}\n' \
                "$status" "$mode" "$(json_escape "$GRAPH_FILE")" "$(json_escape "$REPORT_FILE")" "$(json_escape "$reason")"
        fi
    else
        echo "[Tommy] graph: $status ($mode)${reason:+ — $reason}"
    fi
}

GRAPHIFY_BIN=$(command -v graphify 2>/dev/null)
[ -z "$GRAPHIFY_BIN" ] && [ -x "$HOME/.local/bin/graphify" ] && GRAPHIFY_BIN="$HOME/.local/bin/graphify"
if [ -z "$GRAPHIFY_BIN" ]; then
    emit "SKIP" "none" "graphify não instalado — rode 'npx sdd-tommy@latest --doctor' para ver como instalar"
    exit 0
fi

# Keep graphify-out/ out of version control without touching the project's
# .gitignore: .git/info/exclude is local to this clone.
if has_git && ! git check-ignore -q graphify-out/ 2>/dev/null; then
    EXCLUDE_FILE="$(git rev-parse --git-path info/exclude)"
    mkdir -p "$(dirname "$EXCLUDE_FILE")"
    echo "graphify-out/" >> "$EXCLUDE_FILE"
fi

export GRAPHIFY_BACKEND=none

# `update` also builds the graph from scratch; --force overwrites it even when
# the rebuild has fewer nodes (expected after refactors that delete code).
if $FULL || [ ! -f "$GRAPH_FILE" ]; then
    MODE="full"
    LOG=$("$GRAPHIFY_BIN" update . --force 2>&1)
else
    MODE="incremental"
    LOG=$("$GRAPHIFY_BIN" update . 2>&1)
fi
RC=$?

if [ $RC -ne 0 ]; then
    emit "FAIL" "$MODE" "$(echo "$LOG" | tail -5 | tr '\n' ' ')"
    exit 1
fi

emit "PASS" "$MODE" ""

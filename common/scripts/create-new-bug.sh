#!/usr/bin/env bash

set -e

JSON_MODE=false
SHORT_NAME=""
ARGS=()
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --short-name)
            if [ $((i + 1)) -gt $# ]; then
                echo 'Erro: --short-name requer um valor' >&2
                exit 1
            fi
            i=$((i + 1))
            next_arg="${!i}"
            if [[ "$next_arg" == --* ]]; then
                echo 'Erro: --short-name requer um valor' >&2
                exit 1
            fi
            SHORT_NAME="$next_arg"
            ;;
        --help|-h)
            echo "Uso: $0 [--json] [--short-name <nome>] <descrição_do_bug>"
            echo ""
            echo "Opções:"
            echo "  --json              Saída em formato JSON"
            echo "  --short-name <nome> Nome curto (2-4 palavras) para a pasta e a branch do bug"
            echo "  --help, -h          Exibe esta mensagem de ajuda"
            echo ""
            echo "Exemplo:"
            echo "  $0 'Login falha com e-mail em maiúsculas' --short-name 'login-email-case'"
            exit 0
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
    i=$((i + 1))
done

BUG_DESCRIPTION="${ARGS[*]}"
BUG_DESCRIPTION=$(echo "$BUG_DESCRIPTION" | xargs)
if [ -z "$BUG_DESCRIPTION" ]; then
    echo "Uso: $0 [--json] [--short-name <nome>] <descrição_do_bug>" >&2
    exit 1
fi

clean_name() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

BUGS_DIR="$REPO_ROOT/.tommy/bugs"
mkdir -p "$BUGS_DIR"

HIGHEST=0
for dir in "$BUGS_DIR"/*; do
    [ -d "$dir" ] || continue
    number=$(basename "$dir" | grep -o '^[0-9]\+' || echo "0")
    number=$((10#$number))
    [ "$number" -gt "$HIGHEST" ] && HIGHEST=$number
done

if [ -n "$SHORT_NAME" ]; then
    SUFFIX=$(clean_name "$SHORT_NAME")
else
    SUFFIX=$(clean_name "$BUG_DESCRIPTION" | tr '-' '\n' | grep -v '^$' | head -4 | tr '\n' '-' | sed 's/-$//')
fi
SUFFIX=$(echo "$SUFFIX" | cut -c1-80 | sed 's/-$//')

BUG_NUM=$(printf "%03d" "$((HIGHEST + 1))")
BUG_ID="${BUG_NUM}-${SUFFIX}"
BRANCH_NAME="fix/${BUG_ID}"
BUG_DIR="$BUGS_DIR/$BUG_ID"
BUG_FILE="$BUG_DIR/bug.md"

mkdir -p "$BUG_DIR"
TEMPLATE=$(resolve_template "bug-template" "$REPO_ROOT")
if [ -n "$TEMPLATE" ] && [ -f "$TEMPLATE" ]; then cp "$TEMPLATE" "$BUG_FILE"; else touch "$BUG_FILE"; fi

if $JSON_MODE; then
    if has_jq; then
        jq -cn \
            --arg branch_name "$BRANCH_NAME" \
            --arg bug_id "$BUG_ID" \
            --arg bug_dir "$BUG_DIR" \
            --arg bug_file "$BUG_FILE" \
            '{BRANCH_NAME:$branch_name,BUG_ID:$bug_id,BUG_DIR:$bug_dir,BUG_FILE:$bug_file}'
    else
        printf '{"BRANCH_NAME":"%s","BUG_ID":"%s","BUG_DIR":"%s","BUG_FILE":"%s"}\n' "$(json_escape "$BRANCH_NAME")" "$(json_escape "$BUG_ID")" "$(json_escape "$BUG_DIR")" "$(json_escape "$BUG_FILE")"
    fi
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "BUG_ID: $BUG_ID"
    echo "BUG_DIR: $BUG_DIR"
    echo "BUG_FILE: $BUG_FILE"
fi

#!/usr/bin/env bash

set -e

JSON_MODE=false
SPECS_DIR=""
BRANCH_NUMBER=""
ARGS=()
i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --spec-folder)
            i=$((i + 1))
            SPECS_DIR="${!i}"
            ;;
        --help|-h)
            echo "Uso: $0 [--json] [--spec-folder PATH]"
            echo ""
            echo "Opções:"
            echo "  --json              Saída em formato JSON"
            echo "  --help, -h          Exibe esta mensagem de ajuda"
            echo "  --spec-folder PATH  Especifica o diretório onde os arquivos de especificação serão criados (padrão: .tommy/specs)"
            echo ""
            exit 0
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
    i=$((i + 1))
done

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

if [ -z "$SPECS_DIR" ]; then
    SPECS_DIR="$REPO_ROOT/.tommy/specs"
fi
mkdir -p "$SPECS_DIR"

get_highest_from_checklists() {
    local specs_dir="$1"
    local highest=0
    local number

    if [ -d "$specs_dir/checklists" ]; then
        for prompt in "$specs_dir"/checklists/*.md; do
            [ -f "$prompt" ] || continue

            filename=$(basename "$prompt")

            [[ "$filename" == *codegen* ]] || continue

            number=$(echo "$filename" | grep -o '^[0-9]\+' || echo "0")
            number=$((10#$number))

            if [ "$number" -gt "$highest" ]; then
                highest=$number
            fi
        done
    fi

    echo "$highest"
}

if [ -z "$BRANCH_NUMBER" ]; then
        HIGHEST=$(get_highest_from_checklists "$SPECS_DIR")
        BRANCH_NUMBER=$((HIGHEST + 1))

    else
        if ! [[ "$BRANCH_NUMBER" =~ ^[0-9]+$ ]]; then
            echo "Erro: O número da branch deve ser um inteiro positivo" >&2
            exit 1
    fi
fi

FEATURE_NUM=$(printf "%03d" "$((10#$BRANCH_NUMBER))")
BRANCH_NAME="${FEATURE_NUM}_codegen_checklist"

MAX_BRANCH_LENGTH=244
if [ ${#BRANCH_NAME} -gt $MAX_BRANCH_LENGTH ]; then
    MAX_SUFFIX_LENGTH=$((MAX_BRANCH_LENGTH - 4))

    TRUNCATED_SUFFIX=$(echo "$BRANCH_SUFFIX" | cut -c1-$MAX_SUFFIX_LENGTH)
    TRUNCATED_SUFFIX=$(echo "$TRUNCATED_SUFFIX" | sed 's/-$//')

    ORIGINAL_BRANCH_NAME="$BRANCH_NAME"
    BRANCH_NAME="${FEATURE_NUM}-${TRUNCATED_SUFFIX}"

    >&2 echo "[Tommy] Original: $ORIGINAL_BRANCH_NAME (${#ORIGINAL_BRANCH_NAME} bytes)"
    >&2 echo "[Tommy] Truncado para: $BRANCH_NAME (${#BRANCH_NAME} bytes)"
fi



CHECKLIST_TEMPLATE=$(resolve_template "codegen-checklist" "$REPO_ROOT")
CHECKLIST_FILE="$SPECS_DIR/checklists/${BRANCH_NAME}.md"

mkdir -p "$(dirname "$CHECKLIST_FILE")"
if [ -n "$CHECKLIST_TEMPLATE" ] && [ -f "$CHECKLIST_TEMPLATE" ]; then
    cp "$CHECKLIST_TEMPLATE" "$CHECKLIST_FILE"
else
    touch "$CHECKLIST_FILE"
fi

if $JSON_MODE; then
    if command -v jq >/dev/null 2>&1; then
        jq -cn \
            --arg branch_name "$BRANCH_NAME" \
            --arg checklist_file "$CHECKLIST_FILE" \
            --arg feature_num "$FEATURE_NUM" \
            '{BRANCH_NAME:$branch_name,CHECKLIST_FILE:$checklist_file,FEATURE_NUM:$feature_num}'
    else
        printf '{"BRANCH_NAME":"%s","CHECKLIST_FILE":"%s","FEATURE_NUM":"%s"}\n' "$(json_escape "$BRANCH_NAME")" "$(json_escape "$CHECKLIST_FILE")" "$(json_escape "$FEATURE_NUM")"
    fi
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "CHECKLIST_FILE: $CHECKLIST_FILE"
    echo "FEATURE_NUM: $FEATURE_NUM"
fi

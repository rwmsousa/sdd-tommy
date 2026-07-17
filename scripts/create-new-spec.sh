#!/usr/bin/env bash

set -e

JSON_MODE=false
SHORT_NAME=""
BRANCH_NUMBER=""
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
            # Check if the next argument is another option (starts with --)
            if [[ "$next_arg" == --* ]]; then
                echo 'Erro: --short-name requer um valor' >&2
                exit 1
            fi
            SHORT_NAME="$next_arg"
            ;;
        --help|-h)
            echo "Uso: $0 [--json] [--short-name <nome>] <descrição_da_feature>"
            echo ""
            echo "Opções:"
            echo "  --json              Saída em formato JSON"
            echo "  --short-name <nome> Fornece um nome curto personalizado (2-4 palavras) para a branch"
            echo "  --help, -h          Exibe esta mensagem de ajuda"
            echo ""
            echo "Exemplos:"
            echo "  $0 'Add user authentication system' --short-name 'user-auth'"
            echo "  $0 'Implement OAuth2 integration for API' --short-name 'oauth2-api-integration'"
            exit 0
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
    i=$((i + 1))
done

FEATURE_DESCRIPTION="${ARGS[*]}"
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Uso: $0 [--json] [--short-name <nome>] <descrição_da_feature>" >&2
    exit 1
fi

FEATURE_DESCRIPTION=$(echo "$FEATURE_DESCRIPTION" | xargs)
if [ -z "$FEATURE_DESCRIPTION" ]; then
    echo "Erro: A descrição da feature não pode ser vazia ou conter apenas espaços em branco" >&2
    exit 1
fi

get_highest_from_specs() {
    local specs_dir="$1"
    local highest=0

    if [ -d "$specs_dir" ]; then
        for dir in "$specs_dir"/*; do
            [ -d "$dir" ] || continue
            dirname=$(basename "$dir")
            number=$(echo "$dirname" | grep -o '^[0-9]\+' || echo "0")
            number=$((10#$number))
            if [ "$number" -gt "$highest" ]; then
                highest=$number
            fi
        done
    fi

    echo "$highest"
}

clean_branch_name() {
    local name="$1"
    echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-//' | sed 's/-$//'
}

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
cd "$REPO_ROOT"

SPECS_DIR="$REPO_ROOT/.tommy/specs"
mkdir -p "$SPECS_DIR"

generate_branch_name() {
    local description="$1"

    local stop_words="^(i|a|an|the|to|for|of|in|on|at|by|with|from|is|are|was|were|be|been|being|have|has|had|do|does|did|will|would|should|could|can|may|might|must|shall|this|that|these|those|my|your|our|their|want|need|add|get|set)$"

    local clean_name=$(echo "$description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g')

    local meaningful_words=()
    for word in $clean_name; do
        [ -z "$word" ] && continue

        if ! echo "$word" | grep -qiE "$stop_words"; then
            if [ ${#word} -ge 3 ]; then
                meaningful_words+=("$word")
            elif echo "$description" | grep -q "\b${word^^}\b"; then
                meaningful_words+=("$word")
            fi
        fi
    done

    if [ ${#meaningful_words[@]} -gt 0 ]; then
        local max_words=3
        if [ ${#meaningful_words[@]} -eq 4 ]; then max_words=4; fi

        local result=""
        local count=0
        for word in "${meaningful_words[@]}"; do
            if [ $count -ge $max_words ]; then break; fi
            if [ -n "$result" ]; then result="$result-"; fi
            result="$result$word"
            count=$((count + 1))
        done
        echo "$result"
    else
        local cleaned=$(clean_branch_name "$description")
        echo "$cleaned" | tr '-' '\n' | grep -v '^$' | head -3 | tr '\n' '-' | sed 's/-$//'
    fi
}

if [ -n "$SHORT_NAME" ]; then
    BRANCH_SUFFIX=$(clean_branch_name "$SHORT_NAME")
else
    BRANCH_SUFFIX=$(generate_branch_name "$FEATURE_DESCRIPTION")
fi

if [ -z "$BRANCH_NUMBER" ]; then
        HIGHEST=$(get_highest_from_specs "$SPECS_DIR")
        BRANCH_NUMBER=$((HIGHEST + 1))

    else
        if ! [[ "$BRANCH_NUMBER" =~ ^[0-9]+$ ]]; then
            echo "Erro: O número da branch deve ser um inteiro positivo" >&2
            exit 1
    fi
fi

FEATURE_NUM=$(printf "%03d" "$((10#$BRANCH_NUMBER))")
BRANCH_NAME="${FEATURE_NUM}-${BRANCH_SUFFIX}"

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

FEATURE_DIR="$SPECS_DIR/$BRANCH_NAME"
mkdir -p "$FEATURE_DIR"

TEMPLATE=$(resolve_template "spec-template" "$REPO_ROOT")
CHECKLIST_TEMPLATE=$(resolve_template "checklist-template" "$REPO_ROOT")
SPEC_FILE="$FEATURE_DIR/spec.md"
CHECKLIST_FILE="$FEATURE_DIR/checklists/requirements.md"

if [ -n "$TEMPLATE" ] && [ -f "$TEMPLATE" ]; then cp "$TEMPLATE" "$SPEC_FILE"; else touch "$SPEC_FILE"; fi

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
            --arg spec_file "$SPEC_FILE" \
            --arg feature_dir "$FEATURE_DIR" \
            --arg checklist_file "$CHECKLIST_FILE" \
            --arg feature_num "$FEATURE_NUM" \
            '{BRANCH_NAME:$branch_name,SPEC_FILE:$spec_file,FEATURE_DIR:$feature_dir,CHECKLIST_FILE:$checklist_file,FEATURE_NUM:$feature_num}'
    else
        printf '{"BRANCH_NAME":"%s","SPEC_FILE":"%s","FEATURE_DIR":"%s","CHECKLIST_FILE":"%s","FEATURE_NUM":"%s"}\n' "$(json_escape "$BRANCH_NAME")" "$(json_escape "$SPEC_FILE")" "$(json_escape "$FEATURE_DIR")" "$(json_escape "$CHECKLIST_FILE")" "$(json_escape "$FEATURE_NUM")"
    fi
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "SPEC_FILE: $SPEC_FILE"
    echo "FEATURE_DIR: $FEATURE_DIR"
    echo "CHECKLIST_FILE: $CHECKLIST_FILE"
    echo "FEATURE_NUM: $FEATURE_NUM"
    printf '# To persist in your shell: export TOMMY_FEATURE=%q\n' "$BRANCH_NAME"
fi

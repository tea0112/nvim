#!/usr/bin/env sh
set -eu

fail() {
    printf '%s\n' "error: $*" >&2
    exit 1
}

usage() {
    cat <<'EOF'
Usage:
  ./install-ts-parsers.sh [LANG_OR_FILETYPE...]
  ./install-ts-parsers.sh --list

Without arguments, this installs the languages enabled in lua/config/treesitter.lua,
but skips parsers that are already built into Neovim.

Environment:
  NVIM_TS_LANGS="go java rust"    Languages to install when no args are given
  NVIM_TS_FORCE_BUILTIN=1         Also build/copy queries for built-in languages
  KEEP_TS_BUILD=1                 Keep the temporary build directory
  NVIM_TS_PARSER_DIR=...          Parser output directory
  NVIM_TS_QUERY_DIR=...           Query output directory
EOF
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || fail "missing required command: $1"
}

script_dir() {
    CDPATH= cd "$(dirname "$0")" && pwd
}

library_ext() {
    case "$(uname -s)" in
        Darwin) printf '%s\n' dylib ;;
        MINGW* | MSYS* | CYGWIN*) printf '%s\n' dll ;;
        *) printf '%s\n' so ;;
    esac
}

contains_word() {
    needle="$1"
    list="$2"

    for word in $list; do
        [ "$word" = "$needle" ] && return 0
    done

    return 1
}

join_args() {
    result=""

    for arg do
        result="${result}${result:+ }$arg"
    done

    printf '%s\n' "$result"
}

clone_nvim_treesitter() {
    printf 'Cloning nvim-treesitter parser registry and queries...\n'
    git clone --depth 1 https://github.com/nvim-treesitter/nvim-treesitter "$NVIM_TREESITTER_SOURCE"

    if [ -d "$NVIM_TREESITTER_SOURCE/runtime/queries" ]; then
        QUERY_SOURCE_ROOT="$NVIM_TREESITTER_SOURCE/runtime/queries"
    elif [ -d "$NVIM_TREESITTER_SOURCE/queries" ]; then
        QUERY_SOURCE_ROOT="$NVIM_TREESITTER_SOURCE/queries"
    else
        fail "could not find nvim-treesitter query directory"
    fi
}

write_registry_helper() {
    cat >"$REGISTRY_HELPER" <<'LUA'
local registry = assert(vim.env.NVIM_TS_REGISTRY)
local mode = assert(vim.env.NVIM_TS_MODE)
local output = assert(vim.env.NVIM_TS_OUTPUT)

local function write(lines)
    vim.fn.writefile(lines, output)
end

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function load_configs()
    local parser_file = registry .. "/lua/nvim-treesitter/parsers.lua"
    local ok, result = pcall(dofile, parser_file)

    if ok and type(result) == "table" then
        if type(result.get_parser_configs) == "function" then
            return result.get_parser_configs()
        end

        return result
    end

    vim.opt.runtimepath:prepend(registry)
    local ok_mod, mod = pcall(require, "nvim-treesitter.parsers")
    if ok_mod and type(mod.get_parser_configs) == "function" then
        return mod.get_parser_configs()
    end

    error("could not load nvim-treesitter parser registry")
end

local configs = load_configs()

if mode == "list" then
    write(sorted_keys(configs))
    return
end

if mode == "default" then
    local config_dir = assert(vim.env.NVIM_TS_CONFIG_DIR)
    vim.opt.runtimepath:prepend(config_dir)

    local ok, cfg = pcall(require, "config.treesitter")
    if not ok or type(cfg) ~= "table" or type(cfg.enabled) ~= "table" then
        write({})
        return
    end

    local languages = {}
    for lang, enabled in pairs(cfg.enabled) do
        if enabled then
            table.insert(languages, lang)
        end
    end

    table.sort(languages)
    write(languages)
    return
end

if mode ~= "info" then
    error("unknown mode: " .. mode)
end

local requested = assert(vim.env.NVIM_TS_LANG)
local canonical = requested
local cfg = configs[canonical]

if not cfg then
    local mapped = vim.treesitter.language.get_lang(requested)
    if mapped and configs[mapped] then
        canonical = mapped
        cfg = configs[canonical]
    end
end

if not cfg then
    for lang, parser_cfg in pairs(configs) do
        if parser_cfg.filetype == requested then
            canonical = lang
            cfg = parser_cfg
            break
        end
    end
end

if not cfg then
    write({ "missing", requested })
    return
end

local install_info = cfg.install_info or {}
local requires = cfg.requires or {}
local generate = install_info.generate or install_info.requires_generate_from_grammar or false

write({
    "ok",
    canonical,
    install_info.url or "",
    install_info.branch or "",
    install_info.revision or "",
    install_info.location or "",
    install_info.path or "",
    table.concat(requires, " "),
    generate and "1" or "",
})
LUA
}

run_registry_helper() {
    mode="$1"
    output="$2"
    lang="${3:-}"

    NVIM_TS_HELPER="$REGISTRY_HELPER" \
        NVIM_TS_REGISTRY="$NVIM_TREESITTER_SOURCE" \
        NVIM_TS_MODE="$mode" \
        NVIM_TS_OUTPUT="$output" \
        NVIM_TS_LANG="$lang" \
        NVIM_TS_CONFIG_DIR="$SCRIPT_DIR" \
        nvim --clean --headless -u NONE +'lua dofile(vim.env.NVIM_TS_HELPER)' +qa
}

list_registry_languages() {
    output="$TMP_DIR/languages.txt"
    run_registry_helper list "$output"

    while IFS= read -r lang; do
        printf '%s\n' "$lang"
    done <"$output"
}

configured_languages() {
    output="$TMP_DIR/default-languages.txt"
    run_registry_helper default "$output"

    result=""
    while IFS= read -r lang; do
        result="${result}${result:+ }$lang"
    done <"$output"

    printf '%s\n' "$result"
}

read_parser_info() {
    requested="$1"
    output="$TMP_DIR/parser-info-$requested.txt"

    run_registry_helper info "$output" "$requested"

    {
        IFS= read -r INFO_STATUS || true
        IFS= read -r INFO_LANG || true
        IFS= read -r INFO_URL || true
        IFS= read -r INFO_BRANCH || true
        IFS= read -r INFO_REVISION || true
        IFS= read -r INFO_LOCATION || true
        IFS= read -r INFO_PATH || true
        IFS= read -r INFO_REQUIRES || true
        IFS= read -r INFO_GENERATE || true
    } <"$output"
}

is_builtin_parser() {
    lang="$1"

    NVIM_TS_LANG="$lang" nvim --clean --headless -u NONE +'lua local ok = pcall(vim.treesitter.language.inspect, vim.env.NVIM_TS_LANG); if ok then os.exit(0) end; os.exit(1)' +qa >/dev/null 2>&1
}

copy_queries() {
    lang="$1"

    if [ ! -d "$QUERY_SOURCE_ROOT/$lang" ]; then
        printf 'No nvim-treesitter queries for %s; skipping queries.\n' "$lang"
        return
    fi

    rm -rf "$QUERY_DIR/$lang"
    cp -R "$QUERY_SOURCE_ROOT/$lang" "$QUERY_DIR/$lang"
    printf 'Installed %s queries.\n' "$lang"
}

clone_parser_source() {
    lang="$1"
    parser_source="$TMP_DIR/parser-$lang"

    if [ -n "$INFO_PATH" ]; then
        [ -d "$INFO_PATH" ] || fail "local parser path does not exist for $lang: $INFO_PATH"
        PARSER_SOURCE="$INFO_PATH"
        return
    fi

    [ -n "$INFO_URL" ] || fail "no parser source URL for $lang"

    printf 'Cloning %s parser...\n' "$lang"
    if [ -n "$INFO_BRANCH" ] && [ -z "$INFO_REVISION" ]; then
        git clone --depth 1 --branch "$INFO_BRANCH" "$INFO_URL" "$parser_source"
    else
        git clone --depth 1 "$INFO_URL" "$parser_source"
    fi

    if [ -n "$INFO_REVISION" ]; then
        git -C "$parser_source" fetch --depth 1 origin "$INFO_REVISION"
        git -C "$parser_source" checkout --detach FETCH_HEAD >/dev/null 2>&1
    fi

    PARSER_SOURCE="$parser_source"
}

build_parser() {
    lang="$1"
    grammar_dir="$PARSER_SOURCE"
    parser_output="$PARSER_DIR/$lang.$LIB_EXT"

    if [ -n "$INFO_LOCATION" ]; then
        grammar_dir="$PARSER_SOURCE/$INFO_LOCATION"
    fi

    [ -d "$grammar_dir" ] || fail "parser grammar directory does not exist for $lang: $grammar_dir"

    if [ "$INFO_GENERATE" = "1" ] || [ ! -f "$grammar_dir/src/parser.c" ]; then
        [ -f "$grammar_dir/grammar.js" ] || [ -f "$grammar_dir/grammar.json" ] || fail "cannot generate parser for $lang: missing grammar.js or grammar.json"
        printf 'Generating %s parser...\n' "$lang"
        (cd "$grammar_dir" && tree-sitter generate)
    fi

    printf 'Building %s parser...\n' "$lang"
    tree-sitter build --output "$parser_output" "$grammar_dir"
}

install_language() {
    requested="$1"

    read_parser_info "$requested"

    if [ "$INFO_STATUS" = "missing" ]; then
        fail "$requested is not in the nvim-treesitter parser registry"
    fi

    lang="$INFO_LANG"

    if contains_word "$lang" "$DONE_LANGS"; then
        return
    fi

    for required_lang in $INFO_REQUIRES; do
        if ! contains_word "$required_lang" "$DONE_LANGS" && ! contains_word "$required_lang" "$LANG_QUEUE"; then
            LANG_QUEUE="${LANG_QUEUE}${LANG_QUEUE:+ }$required_lang"
        fi
    done

    if is_builtin_parser "$lang" && [ "${NVIM_TS_FORCE_BUILTIN:-0}" != "1" ]; then
        printf 'Skipping %s: parser is built into Neovim.\n' "$lang"
        DONE_LANGS="${DONE_LANGS}${DONE_LANGS:+ }$lang"
        return
    fi

    if [ -n "$INFO_URL" ] || [ -n "$INFO_PATH" ]; then
        clone_parser_source "$lang"
        build_parser "$lang"
    else
        printf 'Skipping %s parser build: query-only language.\n' "$lang"
    fi

    copy_queries "$lang"
    DONE_LANGS="${DONE_LANGS}${DONE_LANGS:+ }$lang"
}

LIST_ONLY=0

case "${1:-}" in
    -h | --help)
        usage
        exit 0
        ;;
    --list)
        LIST_ONLY=1
        shift
        ;;
esac

[ "$#" -eq 0 ] || [ "$LIST_ONLY" -eq 0 ] || fail "--list does not take language arguments"

require_command git
require_command tree-sitter
require_command node
require_command cc
require_command mktemp
require_command uname
require_command nvim

SCRIPT_DIR="$(script_dir)"
PARSER_DIR="${NVIM_TS_PARSER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/parser}"
QUERY_DIR="${NVIM_TS_QUERY_DIR:-$SCRIPT_DIR/queries}"
LIB_EXT="$(library_ext)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/nvim-ts-parsers.XXXXXX")"
NVIM_TREESITTER_SOURCE="$TMP_DIR/nvim-treesitter"
REGISTRY_HELPER="$TMP_DIR/registry-helper.lua"
QUERY_SOURCE_ROOT=""
LANG_QUEUE=""
DONE_LANGS=""

cleanup() {
    if [ "${KEEP_TS_BUILD:-0}" = "1" ]; then
        printf 'Keeping temporary build directory: %s\n' "$TMP_DIR"
    else
        rm -rf "$TMP_DIR"
    fi
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 129' HUP
trap 'exit 143' TERM

[ -n "$QUERY_DIR" ] || fail "empty query directory"
[ "$QUERY_DIR" != / ] || fail "query directory cannot be /"

mkdir -p "$PARSER_DIR" "$QUERY_DIR"

clone_nvim_treesitter
write_registry_helper

if [ "$LIST_ONLY" -eq 1 ]; then
    list_registry_languages
    exit 0
fi

if [ "$#" -gt 0 ]; then
    LANG_QUEUE="$(join_args "$@")"
elif [ -n "${NVIM_TS_LANGS:-}" ]; then
    LANG_QUEUE="$NVIM_TS_LANGS"
else
    LANG_QUEUE="$(configured_languages)"
fi

[ -n "$LANG_QUEUE" ] || fail "no languages requested"

while [ -n "$LANG_QUEUE" ]; do
    set -- $LANG_QUEUE
    requested_lang="$1"
    shift || true
    LANG_QUEUE="$(join_args "$@")"

    install_language "$requested_lang"
done

printf 'Installed parsers to %s\n' "$PARSER_DIR"
printf 'Installed queries to %s\n' "$QUERY_DIR"

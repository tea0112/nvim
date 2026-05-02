local M = {}

local uv = vim.uv or vim.loop

local function notify(msg, level)
    vim.schedule(function()
        vim.notify(msg, level or vim.log.levels.INFO, { title = "treesitter installer" })
    end)
end

local function fail(msg)
    error({ treesitter_installer_error = true, message = msg }, 0)
end

local function error_message(err)
    if type(err) == "table" and err.treesitter_installer_error then
        return err.message
    end

    return tostring(err)
end

local function file_exists(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "file"
end

local function dir_exists(path)
    local stat = uv.fs_stat(path)
    return stat and stat.type == "directory"
end

local function mkdir_p(path)
    vim.fn.mkdir(path, "p")
end

local function rm_rf(path)
    if not file_exists(path) and not dir_exists(path) then
        return
    end

    if dir_exists(path) then
        vim.fn.delete(path, "rf")
    else
        vim.fn.delete(path)
    end
end

local function split_words(value)
    local result = {}
    for word in string.gmatch(value or "", "%S+") do
        table.insert(result, word)
    end
    return result
end

local function sorted_enabled_languages(enabled)
    local languages = {}
    for lang, is_enabled in pairs(enabled or {}) do
        if is_enabled then
            table.insert(languages, lang)
        end
    end
    table.sort(languages)
    return languages
end

local function library_ext()
    local system = uv.os_uname().sysname
    if system == "Darwin" then
        return "dylib"
    elseif system == "Windows_NT" then
        return "dll"
    end

    return "so"
end

local function copy_recursive(src, dst)
    local stat = uv.fs_stat(src)
    if not stat then
        return
    end

    if stat.type == "directory" then
        mkdir_p(dst)
        local handle = uv.fs_scandir(src)
        if not handle then
            return
        end

        while true do
            local name = uv.fs_scandir_next(handle)
            if not name then
                break
            end
            copy_recursive(src .. "/" .. name, dst .. "/" .. name)
        end
        return
    end

    mkdir_p(vim.fn.fnamemodify(dst, ":h"))
    local ok, copy_err = uv.fs_copyfile(src, dst)
    if not ok then
        fail("failed to copy " .. src .. " to " .. dst .. ": " .. tostring(copy_err))
    end
end

local function run_cmd(cmd, opts)
    opts = opts or {}
    opts.text = true

    local result = vim.system(cmd, opts):wait()
    if result.code ~= 0 then
        local stderr = result.stderr or ""
        fail(table.concat(cmd, " ") .. " failed" .. (stderr ~= "" and ": " .. stderr or ""))
    end

    return result
end

local function require_commands(commands)
    for _, command in ipairs(commands) do
        if vim.fn.executable(command) == 0 then
            fail("missing required command: " .. command)
        end
    end
end

local function parser_available(lang)
    local ok = pcall(vim.treesitter.language.inspect, lang)
    return ok
end

local function parser_output_path(opts, lang)
    return opts.parser_dir .. "/" .. lang .. "." .. opts.lib_ext
end

local function query_path(opts, lang)
    return opts.query_dir .. "/" .. lang
end

local function local_work_needed(opts, requested)
    local lang = vim.treesitter.language.get_lang(requested) or requested

    if not parser_available(lang) then
        return true
    end

    if file_exists(parser_output_path(opts, lang)) and not dir_exists(query_path(opts, lang)) then
        return true
    end

    return false
end

local function debounce_file(opts)
    return opts.debounce_file or (vim.fn.stdpath("state") .. "/treesitter-installer-debounce")
end

local function debounce_active(opts)
    local hours = opts.debounce_hours
    if not hours or hours <= 0 then
        return false
    end

    local stat = uv.fs_stat(debounce_file(opts))
    if not stat then
        return false
    end

    return os.time() - stat.mtime.sec < hours * 60 * 60
end

local function touch_debounce(opts)
    local path = debounce_file(opts)
    mkdir_p(vim.fn.fnamemodify(path, ":h"))
    vim.fn.writefile({ tostring(os.time()) }, path)
end

local function clone_nvim_treesitter(tmp_dir)
    local source = tmp_dir .. "/nvim-treesitter"
    notify("Cloning nvim-treesitter parser registry and queries")
    run_cmd({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/nvim-treesitter/nvim-treesitter",
        source,
    })
    return source
end

local function load_nvim_treesitter(source)
    local parser_file = source .. "/lua/nvim-treesitter/parsers.lua"
    local ok, result = pcall(dofile, parser_file)

    if ok and type(result) == "table" then
        if type(result.get_parser_configs) == "function" then
            return result.get_parser_configs()
        end
        return result
    end

    vim.opt.runtimepath:prepend(source)
    local ok_mod, mod = pcall(require, "nvim-treesitter.parsers")
    if ok_mod and type(mod.get_parser_configs) == "function" then
        return mod.get_parser_configs()
    end

    fail("could not load nvim-treesitter parser registry")
end

local function get_query_source_root(source)
    local runtime = source .. "/runtime/queries"
    if dir_exists(runtime) then
        return runtime
    end

    local queries = source .. "/queries"
    if dir_exists(queries) then
        return queries
    end

    fail("could not find nvim-treesitter query directory")
end

local function get_parser_info(configs, requested)
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
        return { status = "missing", requested = requested }
    end

    local install_info = cfg.install_info or {}
    local requires = cfg.requires or {}
    if type(requires) ~= "table" then
        requires = {}
    end

    return {
        status = "ok",
        lang = canonical,
        url = install_info.url or "",
        branch = install_info.branch or "",
        revision = install_info.revision or "",
        location = install_info.location or "",
        path = install_info.path or "",
        requires = requires,
        generate = install_info.generate or install_info.requires_generate_from_grammar or false,
    }
end

local function copy_queries(opts, query_source_root, lang)
    local src = query_source_root .. "/" .. lang
    if not dir_exists(src) then
        notify("No nvim-treesitter queries for " .. lang .. "; skipping queries")
        return
    end

    local dst = query_path(opts, lang)
    rm_rf(dst)
    copy_recursive(src, dst)
    notify("Installed " .. lang .. " queries")
end

local function clone_parser_source(opts, parser_info)
    if parser_info.path ~= "" then
        if not dir_exists(parser_info.path) then
            fail("local parser path does not exist for " .. parser_info.lang .. ": " .. parser_info.path)
        end
        return parser_info.path
    end

    if parser_info.url == "" then
        fail("no parser source URL for " .. parser_info.lang)
    end

    local parser_source = opts.tmp_dir .. "/parser-" .. parser_info.lang
    notify("Cloning " .. parser_info.lang .. " parser")

    if parser_info.branch ~= "" and parser_info.revision == "" then
        run_cmd({ "git", "clone", "--depth", "1", "--branch", parser_info.branch, parser_info.url, parser_source })
    else
        run_cmd({ "git", "clone", "--depth", "1", parser_info.url, parser_source })
    end

    if parser_info.revision ~= "" then
        run_cmd({ "git", "-C", parser_source, "fetch", "--depth", "1", "origin", parser_info.revision })
        run_cmd({ "git", "-C", parser_source, "checkout", "--detach", "FETCH_HEAD" })
    end

    return parser_source
end

local function build_parser(opts, parser_info, parser_source)
    local grammar_dir = parser_source
    if parser_info.location ~= "" then
        grammar_dir = parser_source .. "/" .. parser_info.location
    end

    if not dir_exists(grammar_dir) then
        fail("parser grammar directory does not exist for " .. parser_info.lang .. ": " .. grammar_dir)
    end

    local needs_generate = parser_info.generate or not file_exists(grammar_dir .. "/src/parser.c")
    if needs_generate then
        if not file_exists(grammar_dir .. "/grammar.js") and not file_exists(grammar_dir .. "/grammar.json") then
            fail("cannot generate parser for " .. parser_info.lang .. ": missing grammar.js or grammar.json")
        end

        notify("Generating " .. parser_info.lang .. " parser")
        run_cmd({ "tree-sitter", "generate" }, { cwd = grammar_dir })
    end

    notify("Building " .. parser_info.lang .. " parser")
    run_cmd({ "tree-sitter", "build", "--output", parser_output_path(opts, parser_info.lang), grammar_dir })
end

local function has_value(list, value)
    for _, item in ipairs(list) do
        if item == value then
            return true
        end
    end
    return false
end

local function install_language(opts, configs, query_source_root, requested, done, queue)
    local parser_info = get_parser_info(configs, requested)
    if parser_info.status == "missing" then
        fail(requested .. " is not in the nvim-treesitter parser registry")
    end

    local lang = parser_info.lang
    if done[lang] then
        return
    end

    for _, required_lang in ipairs(parser_info.requires) do
        if not done[required_lang] and not has_value(queue, required_lang) then
            table.insert(queue, required_lang)
        end
    end

    local parser_output_exists = file_exists(parser_output_path(opts, lang))
    if parser_available(lang) and not parser_output_exists and not opts.force_builtin then
        notify("Skipping " .. lang .. ": parser is already available to Neovim")
        done[lang] = true
        return
    end

    if parser_available(lang) and parser_output_exists and not opts.force then
        if not dir_exists(query_path(opts, lang)) then
            copy_queries(opts, query_source_root, lang)
        end
        done[lang] = true
        return
    end

    if parser_info.url ~= "" or parser_info.path ~= "" then
        local parser_source = clone_parser_source(opts, parser_info)
        build_parser(opts, parser_info, parser_source)
    else
        notify("Skipping " .. lang .. " parser build: query-only language")
    end

    if opts.update_queries or not dir_exists(query_path(opts, lang)) then
        copy_queries(opts, query_source_root, lang)
    end
    done[lang] = true
end

local function normalized_opts(opts)
    opts = vim.tbl_extend("force", {
        debounce_hours = 5,
        force = false,
        force_builtin = vim.env.NVIM_TS_FORCE_BUILTIN == "1",
        parser_dir = vim.env.NVIM_TS_PARSER_DIR or (vim.fn.stdpath("data") .. "/site/parser"),
        query_dir = vim.env.NVIM_TS_QUERY_DIR or (vim.fn.stdpath("config") .. "/queries"),
        start_delay = 3000,
        update_queries = vim.env.NVIM_TS_UPDATE_QUERIES == "1",
    }, opts or {})
    opts.lib_ext = library_ext()
    return opts
end

local function requested_languages(opts)
    if vim.env.NVIM_TS_LANGS and vim.env.NVIM_TS_LANGS ~= "" then
        return split_words(vim.env.NVIM_TS_LANGS)
    end

    if opts.languages and #opts.languages > 0 then
        return opts.languages
    end

    return sorted_enabled_languages(opts.enabled)
end

M.ensure = function(opts)
    opts = normalized_opts(opts)

    if vim.env.NVIM_TS_INSTALL_DISABLED == "1" then
        return true
    end

    local languages = requested_languages(opts)
    if #languages == 0 then
        return true
    end

    local needed = {}
    for _, lang in ipairs(languages) do
        if opts.force or local_work_needed(opts, lang) then
            table.insert(needed, lang)
        end
    end

    if #needed == 0 then
        return true
    end

    if not opts.force and debounce_active(opts) then
        notify("Skipping Tree-sitter parser install because it ran recently")
        return true
    end

    touch_debounce(opts)

    local ok, err = xpcall(function()
        require_commands({ "git", "tree-sitter", "node", "cc" })

        if opts.query_dir == "" or opts.query_dir == "/" then
            fail("invalid query directory: " .. opts.query_dir)
        end

        mkdir_p(opts.parser_dir)
        mkdir_p(opts.query_dir)

        opts.tmp_dir = vim.fn.tempname()
        mkdir_p(opts.tmp_dir)

        local source = clone_nvim_treesitter(opts.tmp_dir)
        local query_source_root = get_query_source_root(source)
        local configs = load_nvim_treesitter(source)
        local queue = vim.deepcopy(needed)
        local done = {}

        while #queue > 0 do
            local requested = table.remove(queue, 1)
            install_language(opts, configs, query_source_root, requested, done, queue)
        end

        if type(opts.on_install) == "function" then
            opts.on_install(needed)
        end

        notify("Installed Tree-sitter parsers to " .. opts.parser_dir)
    end, function(run_err)
        return run_err
    end)

    if opts.tmp_dir then
        if vim.env.KEEP_TS_BUILD == "1" then
            notify("Keeping temporary Tree-sitter build directory: " .. opts.tmp_dir)
        else
            rm_rf(opts.tmp_dir)
        end
    end

    if not ok then
        notify(error_message(err), vim.log.levels.ERROR)
        return false
    end

    return true
end

M.setup = function(opts)
    opts = normalized_opts(opts)

    vim.api.nvim_create_user_command("TSParsersEnsure", function(command)
        local languages = #command.fargs > 0 and command.fargs or nil
        M.ensure(vim.tbl_extend("force", opts, { force = true, languages = languages }))
    end, { nargs = "*", force = true })

    if opts.run_on_start == false then
        return
    end

    vim.api.nvim_create_autocmd("VimEnter", {
        group = vim.api.nvim_create_augroup("user_treesitter_installer", { clear = true }),
        once = true,
        callback = function()
            vim.defer_fn(function()
                M.ensure(opts)
            end, opts.start_delay)
        end,
    })
end

return M

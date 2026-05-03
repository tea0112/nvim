local M = {}

local GENERATED_HEADING = "## Generated keymaps"
local MANUAL_HEADING = "## Manual notes"

local modes = {
    { "n", "Normal" },
    { "i", "Insert" },
    { "v", "Visual" },
    { "x", "Visual Block" },
    { "s", "Select" },
    { "o", "Operator Pending" },
    { "t", "Terminal" },
}

local function note_path()
    return vim.fn.stdpath("config") .. "/KEYBINDINGS.md"
end

local function md_escape(value)
    value = tostring(value or "")
    value = value:gsub("|", "\\|")
    value = value:gsub("\n", " ")
    return value
end

local function sort_maps(a, b)
    return tostring(a.lhs) < tostring(b.lhs)
end

local function generate_auto_section()
    local lines = {
        GENERATED_HEADING,
        "",
        "_This section is generated from current Neovim keymaps. Do not edit inside this block._",
        "",
    }

    for _, mode in ipairs(modes) do
        local mode_key = mode[1]
        local mode_name = mode[2]
        local maps = vim.api.nvim_get_keymap(mode_key)

        local documented = {}
        for _, map in ipairs(maps) do
            if map.desc and map.desc ~= "" then
                table.insert(documented, map)
            end
        end

        table.sort(documented, sort_maps)

        table.insert(lines, "### " .. mode_name)
        table.insert(lines, "")
        table.insert(lines, "| Key | Description | Command |")
        table.insert(lines, "|---|---|---|")

        if #documented == 0 then
            table.insert(lines, "| _none_ | _No mappings with `desc` found_ | |")
        else
            for _, map in ipairs(documented) do
                local rhs = map.rhs or map.callback and "<Lua callback>" or ""
                table.insert(
                    lines,
                    string.format("| `%s` | %s | `%s` |", md_escape(map.lhs), md_escape(map.desc), md_escape(rhs))
                )
            end
        end

        table.insert(lines, "")
    end

    return lines
end

local function default_file()
    local lines = {
        "# Neovim Keybindings",
        "",
    }

    vim.list_extend(lines, generate_auto_section())

    vim.list_extend(lines, {
        MANUAL_HEADING,
        "",
        "Use this area for keybindings, workflows, plugin notes, reminders, or commands you want to keep by hand.",
        "",
        "### My reminders",
        "",
        "- `<leader>` is Space.",
        "- Add notes here. This section will not be overwritten.",
        "",
    })

    return lines
end

local function replace_generated_block(existing_lines, generated_lines)
    local start_idx = nil
    local manual_idx = nil

    for i, line in ipairs(existing_lines) do
        if not start_idx and line == GENERATED_HEADING then
            start_idx = i
        elseif start_idx and line == MANUAL_HEADING then
            manual_idx = i
            break
        end
    end

    if not start_idx or not manual_idx or start_idx >= manual_idx then
        local new_lines = {}

        vim.list_extend(new_lines, {
            "# Neovim Keybindings",
            "",
        })

        vim.list_extend(new_lines, generated_lines)

        vim.list_extend(new_lines, {
            MANUAL_HEADING,
            "",
            "_Existing content was preserved below because no generated keymap section was found._",
            "",
        })

        vim.list_extend(new_lines, existing_lines)

        return new_lines
    end

    local result = {}

    for i = 1, start_idx - 1 do
        table.insert(result, existing_lines[i])
    end

    vim.list_extend(result, generated_lines)

    for i = manual_idx, #existing_lines do
        table.insert(result, existing_lines[i])
    end

    return result
end

function M.generate()
    local path = note_path()
    local generated = generate_auto_section()

    local final_lines

    if vim.fn.filereadable(path) == 1 then
        local existing = vim.fn.readfile(path)
        final_lines = replace_generated_block(existing, generated)
    else
        final_lines = default_file()
    end

    vim.fn.writefile(final_lines, path)
    vim.notify("Updated keybinding note: " .. path, vim.log.levels.INFO)
end

function M.open_popup()
    local path = note_path()

    if vim.fn.filereadable(path) == 0 then
        M.generate()
    end

    local lines = vim.fn.readfile(path)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].modifiable = true
    vim.bo[buf].bufhidden = "wipe"

    local width = math.floor(vim.o.columns * 0.85)
    local height = math.floor(vim.o.lines * 0.85)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " KEYBINDINGS.md ",
        title_pos = "center",
    })

    vim.wo[win].wrap = false
    vim.wo[win].cursorline = true

    vim.api.nvim_buf_set_name(buf, path)

    vim.keymap.set("n", "q", function()
        if vim.bo[buf].modified then
            vim.cmd("write")
        end

        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end, {
        buffer = buf,
        nowait = true,
        desc = "Save and close keybinding note",
    })

    vim.keymap.set("n", "<Esc>", function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end, {
        buffer = buf,
        nowait = true,
        desc = "Close keybinding note",
    })
end

function M.open_file()
    vim.cmd("edit " .. vim.fn.fnameescape(note_path()))
end

vim.api.nvim_create_user_command("KeymapNoteGenerate", M.generate, {
    desc = "Update generated section in KEYBINDINGS.md",
})

vim.api.nvim_create_user_command("KeymapNote", M.open_popup, {
    desc = "Open KEYBINDINGS.md in popup",
})

vim.api.nvim_create_user_command("KeymapNoteEdit", M.open_file, {
    desc = "Edit KEYBINDINGS.md as a normal file",
})

vim.keymap.set("n", "<leader>kg", M.generate, {
    desc = "Generate keybinding note",
})

vim.keymap.set("n", "<leader>ke", M.open_file, {
    desc = "Edit keybinding note",
})

return M

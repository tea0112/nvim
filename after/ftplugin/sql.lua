local ok, utils = pcall(require, "libs.utils")
if not ok then
    vim.notify("utils module doesn't exist!")
    return
end

local home_dir = os.getenv("HOME")
local db_container_info = home_dir .. "/.db_container_info.toml"

if not utils.file_exists(db_container_info) then
    vim.notify('file ".db_container_info.toml" doens\'t exist! at HOME dir')
    if
        os.execute(
            "cp "
                .. home_dir
                .. "/dotfiles/.config/nvim/.db_container_info.toml.example"
                .. " "
                .. home_dir
                .. "/.db_container_info.toml"
        ) ~= 0
    then
        vim.notify('create ".db_container_info.toml" failed')
        return
    end

    vim.notify('created ".db_container_info.toml" at HOME dir')
    vim.notify("please restart!", vim.log.levels.WARN)
end

local file = io.open(home_dir .. "/.db_container_info.toml", "r")
local toml_container_info_file = file:read("*a")

local TOML = require("libs.toml")
TOML.strict = false
local parsed_container_info = TOML.parse(toml_container_info_file)

local error_exists = false
if parsed_container_info["database"]["type"] == nil or parsed_container_info["database"]["type"] == "" then
    vim.notify("database type isn't specified", vim.log.levels.ERROR)
    error_exists = true
end
if
    parsed_container_info["database"]["container_name"] == nil
    or parsed_container_info["database"]["container_name"] == ""
then
    vim.notify("database container_name isn't specified", vim.log.levels.ERROR)
    error_exists = true
end
if parsed_container_info["database"]["username"] == nil or parsed_container_info["database"]["username"] == "" then
    vim.notify("database username isn't specified", vim.log.levels.ERROR)
    error_exists = true
end
if
    parsed_container_info["database"]["database_name"] == nil
    or parsed_container_info["database"]["database_name"] == ""
then
    vim.notify("database database_name isn't specified", vim.log.levels.ERROR)
    error_exists = true
end
if error_exists == true then
    return
end

vim.keymap.set("x", "<leader>ss", function()
    -- Those marks('<, '>) are not set until you leave visual mode.
    -- The thing that makes you leave visual mode in the vimscript mapping is : (because you enter command mode).
    vim.cmd.normal(":")

    local start_line = vim.api.nvim_buf_get_mark(0, "<")
    local end_line = vim.api.nvim_buf_get_mark(0, ">")

    local srow = start_line[1]
    ---@diagnostic disable-next-line: unused-local
    local scol = start_line[2]

    local erow = end_line[1]
    ---@diagnostic disable-next-line: unused-local
    local ecol = end_line[2]

    vim.cmd.normal("gv")

    local selected_lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, true)

    vim.cmd([[hor bo new]])
    vim.cmd([[setlocal nowrap]])

    local uv = vim.loop
    local stdin = uv.new_pipe()
    local stdout = uv.new_pipe()
    local stderr = uv.new_pipe()

    -- -- "<cmd>:'<,'>:w !cat query.sql | docker exec -i postgresql-container-friction_postgres-1 psql -U friction -d friction<cr>"
    local handle, pid = uv.spawn("docker", {
        args = {
            "exec",
            "-i",
            parsed_container_info["database"]["container_name"],
            "psql",
            "-U",
            parsed_container_info["database"]["username"],
            "-d",
            parsed_container_info["database"]["database_name"],
        },
        stdio = { stdin, stdout, stderr },
        function(code, signal)
            print("exit code", code)
            print("exit signal", signal)
        end,
    })

    print("process opened", handle, pid)

    uv.write(stdin, selected_lines, function(err)
        print("err: ", err)
    end)

    uv.read_start(stdout, function(err, data)
        assert(not err, err)
        if data then
            print(data)
            vim.schedule(function()
                local strs = vim.split(data, "\n")
                vim.api.nvim_buf_set_text(0, 0, 0, 0, 0, strs)
            end)
        else
            print("stdout end", stdout)
        end
    end)

    uv.read_start(stderr, function(err, data)
        assert(not err, err)
        if data then
            print("stderr chunk", stderr, data)
        else
            print("stderr end", stderr)
        end
    end)

    uv.shutdown(stdin, function(err)
        print("shutdown err: ", err)
        uv.close(handle, function()
            print("process closed", handle, pid)
        end)
    end)
end, { silent = true, noremap = true })

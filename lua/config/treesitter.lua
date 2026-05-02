local M = {}

M.enabled = {
    c = true,
    lua = true,
    vim = true,
    vimdoc = true,
    query = true,
    go = true,
    java = true,
    json = true,
    python = true,
    markdown = true,
}

function M.start(buf)
    local ft = vim.bo[buf].filetype
    local lang = vim.treesitter.language.get_lang(ft)

    if not lang or not M.enabled[lang] then
        return
    end

    local ok = pcall(vim.treesitter.start, buf, lang)
    if ok then
        vim.bo[buf].syntax = ""
    else
        vim.bo[buf].syntax = "ON"
    end
end

require("config.treesitter_installer").setup({
    enabled = M.enabled,
    on_install = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
                M.start(buf)
            end
        end
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
    callback = function(args)
        M.start(args.buf)
    end,
})

return M

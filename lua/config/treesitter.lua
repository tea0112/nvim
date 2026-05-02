local M = {}

M.enabled = {
    c = true,
    lua = true,
    vim = true,
    vimdoc = true,
    query = true,
    go = true,
    java = true,
}

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)

        if not lang or not M.enabled[lang] then
            return
        end

        local ok = pcall(vim.treesitter.start, args.buf, lang)
        if not ok then
            vim.bo[args.buf].syntax = "ON"
        end
    end,
})

return M

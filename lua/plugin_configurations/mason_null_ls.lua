local M = {}

function M.setup()
    require("mason-null-ls").setup({
        ensure_installed = { "stylua", "flake8" },
    })
end

return M

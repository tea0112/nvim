-- Lightweight yet powerful formatter plugin for Neovim
local M = {}

function M.setup()
    require("conform").setup({
        format_on_save = {
            -- These options will be passed to conform.format()
            timeout_ms = 500,
            lsp_fallback = true,
        },
        formatters_by_ft = {
            lua = { "stylua" },
            -- Conform will run multiple formatters sequentially
            -- python = { "isort", "black" },
            -- Use a sub-list to run only the first available formatter
            -- javascript = { { "prettierd", "prettier" } },
        },
    })
end

return M

return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            -- format_on_save = {
            --     -- These options will be passed to conform.format()
            --     timeout_ms = 500,
            --     lsp_fallback = true,
            -- },
            -- log_level = vim.log.levels.DEBUG,
            formatters_by_ft = {
                lua = { "stylua" },
                sh = { "shfmt" },
                go = { "gofmt", "goimports" },
                json = { "jq" },
                yaml = { "yamlfmt" },
                -- Conform will run multiple formatters sequentially
                -- python = { "isort", "black" },
                -- Use a sub-list to run only the first available formatter
                -- javascript = { { "prettierd", "prettier" } },
            },
            formatters = {
                -- my_json_formatter = {
                --     command = "jq",
                -- },
            },
        })
    end,
}

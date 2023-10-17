return {
    "folke/which-key.nvim",
    config = function()
        local wk = require("which-key")
        wk.register({
            a = {
                name = "Copy",
                a = { "ggVG", "All" },
            },
            d = {
                name = "Diffview plugin",
                o = { "<cmd>DiffviewOpen<cr>", "Open Git Diff View" },
                c = { "<cmd>DiffviewClose<cr>", "Open Git Diff View" },
            },
            o = {
                name = "Insert new line",
                o = { 'o<esc>0"_D', "Down" },
                O = { 'O<esc>0"_D', "Up" },
            },
            n = {
                name = "Navbuddy",
                v = { "<cmd>Navbuddy<cr>", "Open" },
            },
            r = {
                name = "Lsp",
                r = { '<cmd>lua require("trouble").toggle("lsp_references")<cr>', "References" },
            },
            q = {
                name = "Quit",
                q = { "<cmd>qa!<cr>", "All without save" },
            },
            x = {
                name = "Trouble",
                x = { "<cmd>lua require('trouble').toggle()<cr>", "Toggle trouble" },
                w = { '<cmd>lua require("trouble").toggle("workspace_diagnostics")<cr>', "Workspace diagnostics" },
                d = { '<cmd>lua require("trouble").toggle("document_diagnostics")<cr>', "Document diagnostics" },
                q = { '<cmd>lua require("trouble").toggle("quickfix")<cr>', "Quickfix" },
                l = { '<cmd>lua require("trouble").toggle("loclist")<cr>', "Loc List" },
            },
            w = {
                name = "Window",
                w = { "<c-w>c", "Close window" },
                q = { "<cmd>bd!<cr>", "Force closing buffer" },
            },
        }, {
            mode = "n", -- NORMAL mode
            -- prefix: use "<leader>f" for example for mapping everything related to finding files
            -- the prefix is prepended to every mapping part of `mappings`
            prefix = "<leader>",
            buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
            silent = true, -- use `silent` when creating keymaps
            noremap = true, -- use `noremap` when creating keymaps
            nowait = false, -- use `nowait` when creating keymaps
            expr = false, -- use `expr` when creating keymaps
        })
    end,
}

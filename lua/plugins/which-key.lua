return {
    "folke/which-key.nvim",
    config = function()
        local wk = require("which-key")
        wk.setup({
            notify = false,
        })
        wk.register({
            a = {
                name = "Copy",
            },
            d = {
                name = "Diffview plugin",
            },
            o = {
                name = "Insert new line",
            },
            l = {
                name = "conform",
            },
            n = {
                name = "Navbuddy",
            },
            r = {
                name = "Lsp",
            },
            x = {
                name = "Trouble",
            },
            w = {
                name = "Window",
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

        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
        end

        map("<leader>aa", "ggVG", "Select all")
        map("<leader>ae", 'ggVG"+y', "Copy all to system clipboard")
        map("<leader>ar", 'ggVG"+p', "Paste system clipboard over whole buffer")

        map("<leader>do", "<cmd>DiffviewOpen<cr>", "Open Git diff view")
        map("<leader>dc", "<cmd>DiffviewClose<cr>", "Close Git diff view")

        map("<leader>oo", 'o<esc>0"_D', "Insert empty line below")
        map("<leader>oO", 'O<esc>0"_D', "Insert empty line above")

        map(
            "<leader>lf",
            '<cmd>lua require("conform").format({ bufnr = 0, async = true, lsp_format = "fallback" })<cr>',
            "Format buffer with conform"
        )
        map("<leader>nv", "<cmd>Navbuddy<cr>", "Open Navbuddy")

        map("<leader>rr", '<cmd>lua require("trouble").toggle("lsp_references")<cr>', "Show LSP references")
        map("<leader>ri", "<cmd>GoImplements<cr>", "Show Go implementations")

        map("<leader>xx", "<cmd>lua require('trouble').toggle()<cr>", "Toggle Trouble")
        map(
            "<leader>xw",
            '<cmd>lua require("trouble").toggle("workspace_diagnostics")<cr>',
            "Show workspace diagnostics"
        )
        map("<leader>xd", '<cmd>lua require("trouble").toggle("document_diagnostics")<cr>', "Show document diagnostics")
        map("<leader>xq", '<cmd>lua require("trouble").toggle("quickfix")<cr>', "Show quickfix list")
        map("<leader>xl", '<cmd>lua require("trouble").toggle("loclist")<cr>', "Show location list")

        map("<leader>wa", "<cmd>bd!<cr>", "Force close buffer")
        map("<leader>ws", "<cmd>:wq!<cr>", "Force save and quit")
        map("<leader>ww", "<c-w>c", "Close window")
        map("<leader>wq", "<cmd>:qa!<cr>", "Force quit all without saving")
    end,
}

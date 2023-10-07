return {
    "folke/which-key.nvim",
    config = function()
        local wk = require("which-key")
        wk.register({
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

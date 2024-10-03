return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local actions = require("telescope.actions")
        require("telescope").setup({
            defaults = {
                mappings = {
                    i = {
                        ["<esc>"] = actions.close,
                        ["<c-d>"] = require("telescope.actions").delete_buffer,
                    },
                },
                -- file_ignore_patterns = {
                --     { ".git/", "generated.go" },
                -- },
            },
        })
    end,
}

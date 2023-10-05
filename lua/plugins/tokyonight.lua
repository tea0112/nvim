return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        require("tokyonight").setup({
            -- transparent = true,
            style = "moon",
            light_style = "moon",
            terminal_colors = true, -- Configure the colors used when opening a `:terminal` in [Neovim](https://github.com/neovim/neovim)
            styles = {
                -- Style to be applied to different syntax groups
                -- Value is any valid attr-list value for `:help nvim_set_hl`
                comments = { italic = false },
                keywords = { italic = false },
            },
        })
    end,
}

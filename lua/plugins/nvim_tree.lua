return {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        require("nvim-tree").setup({
            sort_by = "case_sensitive",
            view = {
                relativenumber = true,
                width = 30,
                side = "right",
            },
            renderer = {
                group_empty = true,
                full_name = true,
            },
            filters = {
                dotfiles = true,
            },
            actions = {
                open_file = {
                    quit_on_open = true,
                },
            },
        })
    end,
}

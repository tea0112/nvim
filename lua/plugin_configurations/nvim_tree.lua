local M = {}

function M.setup()
    require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
            relativenumber = true,
            width = 30,
        },
        renderer = {
            group_empty = true,
            full_name = true,
        },
        filters = {
            dotfiles = true,
        },
    })
end

return M

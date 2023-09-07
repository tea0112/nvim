local M = {}

local actions = require("telescope.actions")

function M.setup()
    require("telescope").setup({
        defaults = {
            mappings = {
                i = {
                    ["<esc>"] = actions.close,
                },
            },
        }
    })
end

return M

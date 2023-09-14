local M = {}

function M.setup()
    require("tokyonight").setup({
        styles = {
            comments = { italic = false },
            keywords = { italic = false },
        },
    })
end

return M

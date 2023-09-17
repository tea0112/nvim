local M = {}

function M.setup()
    require("luasnip.loaders.from_vscode").load({ paths = { "./snippets" } })
end

return M

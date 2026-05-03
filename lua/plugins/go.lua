return {
    "ray-x/go.nvim",
    dependencies = {
        "ray-x/guihua.lua",
        "neovim/nvim-lspconfig",
    },
    event = { "CmdlineEnter" },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    config = function()
        require("go").setup({
            lsp_cfg = false,
            lsp_keymaps = false,
            textobjects = false,
        })
    end,
}

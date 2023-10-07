----------------------------------
--           config             --
----------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

------------------
-- lazy plugins --
------------------
require("lazy").setup({
    { import = "plugins" },
    -- A simple popup display that provides breadcrumbs feature using LSP server
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "SmiteshP/nvim-navbuddy",
                dependencies = {
                    "SmiteshP/nvim-navic",
                    "MunifTanjim/nui.nvim",
                },
                opts = { lsp = { auto_attach = true } },
            },
        },
    },
    "onsails/lspkind.nvim",
    "sindrets/diffview.nvim",
    {
        "utilyre/barbecue.nvim",
        name = "barbecue",
        version = "*",
        dependencies = {
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons", -- optional dependency
        },
    },
    "mfussenegger/nvim-jdtls",
    {
        "altermo/ultimate-autopair.nvim",
        event = { "InsertEnter", "CmdlineEnter" },
        branch = "v0.6",
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function() end,
    },
    {
        "numToStr/Comment.nvim",
        lazy = false,
    },
    "neovim/nvim-lspconfig",
    "folke/which-key.nvim",
    { "folke/neoconf.nvim", cmd = "Neoconf" },
    "folke/neodev.nvim",
    "neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
    -- cmp
    "mfussenegger/nvim-dap",
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
    "theHamsta/nvim-dap-virtual-text",
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
}, {
    lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})

-------------------
-- for nvim tree --
-------------------
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

------------------
-- plugin setup --
------------------
require("lsp").setup()
require("Comment").setup()
require("nvim-surround").setup()
require("ultimate-autopair").setup()
require("barbecue").setup()

-----------------
-- colorscheme --
-----------------
vim.cmd([[colorscheme tokyonight]])

-----------------
-- key mapping --
-----------------
OPTS_SILENT_NOREMAP = { silent = true, noremap = true }
vim.keymap.set("n", ",s", ":wa<CR>", OPTS_SILENT_NOREMAP)
vim.keymap.set("n", "<leader>o", 'o<esc>0"_D', OPTS_SILENT_NOREMAP)
vim.keymap.set("n", "<leader>O", 'O<esc>0"_D', OPTS_SILENT_NOREMAP)
-- vim.keymap.set(
--     "n",
--     "<C-d>",
--     "<C-d>zz",
--     { silent = true, noremap = true, desc = "Center cursor after moving down half-page" }
-- )
-- vim.keymap.set(
--     "n",
--     "<C-u>",
--     "<C-u>zz",
--     { silent = true, noremap = true, desc = "Center cursor after moving down half-page" }
-- )

------------------
-- trigger lint --
------------------
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    callback = function()
        require("lint").try_lint()
    end,
})

------------------
--    format    --
------------------

-----------------------------------
--        config after           --
-----------------------------------
vim.cmd([[ highlight LineNr guibg=#0a0047 ]])

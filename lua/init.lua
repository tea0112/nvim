----------------------------------
-- lazy package manager section --
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
    {
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "jose-elias-alvarez/null-ls.nvim",
        },
    },
    'mfussenegger/nvim-lint',
    "sindrets/diffview.nvim",
    "lewis6991/gitsigns.nvim",
    {
        "utilyre/barbecue.nvim",
        name = "barbecue",
        version = "*",
        dependencies = {
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons", -- optional dependency
        },
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', lazy = true }
    },
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        opts = {},
    },
    'mfussenegger/nvim-jdtls',
    {
        'altermo/ultimate-autopair.nvim',
        event = { 'InsertEnter', 'CmdlineEnter' },
        branch = 'v0.6',
    },
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
        end
    },
    {
        'numToStr/Comment.nvim',
        lazy = false,
    },
    "williamboman/mason-lspconfig.nvim",
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        }
    },
    "rebelot/kanagawa.nvim",
    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate" -- :MasonUpdate updates registry contents
    },
    "neovim/nvim-lspconfig",
    "folke/which-key.nvim",
    { "folke/neoconf.nvim",   cmd = "Neoconf" },
    "folke/neodev.nvim",
    'neovim/nvim-lspconfig',    -- Collection of configurations for built-in LSP client
    -- cmp
    'hrsh7th/nvim-cmp',         -- Autocompletion plugin
    'hrsh7th/cmp-nvim-lsp',     -- LSP source for nvim-cmp
    'hrsh7th/cmp-cmdline',
    'saadparwaiz1/cmp_luasnip', -- Snippets source for nvim-cmp
    'L3MON4D3/LuaSnip',         -- Snippets plugin
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    --
    {
        "ray-x/go.nvim",
        dependencies = { -- optional packages
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
        event = { "CmdlineEnter" },
        ft = { "go", 'gomod' },
        build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    },
    'mfussenegger/nvim-dap',
    { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
    'theHamsta/nvim-dap-virtual-text',
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    'easymotion/vim-easymotion'
}, {
    lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json"
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
require("lsp")
require("Comment").setup()
require("nvim-surround").setup()
require("ultimate-autopair").setup()
require("barbecue").setup()

require("plugin_configurations.nvim_lint").setup()
require("plugin_configurations.mason_null_ls").setup()
require("plugin_configurations.mason").setup()
require("plugin_configurations.gitsigns").setup()
require("plugin_configurations.lua_line").setup()
require("plugin_configurations.go").setup()
require("plugin_configurations.kanagawa").setup()
require("plugin_configurations.mason_lsp_config").setup()
require("plugin_configurations.nvim_tree").setup()
require("plugin_configurations.telescope").setup()
require("plugin_configurations.tokyonight").setup()

-----------------
-- colorscheme --
-----------------
vim.cmd [[colorscheme tokyonight-moon]]

-----------------
-- key mapping --
-----------------
opts_silent_noremap = { silent = true, noremap = true }
vim.keymap.set('n', ',s', ':wa<CR>', opts_silent_noremap)

------------------
-- trigger lint --
------------------
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    callback = function()
        require("lint").try_lint()
    end,
})

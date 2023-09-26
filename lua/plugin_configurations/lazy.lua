local M = {}

function M.setup()
    require("lazy").setup({
        { "lukas-reineke/indent-blankline.nvim" },
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
        "smoka7/hop.nvim",
        "onsails/lspkind.nvim",
        {
            "stevearc/conform.nvim",
        },
        "nvim-treesitter/nvim-treesitter",
        {
            "jay-babu/mason-null-ls.nvim",
            event = { "BufReadPre", "BufNewFile" },
            dependencies = {
                "williamboman/mason.nvim",
                "jose-elias-alvarez/null-ls.nvim",
            },
        },
        "mfussenegger/nvim-lint",
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
            "nvim-lualine/lualine.nvim",
            dependencies = { "nvim-tree/nvim-web-devicons", lazy = true },
        },
        {
            "folke/tokyonight.nvim",
            lazy = false,
            priority = 1000,
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
        "williamboman/mason-lspconfig.nvim",
        {
            "nvim-tree/nvim-tree.lua",
            version = "*",
            dependencies = {
                "nvim-tree/nvim-web-devicons",
            },
        },
        "rebelot/kanagawa.nvim",
        {
            "williamboman/mason.nvim",
            build = ":MasonUpdate", -- :MasonUpdate updates registry contents
        },
        "neovim/nvim-lspconfig",
        "folke/which-key.nvim",
        { "folke/neoconf.nvim", cmd = "Neoconf" },
        "folke/neodev.nvim",
        "neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
        -- cmp
        "hrsh7th/nvim-cmp", -- Autocompletion plugin
        "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
        "hrsh7th/cmp-cmdline",
        "saadparwaiz1/cmp_luasnip", -- Snippets source for nvim-cmp
        {
            "L3MON4D3/LuaSnip",
            -- install jsregexp (optional!).
            build = "make install_jsregexp",
        },
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "fatih/vim-go",
        --
        -- {
        --     "ray-x/go.nvim",
        --     dependencies = { -- optional packages
        --         "ray-x/guihua.lua",
        --         "neovim/nvim-lspconfig",
        --         "nvim-treesitter/nvim-treesitter",
        --     },
        --     config = function()
        --         require("go").setup()
        --     end,
        --     event = { "CmdlineEnter" },
        --     ft = { "go", "gomod" },
        --     build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
        -- },
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
end

return M

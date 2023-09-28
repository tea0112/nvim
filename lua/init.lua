----------------------------------
--           config             --
----------------------------------

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
require("plugin_configurations.lazy").setup()

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

-- require("plugin_configurations.indent_blankline").setup()
require("plugin_configurations.hop").setup()
require("plugin_configurations.luasnip").setup()
require("plugin_configurations.conform").setup()
require("plugin_configurations.nvim_treesitter_config").setup()
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
vim.cmd([[colorscheme tokyonight]])

-----------------
-- key mapping --
-----------------
OPTS_SILENT_NOREMAP = { silent = true, noremap = true }
vim.keymap.set("n", ",s", ":wa<CR>", OPTS_SILENT_NOREMAP)

------------------
-- trigger lint --
------------------
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    callback = function()
        require("lint").try_lint()
    end,
})

------------------
----- format -----
------------------

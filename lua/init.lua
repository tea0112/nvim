----------------------------------
--           config             --
----------------------------------
vim.opt.termguicolors = true
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
    lockfile = "~/dotfiles/.config/nvim/lazy-lock.json", -- lockfile generated after running update.
})

-------------------
-- for nvim tree --
-------------------
-- disable netrw at the very start of your init.lua
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1

------------------
-- plugin setup --
------------------
require("config.treesitter")
require("lsp").setup()
require("Comment").setup()
require("nvim-surround").setup()
require("ultimate-autopair").setup()
require("barbecue").setup()
require("config.keymap_note")

-----------------
-- colorscheme --
-----------------
vim.cmd([[colorscheme tokyonight]])

-----------------
-- key mapping --
-----------------
local function keymap_opts(desc, opts)
    return vim.tbl_extend("force", { desc = desc }, opts or {})
end

local function silent_keymap_opts(desc, opts)
    return keymap_opts(desc, vim.tbl_extend("force", { silent = true }, opts or {}))
end

local tmux_direction_flags = {
    h = "-L",
    j = "-D",
    k = "-U",
    l = "-R",
}

local function tmux_aware_navigate(direction)
    local start_win = vim.api.nvim_get_current_win()
    local ok = pcall(vim.cmd, "wincmd " .. direction)

    if ok and vim.api.nvim_get_current_win() ~= start_win then
        return
    end

    if not vim.env.TMUX or not vim.env.TMUX_PANE or vim.fn.executable("tmux") ~= 1 then
        return
    end

    local target_flag = tmux_direction_flags[direction]

    if target_flag then
        vim.fn.system({ "tmux", "select-pane", "-t", vim.env.TMUX_PANE, target_flag })
    end
end

vim.keymap.set("n", "<leader>sv", ":source $MYVIMRC<CR>", keymap_opts("Source Neovim config", { remap = true }))
vim.keymap.set({ "n", "v", "o" }, "<Backspace>", "<C-6>", keymap_opts("Switch to alternate buffer", { remap = true }))

vim.keymap.set("n", ",h", ":vert bo help ", keymap_opts("Open vertical help prompt"))
vim.keymap.set("n", "<A-h>", function()
    tmux_aware_navigate("h")
end, keymap_opts("Move to left window or tmux pane"))
vim.keymap.set("n", "<A-j>", function()
    tmux_aware_navigate("j")
end, keymap_opts("Move to lower window or tmux pane"))
vim.keymap.set("n", "<A-k>", function()
    tmux_aware_navigate("k")
end, keymap_opts("Move to upper window or tmux pane"))
vim.keymap.set("n", "<A-l>", function()
    tmux_aware_navigate("l")
end, keymap_opts("Move to right window or tmux pane"))

vim.keymap.set("n", "-", "<CMD>Oil<CR>", keymap_opts("Open parent directory"))
vim.keymap.set("n", "x", '"xx', keymap_opts("Delete character to x register"))
vim.keymap.set("n", "<leader>yy", '"+yy', keymap_opts("Yank line to system clipboard"))
vim.keymap.set("n", "<leader>pp", '"+p', keymap_opts("Paste from system clipboard"))
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", keymap_opts("Find files"))
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", keymap_opts("Search text in files"))
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", keymap_opts("Find open buffers"))
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", keymap_opts("Search help tags"))
vim.keymap.set("n", "<C-e>", "3<C-e>", keymap_opts("Scroll window down three lines"))
vim.keymap.set("n", "<C-y>", "3<C-y>", keymap_opts("Scroll window up three lines"))

vim.keymap.set("i", "jk", "<Esc>", keymap_opts("Exit insert mode", { remap = true }))
vim.keymap.set("i", "<C-n>", ":Explore<CR>", keymap_opts("Open netrw explorer", { remap = true }))
vim.keymap.set("v", "x", '"xx', keymap_opts("Delete selection to x register"))
vim.keymap.set("v", "<leader>jj", '"+y', keymap_opts("Yank selection to system clipboard"))
vim.keymap.set("v", "<leader>kk", '"+p', keymap_opts("Paste from system clipboard"))

vim.keymap.set("i", "<Down>", "<C-o>gj", keymap_opts("Move down by display line"))
vim.keymap.set("i", "<Up>", "<C-o>gk", keymap_opts("Move up by display line"))

vim.keymap.set({ "n", "v", "o" }, "<leader>1", "1gt", keymap_opts("Go to tab 1"))
vim.keymap.set({ "n", "v", "o" }, "<leader>2", "2gt", keymap_opts("Go to tab 2"))
vim.keymap.set({ "n", "v", "o" }, "<leader>3", "3gt", keymap_opts("Go to tab 3"))
vim.keymap.set({ "n", "v", "o" }, "<leader>4", "4gt", keymap_opts("Go to tab 4"))
vim.keymap.set({ "n", "v", "o" }, "<leader>5", "5gt", keymap_opts("Go to tab 5"))
vim.keymap.set({ "n", "v", "o" }, "<leader>6", "6gt", keymap_opts("Go to tab 6"))
vim.keymap.set({ "n", "v", "o" }, "<leader>7", "7gt", keymap_opts("Go to tab 7"))
vim.keymap.set({ "n", "v", "o" }, "<leader>8", "8gt", keymap_opts("Go to tab 8"))
vim.keymap.set({ "n", "v", "o" }, "<leader>9", "9gt", keymap_opts("Go to tab 9"))
vim.keymap.set({ "n", "v", "o" }, "<leader>0", ":tablast<cr>", keymap_opts("Go to last tab"))

-- 1. Normal Mode: Space + t + h
vim.keymap.set("n", "<leader>th", function()
    vim.opt.hlsearch = not vim.opt.hlsearch:get()
end, silent_keymap_opts("Toggle search highlight"))
-- 2. Insert Mode: Alt + t
vim.keymap.set("i", "<M-t>", function()
    vim.opt.hlsearch = not vim.opt.hlsearch:get()
end, silent_keymap_opts("Toggle search highlight"))

vim.keymap.set("n", ",s", ":wa<CR>", silent_keymap_opts("Save all buffers"))
vim.keymap.set({ "n", "v" }, "<a-p>", '"0p', silent_keymap_opts("Paste from yank register"))
vim.keymap.set({ "n", "v" }, "<a-s-p>", '"xp', silent_keymap_opts("Paste from x register"))
-- map gj gk
vim.keymap.set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", keymap_opts("Move up by display line", { expr = true }))
vim.keymap.set(
    { "n", "v" },
    "j",
    "v:count == 0 ? 'gj' : 'j'",
    keymap_opts("Move down by display line", { expr = true })
)
-- tab
vim.keymap.set("n", "<leader>ta", ":$tabnew<CR>", keymap_opts("Open new tab"))
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", keymap_opts("Close current tab"))
vim.keymap.set("n", "<leader>to", ":tabonly<CR>", keymap_opts("Close other tabs"))
vim.keymap.set("n", "<leader>tn", ":tabn<CR>", keymap_opts("Go to next tab"))
vim.keymap.set("n", "<leader>tp", ":tabp<CR>", keymap_opts("Go to previous tab"))
-- move current tab to previous position
vim.keymap.set("n", "<leader>tmp", ":-tabmove<CR>", keymap_opts("Move tab left"))
-- move current tab to next position
vim.keymap.set("n", "<leader>tmn", ":+tabmove<CR>", keymap_opts("Move tab right"))

------------------
-- trigger lint --
------------------
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
    callback = function()
        require("lint").try_lint()
    end,
})

-- Format on save
-- local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     pattern = "*.go",
--     callback = function()
--         require("go.format").goimports()
--     end,
--     group = format_sync_grp,
-- })

-----------------------------------
--        config after           --
-----------------------------------
vim.cmd([[ highlight LineNr guibg=#0a0047 ]])

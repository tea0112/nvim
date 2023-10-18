vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

vim.notify("loading java lsp...")

local nvim_data_dir = vim.fn.stdpath("data")
local mason_package_dir = nvim_data_dir .. "/mason/packages"
local jdtls_dir = mason_package_dir .. "/jdtls"

local config = {
    cmd = {
        vim.fn.stdpath("config") .. "/bin/java-lsp.sh",
    },
    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
    settings = {
        java = {},
    },
    init_options = {
        bundles = {},
    },
}

require("jdtls").start_or_attach(config)

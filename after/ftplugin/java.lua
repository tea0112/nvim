vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2

vim.notify("loading java lsp...")

local nvim_data_dir = vim.fn.stdpath("data")
local mason_package_dir = nvim_data_dir .. "/mason/packages"
local jdtls_dir = mason_package_dir .. "/jdtls"
local jdtls_plugin_dir = jdtls_dir .. "/plugins"
local org_eclipse_equinox_launcher_path_pattern = jdtls_plugin_dir .. "/org.eclipse.equinox.launcher_*.jar"

local org_eclipse_equinox_launcher_path = vim.fn.glob(org_eclipse_equinox_launcher_path_pattern, false)

local config = {
    cmd = {
        -- vim.fn.stdpath("config") .. "/bin/java-lsp.sh",
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx1g",
        "-javaagent:" .. jdtls_dir .. "/lombok.jar",
        "-Xbootclasspath/a:" .. jdtls_dir .. "/lombok.jar",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-jar",
        org_eclipse_equinox_launcher_path,
        "-configuration",
        jdtls_dir .. "/config_linux",
        "-data",
        os.getenv("HOME") .. "/workspace/java",
    },
    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
    settings = {
        java = {
            configuration = {
                runtimes = {
                    -- {
                    --     name = "JavaSE-8",
                    --     path = "/usr/lib/jvm/java-8-openjdk/",
                    -- },
                    -- {
                    --     name = "JavaSE-17",
                    --     path = "/usr/lib/jvm/java-17-openjdk/",
                    -- },
                },
            },
        },
    },
    init_options = {
        bundles = {},
    },
}

require("jdtls").start_or_attach(config)

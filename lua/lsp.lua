local M = {}

function M.setup()
    local border = {
        { "🭽", "FloatBorder" },
        { "▔", "FloatBorder" },
        { "🭾", "FloatBorder" },
        { "▕", "FloatBorder" },
        { "🭿", "FloatBorder" },
        { "▁", "FloatBorder" },
        { "🭼", "FloatBorder" },
        { "▏", "FloatBorder" },
    }

    vim.diagnostic.config({
        virtual_text = {
            prefix = "■ ", -- Could be '●', '▎', 'x', '■', , 
        },
        float = {
            border = border,
        },
    })
    -- map lsp function
    vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
    vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

    -- Use LspAttach autocommand to only map the following keys
    -- after the language server attaches to the current buffer
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
            -- Enable completion triggered by <c-x><c-o>
            vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

            -- Buffer local mappings.
            -- See `:help vim.lsp.*` for documentation on any of the below functions
            local opts = { buffer = ev.buf }
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", function()
                vim.lsp.buf.hover({ border = border })
            end, opts)
            -- vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
            vim.keymap.set("i", "<C-k>", function()
                vim.lsp.buf.signature_help({ border = border })
            end, opts)
            vim.keymap.set("n", "<space>wf", vim.lsp.buf.add_workspace_folder, opts)
            vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
            vim.keymap.set("n", "<space>wl", function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, opts)
            vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
            vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
            vim.keymap.set("n", ",f", function()
                vim.lsp.buf.format({ async = true })
            end, opts)
            vim.keymap.set("v", "<leader>lf", function()
                require("conform").format({ async = true, lsp_fallback = true })
            end, opts)
        end,
    })

    ---------------------------
    -- language server setup --
    ---------------------------

    -- Add additional capabilities supported by nvim-cmp
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    local function enable(server, config)
        vim.lsp.config(server, config or {})
        vim.lsp.enable(server)
    end

    enable("pyright", { capabilities = capabilities })

    -- setup language server by lspconfig plugin
    enable("marksman", { capabilities = capabilities })

    enable("gopls", { capabilities = capabilities })

    enable("lua_ls", {
        capabilities = capabilities,
        settings = {
            Lua = {
                runtime = {
                    -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                    version = "LuaJIT",
                },
                diagnostics = {
                    -- Get the language server to recognize the `vim` global
                    globals = { "vim" },
                },
                workspace = {
                    -- Make the server aware of Neovim runtime files
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                -- Do not send telemetry data containing a randomized but unique identifier
                telemetry = {
                    enable = false,
                },
            },
        },
    })

    enable("bashls", {
        capabilities = capabilities,
    })

    enable("clangd", {
        capabilities = capabilities,
    })

    enable("html", {
        capabilities = capabilities,
    })

    enable("graphql", {
        root_dir = function(bufnr, on_dir)
            on_dir(vim.fs.root(bufnr, { ".graphqlconfig", ".graphqlrc", "package.json" }))
        end,
        flags = {
            debounce_text_changes = 150,
        },
        capabilities = capabilities,
    })
end

return M

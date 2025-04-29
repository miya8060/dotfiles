local keymap = vim.keymap.set

require("lazydev").setup()

-- require("ddc_source_lsp_setup").setup()
-- local capabilities = require("ddc_source_lsp").make_client_capabilities()

local lspconfig = require("lspconfig")

local servers = {
        "lua_ls",
        "taplo",
        "yamlls",
        "dockerls",
        -- "pylsp",
        "clangd",
        "cssls",
        "ts_ls",
}

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover,
        {
                border = "rounded",
        }
)

-- Auto start language servers.
for _, name in ipairs(servers) do
        lspconfig[name].setup({})
end

-- LSP settings
local function on_attach(client, bufnr)
        local opts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
end

-- Denoの設定（特定のプロジェクトディレクトリのみで有効）
lspconfig.denols.setup({
        root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "deps.ts"),
        init_options = {
                lint = true,
                unstable = true,
                suggest = {
                        imports = {
                                hosts = {
                                        ["https://deno.land"] = true,
                                        ["https://x.nest.land"] = true,
                                        ["https://crux.land"] = true,
                                },
                        },
                },
        },
        on_attach = function(client, bufnr)
                -- Denoが有効な場合、TypeScriptサーバーを無効化
                if client.name == "denols" then
                        -- 現在のバッファについているtsserverを無効化
                        for _, other_client in pairs(vim.lsp.get_active_clients()) do
                                if other_client.name == "ts_ls" and other_client.id ~= client.id then
                                        other_client.stop()
                                end
                        end
                end
                -- on_attachの共通処理を呼び出す
                on_attach(client, bufnr)
        end,
        filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
})

-- TypeScriptの設定（Denoプロジェクト以外で有効）
lspconfig.ts_ls.setup({
        root_dir = function(fname)
                -- Denoプロジェクトではないディレクトリでのみtsサーバーを起動
                local is_deno = lspconfig.util.root_pattern("deno.json", "deno.jsonc", "deps.ts")(fname)
                if is_deno then
                        return nil
                end
                return lspconfig.util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")(fname)
                    or vim.fn.getcwd()
        end,
        on_attach = on_attach,
        filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
})

-- html
lspconfig.html.setup {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html" },
        init_options = {
                configurationSection = { "html", "css", "javascript" },
                embeddedLanguages = {
                        css = true,
                        javascript = true
                },
        }
}

-- css
lspconfig.cssls.setup {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        root_dir = lspconfig.util.root_pattern("package.json", ".git") or vim.fn.getcwd(),
        settings = {
                css = {
                        validate = true,
                        lint = {
                                compatibleVendorPrefixes = "warning",
                                vendorPrefix = "warning",
                                duplicateProperties = "warning",
                                emptyRules = "warning",
                        }
                },
                scss = {
                        validate = true,
                        lint = {
                                compatibleVendorPrefixes = "warning",
                                vendorPrefix = "warning",
                                duplicateProperties = "warning",
                                emptyRules = "warning",
                        }
                },
                less = {
                        validate = true,
                        lint = {
                                compatibleVendorPrefixes = "warning",
                                vendorPrefix = "warning",
                                duplicateProperties = "warning",
                                emptyRules = "warning",
                        }
                }
        }
}


local function project_name_to_container_name()
        return "twitter_clone-web-1"
end

lspconfig.pylsp.setup {
        cmd = {
                'docker',
                'exec',
                '-i',
                project_name_to_container_name(),
                'pylsp'
        }
}


-- lsp keymaps
keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
keymap("n", "gf", "<cmd>lua vim.lsp.buf.format()<CR>")
keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
keymap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
keymap("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
keymap("n", "gn", "<cmd>lua vim.lsp.buf.rename()<CR>")

-- vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')

keymap("n", "ge", "<cmd>lua vim.diagnostic.open_float()<CR>")
keymap("n", "g]", "<cmd>lua vim.diagnostic.goto_next()<CR>")
keymap("n", "g[", "<cmd>lua vim.diagnostic.goto_prev()<CR>")

keymap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")

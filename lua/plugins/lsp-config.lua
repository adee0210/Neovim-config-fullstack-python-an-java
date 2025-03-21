-- /home/duc/.config/nvim/lua/plugins.lua
return {
    -- Plugin Mason để quản lý các công cụ phát triển
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    -- Plugin Mason LSP config để quản lý các máy chủ ngôn ngữ
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",           -- Lua
                    "ts_ls",            -- TypeScript/JavaScript
                    "jdtls",            -- Java
                    "html",             -- HTML
                    "cssls",            -- CSS
                    "groovyls",         -- Groovy (cho Gradle *.gradle)
                    "kotlin_language_server" -- Kotlin (cho Gradle *.gradle.kts)
                },
            })
        end,
    },

    -- Plugin Mason DAP config để quản lý các trình gỡ lỗi
    {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
            require("mason-nvim-dap").setup({
                ensure_installed = { "java-debug-adapter", "java-test" },
            })
        end,
    },

    -- Plugin nvim-jdtls để cấu hình máy chủ ngôn ngữ Java
    {
        "mfussenegger/nvim-jdtls",
        dependencies = {
            "mfussenegger/nvim-dap", -- Thêm dependency cho DAP
        },
    },

    -- Plugin nvim-lspconfig để cấu hình các máy chủ ngôn ngữ
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Cấu hình máy chủ ngôn ngữ Lua
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
            })

            -- Cấu hình máy chủ ngôn ngữ TypeScript/JavaScript
            lspconfig.ts_ls.setup({
                capabilities = capabilities,
            })

            -- Cấu hình máy chủ ngôn ngữ HTML
            lspconfig.html.setup({
                capabilities = capabilities,
            })

            -- Cấu hình máy chủ ngôn ngữ CSS
            lspconfig.cssls.setup({
                capabilities = capabilities,
            })

            -- Cấu hình máy chủ ngôn ngữ Groovy (cho Gradle *.gradle)
            lspconfig.groovyls.setup({
                capabilities = capabilities,
                filetypes = { "groovy" }, -- Chỉ áp dụng cho file Groovy
            })

            -- Cấu hình máy chủ ngôn ngữ Kotlin (cho Gradle *.gradle.kts)
            lspconfig.kotlin_language_server.setup({
                capabilities = capabilities,
                filetypes = { "kotlin" }, -- Chỉ áp dụng cho file Kotlin
            })

            -- Cấu hình các phím tắt cho LSP
            vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, { desc = "[C]ode [H]over Documentation" })
            vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "[C]ode Goto [D]efinition" })
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
            vim.keymap.set("n", "<leader>cr", require("telescope.builtin").lsp_references, { desc = "[C]ode Goto [R]eferences" })
            vim.keymap.set("n", "<leader>ci", require("telescope.builtin").lsp_implementations, { desc = "[C]ode Goto [I]mplementations" })
            vim.keymap.set("n", "<leader>cR", vim.lsp.buf.rename, { desc = "[C]ode [R]ename" })
            vim.keymap.set("n", "<leader>cD", vim.lsp.buf.declaration, { desc = "[C]ode Goto [D]eclaration" })
        end,
    },
}

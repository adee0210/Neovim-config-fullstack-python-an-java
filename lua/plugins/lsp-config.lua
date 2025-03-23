return {
    -- Plugin Mason để quản lý các công cụ phát triển
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ensure_installed = { "black" },
            })
        end,
    },

    -- Plugin Mason LSP config để quản lý các máy chủ ngôn ngữ
    {
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "ts_ls",
                    "jdtls",
                    "html",
                    "cssls",
                    "groovyls",
                    "kotlin_language_server",
                    "pyright",
                },
                automatic_installation = true,
            })
        end,
    },

    -- Plugin Mason DAP config để quản lý các trình gỡ lỗi
    {
        "jay-babu/mason-nvim-dap.nvim",
        config = function()
            require("mason-nvim-dap").setup({
                ensure_installed = { "java-debug-adapter", "java-test", "python" },
            })
        end,
    },

    -- Plugin nvim-jdtls để cấu hình máy chủ ngôn ngữ Java
    {
        "mfussenegger/nvim-jdtls",
        dependencies = { "mfussenegger/nvim-dap" },
    },

    -- Plugin toggleterm.nvim để hiển thị terminal
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 15,
                open_mapping = [[<c-\>]],
                hide_numbers = true,
                shade_terminals = true,
                shading_factor = 2,
                start_in_insert = true,
                insert_mappings = true,
                persist_size = true,
                direction = "horizontal",
                close_on_exit = false,
                shell = vim.o.shell,
                float_opts = {
                    border = "curved",
                    winblend = 3,
                    highlights = {
                        border = "Normal",
                        background = "Normal",
                    },
                },
            })
        end,
    },

    -- Plugin nvim-lspconfig để cấu hình các máy chủ ngôn ngữ
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "mfussenegger/nvim-jdtls",
            "stevearc/conform.nvim", -- Thêm conform.nvim vào dependencies
            "akinsho/toggleterm.nvim",
        },
        config = function()
            -- Yêu cầu và cấu hình conform trước
            require("plugins.conform")

            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Gọi setup_pyright từ module trong lua/config/pyright.lua
            require("config.pyright").setup_pyright()

            -- Cấu hình các máy chủ ngôn ngữ khác
            lspconfig.lua_ls.setup({ capabilities = capabilities })
            lspconfig.ts_ls.setup({ capabilities = capabilities })
            lspconfig.html.setup({ capabilities = capabilities })
            lspconfig.cssls.setup({ capabilities = capabilities })
            lspconfig.groovyls.setup({
                capabilities = capabilities,
                filetypes = { "groovy" },
                root_dir = lspconfig.util.root_pattern(".git", "gradlew", "build.gradle", "pom.xml"),
            })

            -- Cấu hình phím tắt chung cho LSP
            vim.keymap.set("n", "<leader>ch", vim.lsp.buf.hover, { desc = "Tài liệu khi di chuột qua mã" })
            vim.keymap.set("n", "<leader>cd", vim.lsp.buf.definition, { desc = "Đi đến định nghĩa mã" })
            vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Hành động mã" })
            vim.keymap.set("n", "<leader>cr", require("telescope.builtin").lsp_references, { desc = "Đi đến tham chiếu mã" })
            vim.keymap.set("n", "<leader>ci", require("telescope.builtin").lsp_implementations, { desc = "Đi đến triển khai mã" })
            vim.keymap.set("n", "<leader>cR", vim.lsp.buf.rename, { desc = "Đổi tên mã" })
            vim.keymap.set("n", "<leader>cD", vim.lsp.buf.declaration, { desc = "Đi đến khai báo mã" })

            -- Autocommands
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "java",
                callback = function()
                    require("config.jdtls").setup_jdtls()
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "kotlin", "kts" },
                callback = function()
                    require("config.jdtls").setup_kotlin()
                end,
            })
        end,
    },
}

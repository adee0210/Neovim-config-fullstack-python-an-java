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
            "stevearc/conform.nvim",
            "akinsho/toggleterm.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local toggleterm = require("toggleterm")
            local mason_registry = require("mason-registry")

            -- Biến để lưu trữ extraPaths hiện tại
            local current_extra_paths = { vim.fn.expand("~/.python_envs/global_env/lib/python3.12/site-packages") }

            -- Hàm chạy Python trong toggleterm
            local function run_python_in_terminal()
                local file = vim.fn.expand("%:p")
                local cmd = "~/.python_envs/global_env/bin/python " .. file
                toggleterm.exec(cmd, 1)
            end

            -- Hàm thay đổi extraPaths động
            local function update_pyright_paths()
                local new_path = vim.fn.input("Nhập đường dẫn mới cho extraPaths (Enter để giữ nguyên): ", current_extra_paths[1])
                if new_path ~= "" then
                    current_extra_paths = { vim.fn.expand(new_path) }
                    print("Đã cập nhật extraPaths thành: " .. table.concat(current_extra_paths, ", "))
                else
                    print("Giữ nguyên extraPaths: " .. table.concat(current_extra_paths, ", "))
                end
                lspconfig.pyright.setup({
                    capabilities = capabilities,
                    filetypes = { "python" },
                    settings = {
                        python = {
                            analysis = {
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "workspace",
                                extraPaths = current_extra_paths,
                            },
                            pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                        },
                    },
                    root_dir = lspconfig.util.root_pattern(".git", "pyproject.toml", "setup.py", "requirements.txt"),
                    on_attach = function(client, bufnr)
                        vim.keymap.set("n", "<leader>Po", "<Cmd>lua require('conform').format({ async = false, lsp_fallback = true })<CR>", { buffer = bufnr, desc = "Định dạng mã Python" })
                        vim.keymap.set("n", "<leader>Pd", "<Cmd>lua require('dap').continue()<CR>", { buffer = bufnr, desc = "Chạy Debug Python" })
                        vim.keymap.set("n", "<leader>Pb", "<Cmd>lua require('dap').toggle_breakpoint()<CR>", { buffer = bufnr, desc = "Đặt/Tắt Breakpoint Python" })
                        vim.keymap.set("n", "<leader>Pr", run_python_in_terminal, { buffer = bufnr, desc = "Chạy file Python trong terminal" })
                    end,
                })
                vim.lsp.stop_client(vim.lsp.get_active_clients({ name = "pyright" }))
                vim.defer_fn(function()
                    vim.cmd("LspRestart pyright")
                end, 500)
            end

            -- Kiểm tra và cài đặt Black
            local black_pkg = mason_registry.get_package("black")
            local black_path = black_pkg:get_install_path() .. "/venv/bin/black"
            if not black_pkg:is_installed() then
                vim.fn.system("nvim -c 'MasonInstall black' -c 'q'")
                vim.wait(10000, function() return black_pkg:is_installed() end, 100)
                if not black_pkg:is_installed() then
                    error("Không thể cài đặt Black. Vui lòng chạy :MasonInstall black thủ công.")
                end
            end
            -- Không in đường dẫn Black nữa
            if not vim.loop.fs_stat(black_path) then
                vim.fn.system("nvim -c 'MasonInstall black' -c 'q'")
                vim.wait(10000, function() return vim.loop.fs_stat(black_path) end, 100)
            end
            vim.fn.system("chmod +x " .. black_path)

            -- Tích hợp conform.nvim cho định dạng
            require("conform").setup({
                formatters_by_ft = {
                    python = { "black" },
                    lua = { "stylua" },
                    javascript = { "prettierd" },
                    typescript = { "prettierd" },
                },
                formatters = {
                    black = {
                        command = black_path,
                        args = { "--fast", "--line-length", "88", "-" },
                        stdin = true,
                    },
                },
                format_on_save = {
                    timeout_ms = 2000,
                    lsp_fallback = true,
                },
                log_level = vim.log.levels.DEBUG, -- Giữ debug để kiểm tra nếu cần
            })

            -- Cấu hình Pyright
            lspconfig.pyright.setup({
                capabilities = capabilities,
                filetypes = { "python" },
                settings = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            useLibraryCodeForTypes = true,
                            diagnosticMode = "workspace",
                            extraPaths = current_extra_paths,
                        },
                        pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                    },
                },
                root_dir = lspconfig.util.root_pattern(".git", "pyproject.toml", "setup.py", "requirements.txt"),
                on_attach = function(client, bufnr)
                    vim.keymap.set("n", "<leader>Po", "<Cmd>lua require('conform').format({ async = false, lsp_fallback = true })<CR>", { buffer = bufnr, desc = "Định dạng mã Python" })
                    vim.keymap.set("n", "<leader>Pd", "<Cmd>lua require('dap').continue()<CR>", { buffer = bufnr, desc = "Chạy Debug Python" })
                    vim.keymap.set("n", "<leader>Pb", "<Cmd>lua require('dap').toggle_breakpoint()<CR>", { buffer = bufnr, desc = "Đặt/Tắt Breakpoint Python" })
                    vim.keymap.set("n", "<leader>Pr", run_python_in_terminal, { buffer = bufnr, desc = "Chạy file Python trong terminal" })
                end,
            })

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
            vim.keymap.set("n", "<leader>Pp", update_pyright_paths, { desc = "Thay đổi extraPaths cho Pyright" })

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

            vim.api.nvim_create_autocmd("FileType", {
                pattern = "python",
                callback = function()
                    local dap = require("dap")
                    dap.adapters.python = {
                        type = "executable",
                        command = mason_registry.get_package("debugpy"):get_install_path() .. "/venv/bin/python",
                        args = { "-m", "debugpy.adapter" },
                    }
                    dap.configurations.python = {
                        {
                            type = "python",
                            request = "launch",
                            name = "Launch file",
                            program = "${file}",
                            pythonPath = function()
                                return vim.fn.expand("~/.python_envs/global_env/bin/python")
                            end,
                        },
                    }
                end,
            })
        end,
    },
}

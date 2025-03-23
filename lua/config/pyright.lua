local function get_pyright_and_tools()
    local mason_registry = require("mason-registry")
    local function get_path(package_name, path_suffix)
        local package = mason_registry.get_package(package_name)
        if not package:is_installed() then error(package_name .. " not installed") end
        return package:get_install_path() .. path_suffix
    end
    return get_path("pyright", "/node_modules/.bin/pyright-langserver"),
           get_path("black", "/venv/bin/black"),
           get_path("debugpy", "/venv/bin/python")
end

local function run_python_in_terminal()
    local file = vim.fn.expand("%:p")
    local cmd = "~/.python_envs/global_env/bin/python " .. file
    local term = require("toggleterm.terminal").Terminal
    local python_term = term:new({
        hidden = true,              -- Ẩn terminal khi không dùng
        direction = "horizontal",   -- Hướng terminal
        on_open = function(t)
            vim.api.nvim_buf_set_lines(t.bufnr, 0, -1, false, {})  -- Xóa nội dung cũ
            t:send(cmd, false)  -- Gửi lệnh mà không hiển thị
        end,
    })
    python_term:toggle()  -- Mở terminal và chạy lệnh
end

local function python_keymaps(bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "<leader>Po", "<Cmd>lua require('conform').format({ async = false, lsp_fallback = true })<CR>", vim.tbl_extend("force", opts, { desc = "Format Python" }))
    vim.keymap.set("n", "<leader>Pd", "<Cmd>lua require('dap').continue()<CR>", vim.tbl_extend("force", opts, { desc = "Run Debug" }))
    vim.keymap.set("n", "<leader>Pb", "<Cmd>lua require('dap').toggle_breakpoint()<CR>", vim.tbl_extend("force", opts, { desc = "Toggle Breakpoint" }))
    vim.keymap.set("n", "<leader>Pi", "<Cmd>PyrightOrganizeImports<CR>", vim.tbl_extend("force", opts, { desc = "Organize Imports" }))
    vim.keymap.set("n", "<leader>Pv", "<Cmd>lua require('refactoring').refactor('Extract Variable')<CR>", vim.tbl_extend("force", opts, { desc = "Extract Variable" }))
    vim.keymap.set("n", "<leader>Pr", run_python_in_terminal, vim.tbl_extend("force", opts, { desc = "Run Python File" }))
end

local function setup_pyright()
    local lspconfig = require("lspconfig")
    local pyright_path, black_path, debugpy_path = get_pyright_and_tools()
    local root_dir = lspconfig.util.root_pattern(".git", "pyproject.toml", "setup.py", "requirements.txt")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    lspconfig.pyright.setup({
        cmd = { pyright_path, "--stdio" },
        capabilities = capabilities,
        filetypes = { "python" },
        root_dir = root_dir,
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = "workspace",
                    typeCheckingMode = "basic",
                    stubPath = vim.fn.expand("~/.python_envs/global_env/lib/python3.12/site-packages"),
                },
                linting = {
                    enabled = true,
                    pylintEnabled = true,
                    pylintArgs = { "--disable=C0111" },
                },
            },
        },
        on_attach = function(client, bufnr)
            python_keymaps(bufnr)
            local dap = require("dap")
            dap.adapters.python = {
                type = "executable",
                command = debugpy_path,
                args = { "-m", "debugpy.adapter" },
            }
            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch file",
                    program = "${file}",
                    pythonPath = "python",
                },
            }
            require("conform").setup({
                formatters_by_ft = { python = { "black" } },
                formatters = {
                    black = {
                        command = black_path,
                        args = { "--fast", "--line-length", "88", "--skip-string-normalization", "-" },
                        stdin = true,
                    },
                },
                format_on_save = { timeout_ms = 500, lsp_fallback = true },
            })
        end,
    })
end

return { setup_pyright = setup_pyright }

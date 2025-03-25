local mason_registry = require("mason-registry")
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Lấy đường dẫn công cụ
local function get_pyright_and_tools()
    local function get_path(package_name, path_suffix)
        local package = mason_registry.get_package(package_name)
        if not package:is_installed() then error(package_name .. " chưa được cài đặt") end
        return package:get_install_path() .. path_suffix
    end
    return get_path("pyright", "/node_modules/.bin/pyright-langserver"),
           get_path("black", "/venv/bin/black"),
           get_path("debugpy", "/venv/bin/python")
end

-- Terminal Python
local python_term = nil
local function run_python_in_terminal()
    local file = vim.fn.expand("%:p")
    local cmd = "~/.python_envs/global_env/bin/python " .. file
    local term = require("toggleterm.terminal").Terminal

    if not python_term then
        python_term = term:new({
            hidden = true,
            direction = "horizontal",
            on_open = function(t)
                t:clear()
                t:send(cmd, false)
            end,
            on_close = function()
                python_term = nil
            end,
        })
    end
    python_term:toggle()
end

-- Định dạng và sắp xếp imports
local function format_and_organize()
    vim.api.nvim_command("silent! PyrightOrganizeImports")
    require("conform").format({ async = false, lsp_fallback = true })
end

-- Keymaps
local function python_keymaps(bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "<leader>Pf", format_and_organize, vim.tbl_extend("force", opts, { desc = "Định dạng và sắp xếp imports" }))
    vim.keymap.set("n", "<leader>Pd", "<Cmd>lua require('dap').continue()<CR>", vim.tbl_extend("force", opts, { desc = "Chạy gỡ lỗi" }))
    vim.keymap.set("n", "<leader>Pb", "<Cmd>lua require('dap').toggle_breakpoint()<CR>", vim.tbl_extend("force", opts, { desc = "Bật/Tắt điểm ngắt" }))
    vim.keymap.set("n", "<leader>Pv", "<Cmd>lua require('refactoring').refactor('Extract Variable')<CR>", vim.tbl_extend("force", opts, { desc = "Trích xuất biến" }))
    vim.keymap.set("n", "<leader>Pr", run_python_in_terminal, vim.tbl_extend("force", opts, { desc = "Chạy file Python" }))
end

-- Cấu hình Pyright
local function setup_pyright()
    local pyright_path, _, debugpy_path = get_pyright_and_tools()
    local root_dir = lspconfig.util.root_pattern(".git", "pyproject.toml", "setup.py", "requirements.txt")
    local current_extra_paths = { vim.fn.expand("~/.python_envs/global_env/lib/python3.12/site-packages") }

    local handlers = {
        ["workspace/executeCommand"] = function(err, result, ctx, config)
            if ctx.command == "pyright.organizeimports" then return {} end -- Chặn thông báo từ lệnh này
            return vim.lsp.handlers["workspace/executeCommand"](err, result, ctx, config)
        end,
        ["window/showMessage"] = function(err, result, ctx, config)
            if result and result.message and result.message:find("pyright%.organizeimports") then return end -- Chặn thông báo hiển thị
            return vim.lsp.handlers["window/showMessage"](err, result, ctx, config)
        end,
    }

    local function update_pyright_paths()
        local new_path = vim.fn.input("Nhập extraPaths mới (Enter để giữ nguyên): ", current_extra_paths[1])
        if new_path ~= "" then current_extra_paths = { vim.fn.expand(new_path) } end
        print("extraPaths: " .. table.concat(current_extra_paths, ", "))
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
                        diagnosticMode = "openFilesOnly",
                        typeCheckingMode = "basic",
                        extraPaths = current_extra_paths,
                    },
                    pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                    linting = { enabled = true, pylintEnabled = true, pylintArgs = { "--disable=C0111" } },
                },
            },
            handlers = handlers,
            on_attach = function(client, bufnr)
                python_keymaps(bufnr)
                vim.keymap.set("n", "<leader>Pp", update_pyright_paths, { buffer = bufnr, desc = "Cập nhật extraPaths" })
                require("dap").adapters.python = {
                    type = "executable",
                    command = debugpy_path,
                    args = { "-m", "debugpy.adapter" },
                }
                require("dap").configurations.python = {
                    {
                        type = "python",
                        request = "launch",
                        name = "Launch file",
                        program = "${file}",
                        pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                    },
                }
            end,
        })
        vim.lsp.stop_client(vim.lsp.get_active_clients({ name = "pyright" }))
        vim.defer_fn(function() vim.cmd("LspRestart pyright") end, 500)
    end

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
                    diagnosticMode = "openFilesOnly",
                    typeCheckingMode = "basic",
                    extraPaths = current_extra_paths,
                },
                pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                linting = { enabled = true, pylintEnabled = true, pylintArgs = { "--disable=C0111" } },
            },
        },
        handlers = handlers,
        on_attach = function(client, bufnr)
            python_keymaps(bufnr)
            vim.keymap.set("n", "<leader>Pp", update_pyright_paths, { buffer = bufnr, desc = "Cập nhật extraPaths" })
        end,
    })
end

return { setup_pyright = setup_pyright }

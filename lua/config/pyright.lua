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

-- Biến toàn cục để lưu terminal instance
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
                t:clear() -- Dùng t:clear() để xóa nội dung
                t:send(cmd, false)
            end,
            on_close = function()
                python_term = nil
            end,
        })
    end

    if python_term:is_open() then
        python_term:toggle()
    else
        python_term:toggle()
        if not python_term:is_open() then
            python_term:send(cmd, false)
        end
    end
end

-- Hàm kết hợp format và organize imports
local function format_and_organize()
    pcall(function() vim.api.nvim_command("silent! PyrightOrganizeImports") end) -- Chạy im lặng với silent!
    require("conform").format({ async = false, lsp_fallback = true })
end

local function python_keymaps(bufnr)
    local opts = { buffer = bufnr }
    vim.keymap.set("n", "<leader>Po", format_and_organize, vim.tbl_extend("force", opts, { desc = "Định dạng và sắp xếp imports" }))
    vim.keymap.set("n", "<leader>Pd", "<Cmd>lua require('dap').continue()<CR>", vim.tbl_extend("force", opts, { desc = "Chạy gỡ lỗi" }))
    vim.keymap.set("n", "<leader>Pb", "<Cmd>lua require('dap').toggle_breakpoint()<CR>", vim.tbl_extend("force", opts, { desc = "Bật/Tắt điểm ngắt" }))
    vim.keymap.set("n", "<leader>Pi", "<Cmd>silent! PyrightOrganizeImports<CR>", vim.tbl_extend("force", opts, { desc = "Sắp xếp Imports" }))
    vim.keymap.set("n", "<leader>Pv", "<Cmd>lua require('refactoring').refactor('Extract Variable')<CR>", vim.tbl_extend("force", opts, { desc = "Trích xuất biến" }))
    vim.keymap.set("n", "<leader>Pr", run_python_in_terminal, vim.tbl_extend("force", opts, { desc = "Chạy file Python" }))
    vim.keymap.set("n", "<leader>Px", function() if python_term then python_term:toggle() end end, vim.tbl_extend("force", opts, { desc = "Bật/Tắt terminal Python" }))
    vim.keymap.set("n", "<C-s>", format_and_organize, vim.tbl_extend("force", opts, { desc = "Lưu và định dạng mã Python" }))
end

local function setup_pyright()
    local lspconfig = require("lspconfig")
    local pyright_path, black_path, debugpy_path = get_pyright_and_tools()
    local root_dir = lspconfig.util.root_pattern(".git", "pyproject.toml", "setup.py", "requirements.txt")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local current_extra_paths = { vim.fn.expand("~/.python_envs/global_env/lib/python3.12/site-packages") }

    -- Tùy chỉnh handlers để chặn thông báo từ pyright.organizeimports
    local handlers = {
        ["workspace/executeCommand"] = function(err, result, ctx, config)
            if ctx.command == "pyright.organizeimports" then
                return -- Chặn hoàn toàn thông báo từ lệnh này
            end
            return vim.lsp.handlers["workspace/executeCommand"](err, result, ctx, config)
        end,
        ["window/showMessage"] = function(err, result, ctx, config)
            if result and result.message and result.message:match("pyright%.organizeimports") then
                return -- Chặn thông báo liên quan đến pyright.organizeimports
            end
            return vim.lsp.handlers["window/showMessage"](err, result, ctx, config)
        end,
    }

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
                        extraPaths = current_extra_paths,
                    },
                    pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                    linting = {
                        enabled = true,
                        pylintEnabled = true,
                        pylintArgs = { "--disable=C0111" },
                    },
                },
            },
            handlers = handlers, -- Sử dụng handlers đã tùy chỉnh
            on_attach = function(client, bufnr)
                python_keymaps(bufnr)
                vim.keymap.set("n", "<leader>Pp", update_pyright_paths, { buffer = bufnr, desc = "Cập nhật extraPaths Pyright" })
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
                        pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                    },
                }
            end,
        })
        vim.lsp.stop_client(vim.lsp.get_active_clients({ name = "pyright" }))
        vim.defer_fn(function()
            vim.cmd("LspRestart pyright")
        end, 500)
    end

    -- Cấu hình Pyright ban đầu
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
                    extraPaths = current_extra_paths,
                },
                pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                linting = {
                    enabled = true,
                    pylintEnabled = true,
                    pylintArgs = { "--disable=C0111" },
                },
            },
        },
        handlers = handlers, -- Sử dụng handlers đã tùy chỉnh
        on_attach = function(client, bufnr)
            python_keymaps(bufnr)
            vim.keymap.set("n", "<leader>Pp", update_pyright_paths, { buffer = bufnr, desc = "Cập nhật extraPaths Pyright" })
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
                    pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"),
                },
            }
        end,
    })
end

return { setup_pyright = setup_pyright }

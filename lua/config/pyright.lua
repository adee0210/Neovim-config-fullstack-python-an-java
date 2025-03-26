local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

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
    lspconfig.pyright.setup({
        capabilities = capabilities,
        filetypes = { "python" }, -- Chỉ áp dụng cho .py
        settings = {
            python = {
                analysis = {
                    extraPaths = { vim.fn.expand("~/.python_envs/global_env/lib/python3.12/site-packages") }, -- Thư viện global
                },
                pythonPath = vim.fn.expand("~/.python_envs/global_env/bin/python"), -- Đường dẫn Python global
            },
        },
        on_attach = function(client, bufnr)
            python_keymaps(bufnr) -- Gắn phím tắt
        end,
    })
end

-- Trì hoãn khởi động Pyright cho đến khi mở .py hoặc .md
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python"},
    callback = function()
        -- Chỉ khởi động Pyright nếu chưa được khởi động
        if not lspconfig.pyright.document_config then
            setup_pyright()
        end
    end,
})

return { setup_pyright = setup_pyright } -- Giữ lại để tương thích với lsp-config.lua

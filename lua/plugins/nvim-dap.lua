return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
    },
    event = { "BufReadPre", "BufNewFile" }, -- Tải DAP khi mở file
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        -- Biến lưu cửa sổ mã nguồn
        local code_win = nil

        -- Thiết lập DAP UI giống VSCode
        dapui.setup({
            icons = { expanded = "▾", collapsed = "▸", current_frame = "→" }, -- Biểu tượng giống VSCode
            layouts = {
                {
                    elements = {
                        { id = "scopes", size = 0.4 },      -- Biến
                        { id = "breakpoints", size = 0.2 }, -- Điểm dừng
                        { id = "stacks", size = 0.3 },      -- Ngăn xếp
                        { id = "watches", size = 0.1 },     -- Theo dõi
                    },
                    size = 40,
                    position = "left", -- Panel trái
                },
                {
                    elements = {
                        { id = "repl", size = 0.5 },    -- REPL
                        { id = "console", size = 0.5 }, -- Console
                    },
                    size = 12,          -- Tăng chiều cao console để hiển thị lỗi chi tiết
                    position = "bottom", -- Console dưới cùng
                },
            },
            floating = { max_height = 0.9, max_width = 0.9, border = "rounded" },
            controls = {
                enabled = true,
                element = "repl", -- Điều khiển trong REPL giống VSCode
                icons = {
                    pause = "⏸",
                    play = "▶",
                    step_into = "↓",
                    step_over = "→",
                    step_out = "↑",
                    step_back = "←",
                    run_last = "↻",
                    terminate = "⏹",
                },
            },
            render = {
                max_type_length = 20, -- Giới hạn độ dài kiểu biến để gọn gàng
            },
        })

        -- Hàm mở DAP UI và giữ focus ở mã nguồn
        local function open_dap_ui()
            code_win = vim.api.nvim_get_current_win()
            dapui.open()
            vim.api.nvim_set_current_win(code_win)
            -- Tô sáng dòng hiện tại khi dừng (giống VSCode)
            vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#3C2F2F" }) -- Nền đỏ nhạt
            vim.fn.sign_place(0, "dap_signs", "DapStopped", vim.api.nvim_get_current_buf(), { lnum = vim.fn.line(".") })
        end

        -- Hàm đóng DAP UI
        local function close_dap_ui()
            dapui.close()
            vim.fn.sign_unplace("dap_signs")
            code_win = nil
        end

        -- Tự động mở DAP UI khi debug bắt đầu hoặc dừng
        dap.listeners.before.launch.dapui_config = function()
            open_dap_ui()
        end
        dap.listeners.after.event_initialized["dapui_config"] = function()
            open_dap_ui()
        end
        dap.listeners.after.event_breakpoint["dapui_config"] = function()
            open_dap_ui()
            vim.notify("Breakpoint hit at " .. vim.fn.expand("<cWORD>"), vim.log.levels.INFO)
        end
        dap.listeners.after.event_stopped["dapui_config"] = function()
            open_dap_ui()
            vim.notify("Debug stopped (possible error)", vim.log.levels.WARN)
        end

        -- Đóng DAP UI khi debug kết thúc
        dap.listeners.before.event_terminated.dapui_config = close_dap_ui
        dap.listeners.before.event_exited.dapui_config = close_dap_ui

        -- Ngăn DAP UI chiếm focus
        vim.api.nvim_create_autocmd("WinEnter", {
            callback = function()
                local current_buf = vim.api.nvim_get_current_buf()
                local buf_name = vim.api.nvim_buf_get_name(current_buf)
                if (buf_name:match("dapui_") or buf_name:match("dap%-repl")) and code_win then
                    vim.schedule(function()
                        vim.api.nvim_set_current_win(code_win)
                    end)
                end
            end,
        })

        -- Tắt chuột trong DAP UI
        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = { "dap-repl", "dapui_watches", "dapui_scopes", "dapui_breakpoints", "dapui_stacks" },
            callback = function()
                vim.opt_local.mouse = ""
                if code_win then
                    vim.api.nvim_set_current_win(code_win)
                end
            end,
        })

        -- Định nghĩa signs cho breakpoint và dừng
        vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
        vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticWarn", linehl = "DapStoppedLine", numhl = "" })

        -- Phím tắt Debug 
        vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
        vim.keymap.set("n", "<F5>", dap.continue, { desc = "Start/Continue" })
        vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over" })
        vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into" })
        vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step Out" })
        vim.keymap.set("n", "<leader>dc", close_dap_ui, { desc = "[D]ebug [C]lose" })
        vim.keymap.set("n", "<leader>du", open_dap_ui, { desc = "[D]ebug [U]I Open" })

        -- Tích hợp với JDTLS (Java) - ví dụ
        dap.adapters.java = function(callback)
            -- JDTLS đã cấu hình DAP qua bundles trong jdtls.lua
            callback({ type = "server", host = "localhost", port = 5005 })
        end
    end,
}

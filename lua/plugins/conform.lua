return {
    "stevearc/conform.nvim",
    event = { "BufWritePre" }, -- Kích hoạt trước khi ghi buffer
    config = function()
        local conform = require("conform")

        -- Cấu hình các formatter theo loại file
        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" }, -- Format Lua bằng stylua
                javascript = { "prettierd" }, -- Format JS bằng prettierd
                typescript = { "prettierd" },
                javascriptreact = { "prettierd" },
                typescriptreact = { "prettierd" },
                json = { "prettierd" },
                html = { "prettierd" },
                css = { "prettierd" },
                markdown = { "prettierd" },
                python = { "black" }, -- Format Python bằng black
                -- Java không cần formatter ở đây vì JDTLS sẽ xử lý
            },
            -- Cấu hình tùy chỉnh cho formatter
            formatters = {
                stylua = {
                    command = "stylua",
                    args = { "--search-parent-directories", "-" },
                },
                prettierd = {
                    command = "prettierd",
                    args = function(self, ctx)
                        return {
                            "--stdin-filepath",
                            ctx.filename,
                            ctx.options and ctx.options.tabSize and "--tab-width" or nil,
                            ctx.options and ctx.options.tabSize or nil,
                        }
                    end,
                },
                black = {
                    command = "black",
                    args = { "--fast", "--line-length", "88", "--skip-string-normalization", "-" },
                    stdin = true,
                },
            },
            -- Format khi lưu (dùng chung với auto-save)
            format_on_save = function(bufnr)
                if vim.bo[bufnr].filetype == "python" then
                    pcall(function() vim.api.nvim_command("silent! PyrightOrganizeImports") end)
                end
                return { timeout_ms = 500, lsp_fallback = true }
            end,
        })

        -- Phím tắt để format thủ công
        vim.keymap.set("n", "<C-s>", function()
            if vim.bo.filetype == "python" then
                -- Ghi đè vim.notify để chặn thông báo trong phạm vi lệnh này
                local original_notify = vim.notify
                vim.notify = function(msg, ...)
                    if msg:match("pyright%.organizeimports") then
                        return -- Chặn thông báo liên quan đến pyright.organizeimports
                    end
                    original_notify(msg, ...)
                end
                -- Chạy PyrightOrganizeImports
                pcall(function() vim.api.nvim_command("silent! PyrightOrganizeImports") end)
                -- Khôi phục vim.notify sau khi chạy lệnh
                vim.notify = original_notify
            end
            conform.format({ async = false, lsp_fallback = true })
        end, { desc = "Code Format", silent = true })
    end,
}

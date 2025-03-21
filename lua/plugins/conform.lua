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
            },
            -- Format khi lưu (dùng chung với auto-save)
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true, -- Dùng LSP nếu formatter không có
            },
        })

        -- Phím tắt để format thủ công
        vim.keymap.set("n", "<C-s>", function()
            conform.format({ async = false, lsp_fallback = true })
        end, { desc = "Code Format" })
    end,
}

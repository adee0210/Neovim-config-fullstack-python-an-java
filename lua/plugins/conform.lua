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
                -- Nếu là file Python, chạy PyrightOrganizeImports im lặng
                if vim.bo[bufnr].filetype == "python" then
                    pcall(function() vim.api.nvim_command("silent PyrightOrganizeImports") end)
                end
                return { timeout_ms = 500, lsp_fallback = true }
            end,
        })

        -- Phím tắt để format thủ công
        vim.keymap.set("n", "<C-s>", function()
            -- Nếu là file Python, chạy PyrightOrganizeImports im lặng
            if vim.bo.filetype == "python" then
                pcall(function() vim.api.nvim_command("silent PyrightOrganizeImports") end)
            end
            conform.format({ async = false, lsp_fallback = true })
        end, { desc = "Code Format" })
    end,
}

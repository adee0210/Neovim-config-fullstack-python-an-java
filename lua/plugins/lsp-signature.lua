return {
    "ray-x/lsp_signature.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lsp_signature = require("lsp_signature")

        lsp_signature.setup({
            bind = true,
            floating_window = false,            -- Tắt cửa sổ nổi
            hint_enable = false,                -- Tắt gợi ý chữ ký
            hint_prefix = "󱄑 ",
            handler_opts = { border = "rounded" },
            transparency = 10,
            max_height = 10,
            max_width = 80,
            toggle_key = "<M-s>",
            floating_window_above_cur_line = true,
        })

        -- Gắn lsp_signature vào tất cả LSP qua LspAttach
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local bufnr = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client then
                    lsp_signature.on_attach({
                        bind = true,
                        floating_window = false,    -- Tắt cửa sổ nổi
                        hint_enable = false,        -- Tắt gợi ý chữ ký
                        hint_prefix = "󱄑 ",
                        handler_opts = { border = "rounded" },
                    }, bufnr)
                end
            end,
        })
    end,
}

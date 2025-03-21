return {
    -- Cấu hình LuaSnip và các plugin hỗ trợ
    {
        "L3MON4D3/LuaSnip",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets",
        },
    },
    -- Cung cấp các gợi ý tự động theo ngôn ngữ từ LSP
    {
        "hrsh7th/cmp-nvim-lsp",
    },
    -- Plugin nvim-cmp cung cấp giao diện hoàn thành tự động
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            -- Tải snippets giống VSCode
            require("luasnip.loaders.from_vscode").lazy_load()

            -- Cấu hình cmp
            cmp.setup({
                completion = {
                    completeopt = "menu,menuone,preview,noselect",
                },
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                }),
                -- Tùy chỉnh giao diện khung hoàn thành
                window = {
                    completion = cmp.config.window.bordered({
                        border = "rounded",                                                                          -- Viền bo tròn
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None", -- Highlight trong suốt
                        col_offset = -3,                                                                             -- Dịch cột để mở rộng không gian
                        side_padding = 1,                                                                            -- Thêm padding bên để "mở hơn"
                        scrollbar = false,                                                                           -- Tắt scrollbar cho giao diện gọn
                    }),
                    documentation = cmp.config.window.bordered({
                        border = "rounded",                                          -- Viền bo tròn cho tài liệu
                        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder", -- Trong suốt
                    }),
                },
                experimental = {
                    ghost_text = false, -- Hiển thị gợi ý mờ (inline ghost text)
                },
            })
        end,
    },
}

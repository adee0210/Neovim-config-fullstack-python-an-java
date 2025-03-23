return {
    "windwp/nvim-autopairs", -- Plugin nvim-autopairs của windwp
    event = { "InsertEnter" }, -- Plugin này sẽ được kích hoạt khi vào chế độ Insert (nhập liệu)
    dependencies = {
        "hrsh7th/nvim-cmp", -- Plugin nvim-cmp (autocomplete) là một phụ thuộc
    },
    config = function() -- Cấu hình plugin
        -- Gọi hàm setup của nvim-autopairs để cấu hình cách hoạt động của auto pairs
        require'nvim-autopairs'.setup({
            check_ts = true, -- Kiểm tra Tree-sitter cho các ngôn ngữ có hỗ trợ
            ts_config = { -- Cấu hình Tree-sitter cho từng ngôn ngữ cụ thể
                lua = { "string" }, -- Tự động đóng cặp trong chuỗi Lua
                javascript = { "template_string" }, -- Tự động đóng cặp trong template string JavaScript
                java = {}, -- Không cấu hình đặc biệt cho Java
                python = { "string" },
            }
        })

        -- Lấy quyền truy cập vào chức năng hoàn thành auto pairs và các plugin cmp
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")

        -- Khi người dùng xác nhận một sự lựa chọn từ autocompletion, đảm bảo rằng các cặp dấu sẽ tự động được đóng
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
}


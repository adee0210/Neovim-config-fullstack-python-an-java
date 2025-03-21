return {
    "nvim-lualine/lualine.nvim",  -- Plugin để tạo thanh trạng thái (statusline) tùy chỉnh
    dependencies = {
        "nvim-tree/nvim-web-devicons",  -- Plugin cung cấp các biểu tượng (icons) cho file types
    },
    config = function()
        -- Thiết lập lualine với các thuộc tính để định nghĩa giao diện của thanh trạng thái
        require("lualine").setup({
            options = {
                -- Sử dụng biểu tượng nếu bạn đã cài đặt nerdfont
                icons_enabled = true,
                -- Chọn theme "dracula", lualine cung cấp nhiều theme khác
                theme = "solarized",
                -- Phân tách các thành phần bằng ký tự chevron
                component_separators = { left = "", right = "" },
                -- Phân tách các section bằng ký tự tam giác
                section_separators = { left = "", right = "" },
                -- Vô hiệu hóa statusline và winbar cho các filetypes cụ thể
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                -- Bỏ qua focus trên NvimTree
                ignore_focus = { "NvimTree" },
                -- Luôn chia thanh trạng thái thành hai phần bằng nhau
                always_divide_middle = true,
                -- Vô hiệu hóa global status
                globalstatus = false,
                -- Làm mới thanh trạng thái mỗi 1000 mili giây
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                },
            },
            -- Thiết lập nội dung của từng section trong thanh trạng thái
            -- Các section bắt đầu từ a (bên trái) đến z (bên phải)
            sections = {
                -- Hiển thị chế độ hiện tại (ví dụ: Normal, Insert, Visual) trong section a
                lualine_a = { "mode" },
                -- Hiển thị branch Git, thay đổi Git và các thông báo lỗi (diagnostics) trong section b
                lualine_b = { "branch", "diff", "diagnostics" },
                -- Hiển thị tên file trong section c
                lualine_c = { "filename" },
                -- Hiển thị loại encoding, định dạng file và loại file trong section x
                lualine_x = { "encoding", "fileformat", "filetype" },
                -- Hiển thị tiến trình trong file (ví dụ: dòng hiện tại/tổng số dòng) trong section y
                lualine_y = { "progress" },
                -- Hiển thị vị trí chính xác của con trỏ (ví dụ: dòng và cột) trong section z
                lualine_z = { "location" },
            },
            -- Thiết lập nội dung của từng section trong các buffer không hoạt động
            inactive_sections = {
                -- Không hiển thị gì trong section a và b
                lualine_a = {},
                lualine_b = {},
                -- Hiển thị tên file trong section c
                lualine_c = { "filename" },
                -- Hiển thị vị trí chính xác của con trỏ trong section x
                lualine_x = { "location" },
                -- Không hiển thị gì trong section y và z
                lualine_y = {},
                lualine_z = {},
            },
            -- Sử dụng giá trị mặc định cho tabline, winbar, inactive winbar và extensions
            tabline = {},
            winbar = {},
            inactive_winbar = {},
            extensions = { "quickfix", "man", "fugitive" },  -- Mở rộng cho các chức năng như quickfix, man, fugitive
        })
    end,
}

return {
    "p00f/nvim-ts-rainbow",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPre", "BufNewFile" }, -- Tải plugin khi mở file
    config = function()
        require("nvim-treesitter.configs").setup({
            rainbow = {
                enable = true,              -- Bật tính năng tô màu dấu ngoặc
                extended_mode = true,       -- Hỗ trợ thêm các loại ngoặc (HTML, JSX, v.v.)
                max_file_lines = 2000,      -- Giới hạn 2000 dòng
                colors = {                  -- Bảng màu mới, sáng và phân biệt rõ
                    "#FF6B6B", -- Đỏ tươi
                    "#4ECDC4", -- Cyan ngọc
                    "#FFD700", -- Vàng ánh kim
                    "#FF69B4", -- Hồng phấn
                    "#7FFF00", -- Xanh chartreuse
                    "#00CED1", -- Xanh ngọc lam
                    "#FF4500", -- Cam đỏ
                    "#DA70D6", -- Tím hoa cà
                    "#32CD32", -- Xanh lá lime
                    "#1E90FF", -- Xanh dương sáng
                    "#FFB6C1", -- Hồng nhạt
                    "#ADFF2F", -- Xanh lá vàng
                },
                disable = { "txt" },        -- Tắt rainbow cho file .txt
            },
        })
    end,
}

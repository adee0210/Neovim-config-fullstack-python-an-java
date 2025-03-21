return {
    -- Plugin Tokyo Night (Colorscheme)
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("tokyonight").setup({
                style = "night", -- Chọn style: "storm", "moon", "night", hoặc "day"
                transparent = true, -- Bật nền trong suốt cho toàn bộ giao diện
                terminal_colors = true, -- Áp dụng màu cho terminal
                styles = {
                    comments = { italic = true }, -- Kiểu chữ nghiêng cho comments
                    keywords = { italic = true , bold = true},
                    functions = {},
                    variables = {},
                    sidebars = "transparent", -- Đặt sidebar (như Vim Tree) trong suốt
                    floats = "transparent", -- Đặt floating windows trong suốt
                },
                sidebars = { "qf", "vista_kind", "terminal", "packer", "NvimTree" }, -- Thêm NvimTree vào danh sách sidebar
                day_brightness = 0.3, -- Độ sáng khi dùng style "day"
                hide_inactive_statusline = false, -- Ẩn statusline khi không hoạt động
                dim_inactive = false, -- Làm mờ các cửa sổ không hoạt động
                lualine_bold = true, -- In đậm cho lualine
            })
            vim.cmd([[colorscheme tokyonight]]) -- Kích hoạt colorscheme
        end,
    },

    -- Plugin nvim-web-devicons
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                default = true,
            })
        end,
    },

    -- Gọi colorscheme.lua (chứa bufferline.nvim)
    require("plugins.bufferline"),
}

return {
    "NStefan002/screenkey.nvim",
    version = "*", -- Dùng phiên bản mới nhất
    event = "VeryLazy", -- Tải chậm để tối ưu
    config = function()
        require("screenkey").setup({
            win_opts = {
                row = vim.o.lines - 2, -- Gần dưới cùng
                col = vim.o.columns / 2, -- Căn giữa
                width = 10, -- Khung nhỏ
                height = 1, -- Chiều cao tối thiểu
                border = "single", -- Viền đơn giản
                winblend = 20, -- Trong suốt nhẹ
            },
            compress_after = 3, -- Nén phím sau 3 lần gõ liên tiếp
            clear_after = 300, -- Xóa khung sau 300ms
            disable = {
                filetypes = { "help", "lazy" }, -- Tắt ở các file không cần
                buftypes = { "terminal" },
            },
        })
    end,
}

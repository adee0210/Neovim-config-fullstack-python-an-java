-- Đặt phím dẫn (leader key) thành phím Space
-- Bất cứ nơi nào bạn thấy <leader> trong thiết lập phím đều có nghĩa là phím Space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Xóa highlight tìm kiếm sau khi tìm kiếm xong
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Xóa highlight tìm kiếm" })

-- Thoát chế độ terminal của Vim
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Thoát chế độ terminal" })

-- TÙY CHỌN: Vô hiệu hóa phím mũi tên trong chế độ bình thường
-- vim.keymap.set('n', '<left>', '<cmd>echo "Dùng phím h để di chuyển!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Dùng phím l để di chuyển!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Dùng phím k để di chuyển!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Dùng phím j để di chuyển!!"<CR>')

-- Di chuyển giữa các cửa sổ dễ dàng hơn
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Di chuyển sang cửa sổ bên trái" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Di chuyển sang cửa sổ bên phải" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Di chuyển xuống cửa sổ phía dưới" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Di chuyển lên cửa sổ phía trên" })

-- Chia cửa sổ dễ dàng hơn
vim.keymap.set("n", "<leader>wv", ":vsplit<cr>", { desc = "Window Chia dọc màn hình(Vertical)" })
vim.keymap.set("n", "<leader>wh", ":split<cr>", { desc = "Window Chia ngang màn hình(Horizontal)" })

-- Giữ nguyên chế độ chọn khi thụt lề dòng
vim.keymap.set("v", "<", "<gv", { desc = "Thụt lề trái trong chế độ chọn" })
vim.keymap.set("v", ">", ">gv", { desc = "Thụt lề phải trong chế độ chọn" })


-- Cột bên trái và các thiết lập tương tự
vim.opt.number = true -- hiển thị số dòng
vim.opt.relativenumber = false -- không hiển thị số dòng tương đối
vim.opt.numberwidth = 2 -- thiết lập chiều rộng của cột số dòng
vim.opt.signcolumn = "yes" -- luôn hiển thị cột dấu (sign column)
vim.opt.wrap = false -- hiển thị dòng văn bản như một dòng duy nhất
vim.opt.scrolloff = 10 -- số dòng giữ ở trên/dưới con trỏ
vim.opt.sidescrolloff = 8 -- số cột giữ ở bên trái/phải con trỏ

-- Thụt lề/Tab
vim.opt.expandtab = true -- chuyển đổi tab thành dấu cách
vim.opt.shiftwidth = 4 -- số dấu cách chèn vào cho mỗi cấp độ thụt lề
vim.opt.tabstop = 4 -- số dấu cách chèn vào cho ký tự tab
vim.opt.softtabstop = 4 -- số dấu cách chèn vào khi nhấn phím <Tab>
vim.opt.smartindent = true -- bật thụt lề thông minh
vim.opt.breakindent = true -- bật thụt lề khi xuống dòng

-- Các hành vi tổng quát
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.backup = false -- vô hiệu hóa việc tạo file sao lưu
vim.opt.clipboard = "unnamedplus" -- bật tính năng truy cập clipboard hệ thống
vim.opt.conceallevel = 0 -- để `` hiển thị trong các file markdown
vim.opt.fileencoding = "utf-8" -- thiết lập mã hóa file là UTF-8
vim.opt.mouse = "a" -- bật hỗ trợ chuột
vim.opt.showmode = false -- ẩn chế độ hiển thị
vim.opt.splitbelow = true -- ép buộc các cửa sổ chia ngang nằm dưới cửa sổ hiện tại
vim.opt.splitright = true -- ép buộc các cửa sổ chia dọc nằm bên phải cửa sổ hiện tại
vim.opt.termguicolors = true -- bật màu sắc GUI trong terminal
vim.opt.timeoutlen = 1000 -- thiết lập thời gian timeout cho các chuỗi phím tắt
vim.opt.undofile = true -- bật tính năng undo vĩnh viễn
vim.opt.updatetime = 300 -- thiết lập thời gian hoàn thành nhanh hơn
vim.opt.writebackup = false -- ngăn chặn việc chỉnh sửa các file đang được chỉnh sửa ở nơi khác
vim.opt.cursorline = true -- làm nổi bật dòng hiện tại
vim.o.swapfile = false  -- Tắt tính năng tạo file swap
-- Các hành vi tìm kiếm
vim.opt.hlsearch = true -- bật tính năng highlight tất cả kết quả tìm kiếm
vim.opt.ignorecase = true -- không phân biệt chữ hoa/thường khi tìm kiếm
vim.opt.smartcase = true -- tìm kiếm phân biệt chữ hoa/thường nếu rõ ràng trong cú pháp tìm

-- Cấu hình phím tắt sao chép vào clipboard
vim.api.nvim_set_keymap("n", "<leader>y", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<leader>y", '"+y', { noremap = true, silent = true })


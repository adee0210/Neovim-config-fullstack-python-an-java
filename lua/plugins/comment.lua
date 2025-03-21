return {
	-- Định nghĩa plugin Comment.nvim
	"numToStr/Comment.nvim",
	event = { "BufReadPre", "BufNewFile" }, -- Kích hoạt plugin khi mở tệp
	dependencies = {
		-- Plugin giúp tự động comment cho các phần tử tsx trong file với plugin comment
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	config = function()
		-- Thiết lập phím tắt để comment dòng dưới con trỏ trong chế độ bình thường
		vim.keymap.set("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)", { desc = "Comment Line" })
		-- Thiết lập phím tắt để comment tất cả các dòng đã chọn trong chế độ visual
		vim.keymap.set("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)", { desc = "Comment Selected" })

		-- Lấy quyền truy cập vào các hàm của plugin Comment
		local comment = require("Comment")
		-- Lấy quyền truy cập vào các hàm của plugin ts_context_commentstring
		local ts_context_comment_string = require("ts_context_commentstring.integrations.comment_nvim")

		-- Cấu hình plugin Comment để sử dụng ts_context_comment_string khi comment các phần tử tsx
		comment.setup({
			pre_hook = ts_context_comment_string.create_pre_hook(),
		})
	end,
}


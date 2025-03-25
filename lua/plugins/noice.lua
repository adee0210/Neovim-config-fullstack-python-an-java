return {
  {
    "folke/noice.nvim",
    event = "VeryLazy", -- Tải plugin sau khi Neovim khởi động hoàn toàn
    dependencies = {
      "MunifTanjim/nui.nvim", -- Yêu cầu cho giao diện popup
      "rcarriga/nvim-notify", -- Tích hợp thông báo đẹp hơn
    },
    config = function()
      require("noice").setup({
        lsp = {
          -- Cải thiện giao tiếp với LSP
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true, -- Tùy chọn cho completion
          },
        },
        presets = {
          bottom_search = true, -- Hiển thị tìm kiếm ở dưới
          command_palette = true, -- Giao diện command kiểu palette
          long_message_to_split = true, -- Chia nhỏ thông báo dài
          inc_rename = false, -- Tắt tính năng rename LSP mặc định nếu không cần
          lsp_doc_border = true, -- Thêm viền cho tài liệu LSP
        },
        -- Tùy chỉnh thông báo
        messages = {
          enabled = true, -- Bật thông báo
          view = "notify", -- Sử dụng nvim-notify để hiển thị
          view_error = "notify", -- Thông báo lỗi
          view_warn = "notify", -- Thông báo cảnh báo
        },
      })
    end,
  },
}

return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Phím tắt mới với <Leader> kết hợp phím Tab vật lý
    vim.keymap.set("n", "<Leader><Tab>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer", noremap = true, silent = true })
    vim.keymap.set("n", "<Leader><S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous Buffer", noremap = true, silent = true })
    vim.keymap.set("n", "<Leader>W", "<cmd>bd<CR>", { desc = "Close Buffer", noremap = true, silent = true })

    require("bufferline").setup({
      options = {
        numbers = "ordinal", -- Hiển thị số thứ tự buffer (1, 2, 3...)
        diagnostics = "nvim_lsp", -- Hiển thị thông tin LSP (nếu có)
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          local icon = level:match("error") and " " or " "
          return " " .. icon .. count
        end,
        separator_style = "slant", -- Kiểu phân cách giữa các tab
        show_buffer_close_icons = true, -- Hiển thị nút đóng buffer
        show_close_icon = false, -- Không hiển thị nút đóng toàn bộ bufferline
        always_show_bufferline = true, -- Luôn hiển thị bufferline
        enforce_regular_tabs = false, -- Không ép các tab đều nhau
        offsets = {
          { -- Đảm bảo bufferline không đè lên nvim-tree
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
            padding = 1,
          },
        },
      },
      highlights = { -- Tùy chỉnh màu sắc để đồng bộ với theme
        fill = {
          fg = { attribute = "fg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "StatusLineNonText" },
        },
        background = {
          fg = { attribute = "fg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "StatusLine" },
        },
        buffer_selected = {
          fg = { attribute = "fg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "Normal" },
          bold = true,
          italic = false,
        },
        separator = {
          fg = { attribute = "bg", highlight = "StatusLine" },
          bg = { attribute = "bg", highlight = "StatusLine" },
        },
        separator_selected = {
          fg = { attribute = "bg", highlight = "Normal" },
          bg = { attribute = "bg", highlight = "Normal" },
        },
      },
    })
  end,
}

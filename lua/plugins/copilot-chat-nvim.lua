return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  dependencies = {
    { "github/copilot.vim" },
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
  },
  config = function()
    -- Tắt gợi ý tự động của Copilot
    vim.g.copilot_enabled = false

    -- Cấu hình CopilotChat
    require("CopilotChat").setup({
      debug = false, -- Tắt debug để tránh in quá nhiều log
      show_help = true,
      window = {
        layout = "float", -- Sử dụng floating window
        width = 50, -- Chiều rộng cố định là 50 (giống NvimTree)
        height = 0.8, -- Chiều cao 80% màn hình
        title = '',
        relative = "editor", -- Đặt khung chat tương đối với toàn bộ editor
        row = 0, -- Vị trí dòng bắt đầu (top)
        col = vim.o.columns - 50, -- Vị trí cột bắt đầu (bên phải, tránh NvimTree)
        style = "minimal", -- Kiểu khung chat tối giản
        border = "rounded", -- Viền bo tròn
        zindex = 50, -- Đảm bảo khung chat hiển thị trên cùng
        focusable = true,
        noautocmd = false,
      },
      auto_follow_cursor = false,
      question_header = 'My',
      answer_header = 'Copilot',
    })

    -- Thay đổi màu nền của khung chat thành xám nhạt
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#3b4252" }) -- Màu nền xám nhạt
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#81a1c1", bg = "#3b4252" }) -- Màu viền và nền

    -- Thêm phím tắt để mở khung chat
    vim.api.nvim_set_keymap("n", "<leader>cc", ":CopilotChat<CR>", {
      noremap = true,
      silent = true,
      desc = "Mở khung chat Copilot"
    })
  end,
}

return {
  {
    "benlubas/molten-nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Cấu hình Molten
      vim.g.molten_auto_open_output = false        -- Tắt cửa sổ output thủ công
      vim.g.molten_virt_text_output = true         -- Hiển thị kết quả dạng virtual text
      vim.g.molten_virt_lines = true               -- Dùng virtual lines để hiển thị inline
      vim.g.molten_output_virt_lines = true        -- Đảm bảo output luôn hiển thị dưới dạng virtual lines
      vim.g.molten_wrap_output = true              -- Wrap text nếu dài
      vim.g.molten_virt_lines_off_by_1 = false     -- Đảm bảo output nằm ngay dưới dòng mã
      vim.g.molten_image_provider = "image.nvim"   -- Sử dụng image.nvim cho hình ảnh

      -- Tăng kích thước khung output (dành cho virtual lines)
      vim.g.molten_virt_lines_height = 20          -- Tăng chiều cao tối đa của virtual lines (mặc định nhỏ hơn)

      -- Đường dẫn Python cụ thể
      local python_path = vim.fn.expand("~/.python_envs/global_env/bin/python")
      
      -- Hàm khởi tạo kernel với Python tùy chỉnh
      local function init_molten_global_env()
        local install_cmd = python_path .. " -m ipykernel install --user --name=global_env_python"
        vim.fn.system(install_cmd)
        vim.cmd("MoltenInit global_env_python")
        print("Molten đã khởi tạo với global_env_python")
      end

      -- Phím tắt với mô tả tiếng Việt
      vim.keymap.set("n", "<leader>mi", init_molten_global_env, { desc = "Khởi tạo Molten với Python" })
      vim.keymap.set("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { desc = "Chạy đoạn mã được chọn" })
      vim.keymap.set("v", "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>", { desc = "Chạy vùng mã được bôi đen" })
      vim.keymap.set("n", "<leader>md", ":MoltenDeinit<CR>", { desc = "Tắt Molten" })
      vim.keymap.set("n", "<leader>mr", ":MoltenReevaluateCell<CR>", { desc = "Chạy lại ô mã hiện tại" })
      vim.keymap.set("n", "<leader>mc", ":MoltenClearOutputs<CR>", { desc = "Xóa toàn bộ output" })
    end,
  },
  {
    "3rd/image.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("image").setup({
        backend = "kitty", -- Terminal hỗ trợ ảnh
        integrations = {
          markdown = { enabled = true },
          neorg = { enabled = true },
        },
        max_width = 200,   -- Tăng chiều rộng tối đa của ảnh (đơn vị là ký tự)
        max_height = 24,   -- Tăng chiều cao tối đa của ảnh (đơn vị là dòng)
        max_width_window_percentage = 80,  -- Giới hạn chiều rộng theo phần trăm cửa sổ
        max_height_window_percentage = 50, -- Giới hạn chiều cao theo phần trăm cửa sổ
      })
    end,
  },
}

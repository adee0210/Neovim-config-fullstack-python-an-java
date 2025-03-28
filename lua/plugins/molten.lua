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
      vim.g.molten_virt_lines_height = 40         -- Tăng chiều cao tối đa của virtual lines
      -- Đặt màu output thành trắng cho virtual text
      vim.api.nvim_set_hl(0, "MoltenVirtualText", { fg = "#E0E0E0" })  -- Màu trắng cho output

      -- Đường dẫn Python cụ thể
      local python_path = vim.fn.expand("~/.python_envs/global_env/bin/python")
      
      -- Thêm PATH để dùng Jupyter từ môi trường ảo
      vim.env.PATH = vim.fn.expand("~/.python_envs/global_env/bin") .. ":" .. vim.env.PATH

      -- Hàm khởi tạo kernel Python
      local function init_molten_python()
        local install_cmd = python_path .. " -m ipykernel install --user --name=global_env_python"
        vim.fn.system(install_cmd)
        vim.cmd("MoltenInit global_env_python")
        print("Molten đã khởi tạo với global_env_python")
      end

      -- Hàm khởi tạo kernel R
      local function init_molten_r()
        vim.fn.jobstart("Rscript -e 'library(IRkernel)'", {
          on_exit = function(_, code)
            if code == 0 then
              vim.fn.jobstart("Rscript -e 'IRkernel::installspec()'", {
                on_exit = function(_, spec_code)
                  if spec_code == 0 then
                    vim.schedule(function()
                      vim.cmd("MoltenInit ir")
                      print("Molten đã khởi tạo với kernel R")
                    end)
                  else
                    vim.notify("Lỗi khi đăng ký kernel R. Chạy 'Rscript -e \"IRkernel::installspec()\"' trong terminal.", vim.log.levels.ERROR)
                  end
                end,
              })
            else
              vim.notify("IRkernel chưa cài đặt, đang cài...", vim.log.levels.INFO)
              vim.fn.jobstart("Rscript -e 'install.packages(\"IRkernel\", repos=\"https://cloud.r-project.org\")'", {
                on_exit = function(_, install_code)
                  if install_code == 0 then
                    vim.fn.jobstart("Rscript -e 'IRkernel::installspec()'", {
                      on_exit = function(_, spec_code)
                        if spec_code == 0 then
                          vim.schedule(function()
                            vim.cmd("MoltenInit ir")
                            print("Molten đã khởi tạo với kernel R")
                          end)
                        else
                          vim.notify("Lỗi khi đăng ký kernel R sau cài đặt.", vim.log.levels.ERROR)
                        end
                      end,
                    })
                  else
                    vim.notify("Lỗi khi cài đặt IRkernel. Chạy 'Rscript -e \"install.packages(\\\"IRkernel\\\", repos=\\\"https://cloud.r-project.org\\\")\"' trong terminal.", vim.log.levels.ERROR)
                  end
                end,
              })
            end
          end,
        })
      end

      -- Phím tắt với mô tả tiếng Việt
      vim.keymap.set("n", "<leader>mp", init_molten_python, { desc = "Khởi tạo Molten với Python" })
      vim.keymap.set("n", "<leader>mR", init_molten_r, { desc = "Khởi tạo Molten với R" })
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

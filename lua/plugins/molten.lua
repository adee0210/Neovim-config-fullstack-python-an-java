return {
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        lazy = false,
        dependencies = { "3rd/image.nvim" },
        config = function()
            -- Cấu hình Molten
            vim.g.molten_auto_open_output = true -- Tự động mở output
            vim.g.molten_wrap_output = true -- Wrap output nếu quá dài
            vim.g.molten_virt_text_output = false -- Không hiển thị output dạng virtual text
            vim.g.molten_output_win_border = { " ", "", " ", " " } -- Viền cửa sổ output
            vim.g.molten_output_win_max_height = 50 -- Chiều cao tối đa
            vim.g.molten_output_win_max_width = 200 -- Chiều rộng tối đa
            vim.g.molten_image_provider = "image.nvim" -- Sử dụng image.nvim cho hình ảnh
            vim.g.molten_output_show_more = true -- Hiển thị thêm output nếu có (không ẩn)

            -- Đảm bảo output không bị đóng khi rời block
            vim.g.molten_auto_close_output = false -- Ngăn tự động đóng output (nếu plugin hỗ trợ)

            -- Tắt highlight khi trỏ tới block
            vim.g.molten_highlight_output = false -- Tắt hiệu ứng sáng output (nếu plugin hỗ trợ)

            -- Cấu hình image.nvim
            local python_path = vim.fn.expand("~/.python_envs/global_env/bin/python")
            require("image").setup({
                backend = "kitty",
                max_width = 200, -- Chiều rộng tối đa của ảnh
                max_height = 50, -- Chiều cao tối đa của ảnh
            })

            -- Keymaps
            local keymap = vim.keymap.set
            keymap("n", "<leader>mi", function()
                local result = vim.fn.system(python_path .. " -m ipykernel install --user --name=global_env_python")
                if vim.v.shell_error ~= 0 then
                    print("Lỗi khi đăng ký kernel: " .. result)
                    return
                else
                    print("Kernel 'global_env_python' đã sẵn sàng.")
                end

                local success, err = pcall(function()
                    vim.cmd("MoltenInit global_env_python")
                end)
                if success then
                    print("Molten kernel 'global_env_python' đã được khởi tạo.")
                else
                    print("Lỗi khi chạy :MoltenInit: " .. err)
                end
            end, { desc = "Khởi tạo kernel Molten" })
            keymap("n", "<leader>me", ":MoltenEvaluateOperator<CR>", { desc = "Chạy mã dưới con trỏ" })
            keymap("v", "<leader>me", ":<C-u>MoltenEvaluateVisual<CR>", { desc = "Chạy đoạn mã được chọn" })
            keymap("n", "<leader>md", ":MoltenDeinit<CR>", { desc = "Tắt kernel Molten" })
        end,
    },
    {
        "3rd/image.nvim",
        config = function()
            require("image").setup()
        end,
    },
}

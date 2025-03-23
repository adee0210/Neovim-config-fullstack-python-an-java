return {
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        lazy = false, -- Tải ngay lập tức
        config = function()
            -- Cấu hình các biến toàn cục của molten-nvim
            vim.g.molten_auto_open_output = true
            vim.g.molten_wrap_output = true
            vim.g.molten_virt_text_output = true
            vim.g.molten_output_win_border = {" ", "", " ", " "}
            vim.g.molten_output_win_max_height = 20

            -- Đường dẫn Python tùy chỉnh
            local python_path = vim.fn.expand("~/.python_envs/global_env/bin/python")

            -- Gán phím tắt cho molten-nvim
            local keymap = vim.keymap.set
            keymap("n", "<leader>mi", function()
                -- Đăng ký kernel (nếu cần)
                local result = vim.fn.system(python_path .. " -m ipykernel install --user --name=global_env_python")
                if vim.v.shell_error ~= 0 then
                    print("Lỗi khi đăng ký kernel: " .. result)
                    return
                else
                    print("Kernel 'global_env_python' đã sẵn sàng.")
                end

                -- Khởi tạo kernel và bắt lỗi
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
}

return {
    {
        "benlubas/molten-nvim",
        build = ":UpdateRemotePlugins",
        lazy = false,
        dependencies = { "3rd/image.nvim" },
        config = function()
            vim.g.molten_auto_open_output = true
            vim.g.molten_wrap_output = true
            vim.g.molten_virt_text_output = true
            vim.g.molten_output_win_border = { " ", "", " ", " " }
            vim.g.molten_output_win_max_height = 50 -- Tăng chiều cao tối đa
            vim.g.molten_output_win_max_width = 200 -- Thêm chiều rộng tối đa
            vim.g.molten_image_provider = "image.nvim"

            local python_path = vim.fn.expand("~/.python_envs/global_env/bin/python")

            require("image").setup({
                backend = "kitty",
                max_width = 200, -- Tăng chiều rộng tối đa của ảnh
                max_height = 50, -- Tăng chiều cao tối đa của ảnh
            })

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

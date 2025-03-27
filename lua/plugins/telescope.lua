return {
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.8',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            -- Lấy quyền truy cập vào các chức năng có sẵn của Telescope
            local builtin = require('telescope.builtin')

            -- Thiết lập phím tắt trong Vim để tìm kiếm tệp theo tên
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Tìm kiếm tệp" })

            -- Thiết lập phím tắt trong Vim để tìm kiếm tệp dựa trên nội dung của chúng
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Tìm kiếm bằng Grep" })

            -- Thiết lập phím tắt trong Vim để tìm kiếm các mã lỗi trong dự án hiện tại
            vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { desc = "Tìm kiếm lỗi mã" })

            -- Thiết lập phím tắt trong Vim để tiếp tục tìm kiếm lần trước
            vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = "Tiếp tục tìm kiếm trước" })

            -- Thiết lập phím tắt trong Vim để tìm kiếm các tệp đã mở gần đây
            vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = "Tìm kiếm tệp gần đây" })

            -- Thiết lập phím tắt trong Vim để tìm kiếm các bộ đệm đã mở
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Tìm kiếm buffer đang mở" })

            -- Thiết lập phím tắt để tìm kiếm thư mục
            vim.keymap.set('n', '<leader>fd', function()
                require('telescope.builtin').find_files({
                    prompt_title = 'Find Directories',                                         -- Tiêu đề tìm kiếm
                    find_command = { 'find', '.', '-type', 'd', '-not', '-path', '*/.git/*' }, -- Chỉ tìm thư mục, không bao gồm thư mục .git
                })
            end, { desc = "Tìm kiếm thư mục" })
        end
    },
    {
        'nvim-telescope/telescope-ui-select.nvim',
        config = function()
            -- Cấu hình Telescope với các extension
            require("telescope").setup({
                -- Sử dụng ui-select dropdown làm giao diện người dùng
                extensions = {
                    ["ui-select"] = {
                        -- Lấy chủ đề dropdown mặc định cho ui-select
                        require("telescope.themes").get_dropdown {}
                    },
                }
            })

            -- Đăng ký extension ui-select với Telescope
            require("telescope").load_extension("ui-select")
        end
    }
}

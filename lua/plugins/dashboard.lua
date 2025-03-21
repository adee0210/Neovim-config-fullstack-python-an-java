return {
    'nvimdev/dashboard-nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local dashboard = require('dashboard')

        -- Hàm tạo footer với thứ, ngày tháng năm
        local function get_footer()
            local datetime = os.date("%A, %d/%m/%Y")
            return { "📅 " .. datetime }
        end

        -- Hàm kiểm tra và dùng fd nếu có, fallback về find
        local function find_directories()
            local has_fd = vim.fn.executable("fd") == 1
            if has_fd then
                require("telescope.builtin").find_files({
                    prompt_title = "Find Directories",
                    find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
                    cwd = vim.fn.getcwd(),
                })
            else
                require("telescope.builtin").find_files({
                    prompt_title = "Find Directories",
                    find_command = { "find", vim.fn.getcwd(), "-type", "d", "-not", "-path", "*/.git/*" },
                })
            end
        end

        -- Cấu hình dashboard
        dashboard.setup({
            theme = 'doom',
            config = {
                header = {
                    "",
                    "",
                    "",
                    "",
                    " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
                    " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
                    " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
                    " ██║╚██╗██║ ██╔==╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
                    " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
                    " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
                    "",
                    "",
                    "    Welcome to Neovim 🔥🔥🔥🦖",
                    "",
                    "",
                },
                center = {
                    { desc = '📂 Tạo và mở thư mục mới', group = '@string', 
                      action = 'lua local path = vim.fn.input("Nhập đường dẫn thư mục mới: ", "", "file"); if path ~= "" then vim.fn.mkdir(path, "p"); vim.cmd("edit " .. path); vim.cmd("redraw"); vim.cmd("echo \'Đã tạo và mở thư mục: " .. path .. "\'"); else vim.cmd("echo \'Không có đường dẫn được nhập\'"); end', key = 'm' },
                    { desc = '📁 Tạo file mới', group = '@string', action = 'enew', key = 'n' },
                    { desc = '📂 Mở thư mục cấu hình', group = '@string', action = 'lua vim.cmd("lcd ~/.config/nvim | edit .")', key = 'c' },
                    { desc = '🔎📂 Tìm thư mục', group = '@string', action = find_directories, key = 'd' },
                    { desc = '🔎🖹 Tìm file', group = '@string', action = 'Telescope find_files', key = 'f' },
                    { desc = '🖹 Tìm từ', group = '@string', action = 'Telescope live_grep', key = 'g' },
                    { desc = '👋 Thoát', group = '@string', action = 'qa', key = 'q' },
                },
                footer = get_footer(),
                disable_move = true, -- Ngăn di chuyển con trỏ
                hide = {
                    statusline = false,
                    tabline = false,
                    winbar = false,
                },
            },
            shortcut_type = 'letter',
        })

        -- Hàm để khóa cuộn dashboard
        local function lock_dashboard_scrolling()
            vim.opt_local.wrap = false
            vim.opt_local.scrolloff = 0
            vim.opt_local.sidescrolloff = 0
            vim.opt_local.scrollbind = false
            vim.opt_local.buflisted = false
            vim.g.original_mouse = vim.opt.mouse:get() or "a"
            vim.opt.mouse = "" -- Tắt chuột trong dashboard
            vim.opt_local.modifiable = false -- Ngăn chỉnh sửa buffer
            vim.opt_local.buftype = "nofile" -- Đảm bảo buffer không phải file thông thường
        end

        -- Áp dụng khóa cuộn khi mở dashboard
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "dashboard",
            callback = function()
                lock_dashboard_scrolling()
            end,
        })

        -- Khôi phục mouse khi rời dashboard
        vim.api.nvim_create_autocmd("BufLeave", {
            pattern = "*",
            callback = function()
                if vim.bo.filetype == "dashboard" then
                    vim.opt.mouse = vim.g.original_mouse or "a"
                end
            end,
        })

        -- Xử lý khi quay lại dashboard từ Telescope
        vim.api.nvim_create_autocmd("BufEnter", {
            pattern = "*",
            callback = function()
                if vim.bo.filetype == "dashboard" then
                    lock_dashboard_scrolling()
                end
            end,
        })

        -- Keymap để quay lại dashboard
        vim.keymap.set('n', '<leader>bda', function()
            local tree_api = pcall(require, 'nvim-tree.api')
            if tree_api then
                require('nvim-tree.api').tree.close()
            end
            vim.cmd('Dashboard')
            vim.cmd('lcd ' .. vim.fn.expand('~'))
            if vim.bo.filetype == "dashboard" then
                lock_dashboard_scrolling()
            end
        end, { noremap = true, silent = true, desc = 'Mở lại Dashboard' })
    end,
}

return {
    'nvimdev/dashboard-nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local dashboard = require('dashboard')

        -- Định nghĩa nhóm highlight
        vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#FF69B4', bold = true }) -- Màu hồng cho footer
        vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#FFFFFF' }) -- Màu trắng cho desc
        vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#FF69B4', bold = true }) -- Màu hồng cho icon
        vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#87CEEB', bold = true }) -- Màu xanh dương nhạt cho key

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
                    { icon = '📂 ', desc = 'Tạo và mở thư mục mới', group = 'DashboardDesc', key = 'm' , 
                      action = 'lua local path = vim.fn.input("Nhập đường dẫn thư mục mới: ", "", "file"); if path ~= "" then vim.fn.mkdir(path, "p"); vim.cmd("edit " .. path); vim.cmd("redraw"); vim.cmd("echo \'Đã tạo và mở thư mục: " .. path .. "\'"); else vim.cmd("echo \'Không có đường dẫn được nhập\'"); end' },
                    { icon = '📁 ', desc = 'Tạo file mới', group = 'DashboardDesc', action = 'enew', key = 'n' },
                    { icon = '📂 ', desc = 'Mở thư mục cấu hình', group = 'DashboardDesc', action = 'lua vim.cmd("lcd ~/.config/nvim | edit .")', key = 'c' },
                    { icon = '🔎📂 ', desc = 'Tìm thư mục', group = 'DashboardDesc', action = find_directories, key = 'd' },
                    { icon = '🔎🖹 ', desc = 'Tìm file', group = 'DashboardDesc', action = 'Telescope find_files', key = 'f' },
                    { icon = '🖹 ', desc = 'Tìm từ', group = 'DashboardDesc', action = 'Telescope live_grep', key = 'g' },
                    { icon = '👋 ', desc = 'Thoát', group = 'DashboardDesc', action = 'qa', key = 'q' },
                },
                footer = get_footer(),
                disable_move = true,
                hide = {
                    statusline = false,
                    tabline = false,
                    winbar = false,
                },
            },
            shortcut_type = 'letter',
        })

        -- Áp dụng highlight cho footer và center
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "dashboard",
            callback = function()
                -- Highlight footer
                vim.api.nvim_buf_add_highlight(0, -1, 'DashboardFooter', vim.fn.line('$') - 1, 0, -1)
                -- Highlight center (icon, desc, và key riêng)
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                for i, line in ipairs(lines) do
                    if line:match('^%S+%s+.*%s%[.%]') then -- Dòng có icon, desc, và key
                        local icon_end = line:find('%s') or 0
                        local key_start = line:find('%[.%]') - 1 or -1
                        local key_end = key_start + 3 -- [q] dài 3 ký tự
                        vim.api.nvim_buf_add_highlight(0, -1, 'DashboardIcon', i - 1, 0, icon_end)
                        vim.api.nvim_buf_add_highlight(0, -1, 'DashboardDesc', i - 1, icon_end, key_start)
                        vim.api.nvim_buf_add_highlight(0, -1, 'DashboardKey', i - 1, key_start, key_end)
                    end
                end
            end,
        })

        -- Hàm để khóa cuộn dashboard
        local function lock_dashboard_scrolling()
            vim.opt_local.wrap = false
            vim.opt_local.scrolloff = 0
            vim.opt_local.sidescrolloff = 0
            vim.opt_local.scrollbind = false
            vim.opt_local.buflisted = false
            vim.g.original_mouse = vim.opt.mouse:get() or "a"
            vim.opt.mouse = ""
            vim.opt_local.modifiable = false
            vim.opt_local.buftype = "nofile"
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

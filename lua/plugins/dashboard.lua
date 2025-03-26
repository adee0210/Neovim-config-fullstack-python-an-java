return {
    'nvimdev/dashboard-nvim',
    lazy = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local dashboard = require('dashboard')

        -- Định nghĩa nhóm highlight
        vim.api.nvim_set_hl(0, 'DashboardFooter', { fg = '#FF69B4', bold = true })
        vim.api.nvim_set_hl(0, 'DashboardDesc', { fg = '#FFFFFF' })
        vim.api.nvim_set_hl(0, 'DashboardIcon', { fg = '#FF69B4', bold = true })
        vim.api.nvim_set_hl(0, 'DashboardKey', { fg = '#87CEEB', bold = true })

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

        -- Hàm để tắt bufferline và toggleterm khi mở dashboard
        local function hide_ui_elements()
            if pcall(require, 'bufferline') then
                vim.g.bufferline_enabled = false
                vim.api.nvim_set_hl(0, 'BufferLineFill', { bg = 'NONE' })
            end
            if pcall(require, 'toggleterm') then
                local terms = require('toggleterm.terminal').get_all()
                for _, term in ipairs(terms) do
                    term:shutdown()
                end
            end
            vim.opt.showtabline = 0
            vim.opt.laststatus = 0
            vim.opt.winbar = ''
        end

        -- Hàm để khôi phục UI khi rời dashboard
        local function restore_ui_elements()
            if pcall(require, 'bufferline') then
                vim.g.bufferline_enabled = true
                vim.cmd('redrawtabline')
            end
            vim.opt.showtabline = 2
            vim.opt.laststatus = 2
        end

        -- Hàm tạo file hoặc thư mục mới với kiểm tra tồn tại
        local function create_file_or_directory()
            local current_dir = vim.fn.getcwd() .. "/"
            local input = vim.fn.input("Nhập tên file hoặc thư mục (thư mục kết thúc bằng /): ", current_dir, "file")
            if input == "" then
                vim.cmd("echo 'Không có đường dẫn được nhập'")
                return
            end

            local exists = vim.fn.filereadable(input) == 1 or vim.fn.isdirectory(input) == 1
            if exists then
                vim.cmd("redraw")
                vim.cmd("echo 'Đường dẫn đã tồn tại: " .. input .. "'")
            else
                if input:sub(-1) == "/" then
                    vim.fn.mkdir(input, "p")
                    vim.cmd("edit " .. input)
                    vim.cmd("redraw")
                    vim.cmd("echo 'Đã tạo và mở thư mục: " .. input .. "'")
                else
                    vim.cmd("edit " .. input)
                    vim.cmd("redraw")
                    vim.cmd("echo 'Đã tạo và mở file: " .. input .. "'")
                end
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
                    { icon = '📄 ', desc = 'Tạo file/thư mục mới', group = 'DashboardDesc', key = 'm', action = create_file_or_directory },
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
                vim.api.nvim_buf_add_highlight(0, -1, 'DashboardFooter', vim.fn.line('$') - 1, 0, -1)
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                for i, line in ipairs(lines) do
                    if line:match('^%S+%s+.*%s%[.%]') then
                        local icon_end = line:find('%s') or 0
                        local key_start = line:find('%[.%]') - 1 or -1
                        local key_end = key_start + 3
                        vim.api.nvim_buf_add_highlight(0, -1, 'DashboardIcon', i - 1, 0, icon_end)
                        vim.api.nvim_buf_add_highlight(0, -1, 'DashboardDesc', i - 1, icon_end, key_start)
                        vim.api.nvim_buf_add_highlight(0, -1, 'DashboardKey', i - 1, key_start, key_end)
                    end
                end
            end,
        })

        -- Hàm để khóa cuộn dashboard và tắt UI
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
            hide_ui_elements()
        end

        -- Áp dụng khóa cuộn và tắt UI khi mở dashboard
        vim.api.nvim_create_autocmd("FileType", {
            pattern = "dashboard",
            callback = function()
                lock_dashboard_scrolling()
            end,
        })

        -- Khởi động Neovim với dashboard
        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                vim.cmd('Dashboard')
                lock_dashboard_scrolling()
            end,
        })

        -- Khôi phục UI khi rời dashboard
        vim.api.nvim_create_autocmd("BufLeave", {
            pattern = "*",
            callback = function()
                if vim.bo.filetype == "dashboard" then
                    vim.opt.mouse = vim.g.original_mouse or "a"
                    restore_ui_elements()
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

        -- Lệnh :Dba để mở dashboard
        vim.api.nvim_create_user_command('Dba', function()
            local tree_api = pcall(require, 'nvim-tree.api')
            if tree_api then
                require('nvim-tree.api').tree.close()
            end
            vim.cmd('Dashboard')
            vim.cmd('lcd ' .. vim.fn.expand('~'))
            if vim.bo.filetype == "dashboard" then
                lock_dashboard_scrolling()
            end
        end, { desc = 'Mở Dashboard và tắt bufferline, toggleterm' })
    end,
}

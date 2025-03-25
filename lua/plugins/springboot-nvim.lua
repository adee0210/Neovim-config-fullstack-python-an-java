return {
    "elmcgill/springboot-nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-jdtls",
        "akinsho/toggleterm.nvim", -- Thêm dependency cho toggleterm
    },
    config = function()
        local springboot_nvim = require("springboot-nvim")
        local Terminal = require("toggleterm.terminal").Terminal

        -- Hàm kiểm tra loại dự án (Maven hay Gradle)
        local function get_project_type()
            local root_dir = vim.fn.getcwd()
            if vim.fn.filereadable(root_dir .. "/build.gradle") == 1 or vim.fn.filereadable(root_dir .. "/build.gradle.kts") == 1 then
                return "gradle"
            elseif vim.fn.filereadable(root_dir .. "/pom.xml") == 1 then
                return "maven"
            else
                return nil
            end
        end

        -- Hàm chạy Spring Boot trong toggleterm
        local spring_term = nil -- Biến để lưu terminal instance

        local function boot_run()
            local project_type = get_project_type()
            local cmd
            if project_type == "gradle" then
                cmd = "./gradlew bootRun"
            elseif project_type == "maven" then
                cmd = "mvn spring-boot:run"
            else
                vim.notify("No Spring Boot project detected (missing build.gradle or pom.xml)", vim.log.levels.ERROR)
                return
            end

            -- Nếu terminal đã tồn tại, đóng nó trước khi tạo mới
            if spring_term then
                spring_term:shutdown()
            end

            -- Tạo terminal nhỏ gọn
            spring_term = Terminal:new({
                cmd = cmd,
                direction = "horizontal",  -- Terminal mở dưới dạng split ngang
                size = 15,                 -- Chiều cao 15 dòng (có thể điều chỉnh)
                close_on_exit = false,     -- Không tự đóng khi lệnh hoàn tất
                on_open = function(term)
                    vim.cmd("startinsert") -- Bắt đầu ở chế độ insert
                end,
                on_exit = function(term, job, exit_code, name)
                    if exit_code ~= 0 then
                        vim.notify("Spring Boot terminated with exit code: " .. exit_code, vim.log.levels.ERROR)
                    end
                    -- Không đặt spring_term = nil để bạn tự quản lý việc tắt
                end,
            })
            spring_term:toggle() -- Mở hoặc đóng terminal
        end

        -- Thiết lập phím tắt
        vim.keymap.set('n', '<leader>jr', boot_run, { desc = "Java Run Spring Boot" })
        vim.keymap.set('n', '<leader>jc', springboot_nvim.generate_class, { desc = "Java Create Class" })
        vim.keymap.set('n', '<leader>ji', springboot_nvim.generate_interface, { desc = "Java Create Interface" })
        vim.keymap.set('n', '<leader>je', springboot_nvim.generate_enum, { desc = "Java Create Enum" })

        -- Thiết lập plugin với cấu hình mặc định
        springboot_nvim.setup({
            lsp_server = "jdtls",
        })
    end,
}

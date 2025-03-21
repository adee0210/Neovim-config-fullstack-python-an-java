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
                end,
            })
            spring_term:toggle() -- Mở hoặc đóng terminal
        end

        -- Hàm đóng terminal thủ công
        local function close_spring_term()
            if spring_term then
                spring_term:shutdown()
                spring_term = nil
                vim.notify("Spring Boot terminal closed", vim.log.levels.INFO)
            else
                vim.notify("No Spring Boot terminal to close", vim.log.levels.WARN)
            end
        end

        -- Thiết lập phím tắt
        vim.keymap.set('n', '<leader>Jr', boot_run, { desc = "Java Run Spring Boot" })
        vim.keymap.set('n', '<leader>Jx', close_spring_term, { desc = "Java Exit Spring Boot Terminal" })
        vim.keymap.set('n', '<leader>Jc', springboot_nvim.generate_class, { desc = "Java Create Class" })
        vim.keymap.set('n', '<leader>Ji', springboot_nvim.generate_interface, { desc = "Java Create Interface" })
        vim.keymap.set('n', '<leader>Je', springboot_nvim.generate_enum, { desc = "Java Create Enum" })

        -- Thiết lập plugin với cấu hình mặc định
        springboot_nvim.setup({
            lsp_server = "jdtls",
        })
    end,
}

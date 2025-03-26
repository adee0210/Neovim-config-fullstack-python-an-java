return {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    config = function()
        -- Cấu hình plugin Jupytext
        require("jupytext").setup({
            style = "markdown",
            output_extension = "md",
            force_ft = "markdown",
        })
        
        -- Kiểm tra và xác nhận đường dẫn
        local function get_valid_path(path)
            if vim.fn.executable(path) == 1 then
                return path
            end
            return nil
        end

        -- Hàm chuyển đổi Markdown sang IPython Notebook
        local function convert_to_ipynb()
            -- Kiểm tra file hiện tại
            local current_file = vim.fn.expand("%:p")
            if current_file == "" then
                vim.notify("Không có file nào đang mở hoặc file chưa được lưu!", vim.log.levels.ERROR)
                return
            end

            -- Kiểm tra extension
            if not current_file:match("%.md$") then
                vim.notify("File hiện tại không phải định dạng .md: " .. current_file, vim.log.levels.ERROR)
                return
            end

            -- Tự động lưu file
            if vim.api.nvim_buf_get_option(0, 'modified') then
                vim.cmd("write")
                vim.notify("Đã tự động lưu file trước khi chuyển đổi", vim.log.levels.INFO)
            end

            -- Xác định đường dẫn
            local jupytext_path = get_valid_path(vim.fn.expand("~/.python_envs/global_env/bin/jupytext"))
            if not jupytext_path then
                -- Thử tìm jupytext trong PATH
                jupytext_path = get_valid_path("jupytext")
                if not jupytext_path then
                    vim.notify("Không tìm thấy jupytext! Vui lòng cài đặt trước.", vim.log.levels.ERROR)
                    return
                end
            end

            -- Tạo tên file đầu ra
            local ipynb_file = current_file:gsub("%.md$", ".ipynb")
            
            -- Xây dựng lệnh
            local cmd = string.format("%s --from md --to ipynb '%s' -o '%s' --set-kernel global_env_python", 
                                     jupytext_path, current_file, ipynb_file)
            
            -- Thực thi với xử lý lỗi
            local handle = io.popen(cmd .. " 2>&1")
            local output = handle:read("*a")
            handle:close()

            if output:match("Writing") or output:match("success") then
                vim.notify("✅ Đã chuyển đổi thành công sang file: " .. ipynb_file, vim.log.levels.INFO)
            else
                vim.notify("❌ Lỗi khi chuyển đổi: " .. output:gsub("\n", " "), vim.log.levels.ERROR)
            end
        end

        -- Gán keybinding
        vim.keymap.set("n", "<leader>mip", convert_to_ipynb, {
            noremap = true,
            silent = false,
            desc = "Chuyển đổi Markdown sang IPython Notebook"
        })
    end,
}

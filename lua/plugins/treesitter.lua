return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        -- ts-autotag sử dụng treesitter để hiểu cấu trúc mã và tự động đóng thẻ trong tsx
        "windwp/nvim-ts-autotag"
    },
    -- khi plugin được xây dựng, chạy lệnh TSUpdate để đảm bảo tất cả các server của chúng ta được cài đặt và cập nhật
    build = ':TSUpdate',
    config = function()
        -- truy cập các chức năng cấu hình của treesitter
        local ts_config = require("nvim-treesitter.configs")

        -- gọi hàm thiết lập treesitter với các thuộc tính để cấu hình trải nghiệm của chúng ta
        ts_config.setup({
            -- đảm bảo rằng chúng ta có các server tô màu cho vim, vimdoc, lua, java, javascript, typescript, html, css, json, tsx, markdown, markdown_inline và gitignore
            ensure_installed = {"vim", "vimdoc", "lua", "java", "javascript", "typescript", "html", "css", "json", "tsx", "markdown", "markdown_inline", "gitignore"},
            -- đảm bảo rằng tính năng tô màu được bật
            highlight = {enable = true},
            -- bật tính năng tự động đóng thẻ trong tsx
            autotag = {
                enable = true
            }
        })
    end
}


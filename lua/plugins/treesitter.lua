return {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    build = ":TSUpdate",
    config = function()
        local ts_config = require("nvim-treesitter.configs")
        ts_config.setup({
            -- Thêm "r" vào danh sách
            ensure_installed = {
                "vim",
                "vimdoc",
                "lua",
                "java",
                "javascript",
                "typescript",
                "html",
                "css",
                "json",
                "tsx",
                "markdown",
                "markdown_inline",
                "gitignore",
                "python", -- Parser cho Python
                "r",     -- Thêm parser cho R
            },
            highlight = {
                enable = true,
                -- Tắt highlighting mặc định của Vim để tránh xung đột
                additional_vim_regex_highlighting = false,
            },
            autotag = {
                enable = true,
            },
        })
    end,
}

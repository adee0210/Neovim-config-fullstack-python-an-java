return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            size = 15, -- Kích thước mặc định (15 dòng nếu ngang, 15 cột nếu dọc)
            open_mapping = [[<c-\>]], -- Phím tắt mở/đóng terminal chung (Ctrl + \)
            hide_numbers = true,
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            persist_size = true,
            direction = "horizontal", -- Mặc định mở split ngang
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
                border = "curved",
                winblend = 3,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                },
            },
        })
    end,
}

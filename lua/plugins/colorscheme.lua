-- /home/duc/.config/nvim/lua/plugins.lua
return {
    -- Plugin Onedark (Colorscheme)
    {
        "navarasu/onedark.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("onedark").setup({
                style = "dark",
                transparent = true,
                term_colors = true,
                ending_tildes = false,
                cmp_itemkind_reverse = false,
                code_style = {
                    comments = "italic",
                    keywords = "none",
                    functions = "none",
                    strings = "none",
                    variables = "none",
                },
                diagnostics = {
                    darker = true,
                    undercurl = true,
                    background = true,
                },
                colors = {},
                highlights = {},
            })
            vim.cmd.colorscheme "onedark"
        end,
    },

    -- Plugin nvim-web-devicons
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                default = true,
            })
        end,
    },

    -- Gọi colorscheme.lua (chứa bufferline.nvim)
    require("plugins.bufferline"),
}

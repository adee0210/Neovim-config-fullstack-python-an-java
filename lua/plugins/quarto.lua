return {
    "quarto-dev/quarto-nvim",
    lazy = false,
    ft = { "quarto", "markdown" },
    dev = false,
    config = function()
        require("quarto").setup({
            lspFeatures = {
                languages = { "python", "r" },  -- CHỈ THÊM "r" VÀO ĐÂY
                chunks = "all",
                diagnostics = {
                    enabled = true,
                    triggers = { "BufWritePost" },
                },
                completion = {
                    enabled = true,
                },
            },
            keymap = {
                hover = "H",
                definition = "gd",
                rename = "<leader>rn",
                references = "gr",
                format = "<leader>gf",
            },
            codeRunner = {
                enabled = true,
                default_method = "molten",
            },
        })
        -- Kích hoạt otter khi mở .md hoặc .qmd
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "markdown", "quarto" },
            callback = function()
                if pcall(require, "nvim-treesitter.parsers") then
                    require("otter").activate({ "python", "r" })  -- VÀ THÊM "r" VÀO ĐÂY
                else
                    print("Treesitter not available, otter activation skipped")
                end
            end,
        })
    end,
    dependencies = {
        "jmbuhr/otter.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
}

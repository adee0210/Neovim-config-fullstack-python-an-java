return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" }, -- Lazy load khi mở file
        config = function()
            require("gitsigns").setup({
                signs = {
                    add = { text = "│" },          -- Dấu thêm dòng
                    change = { text = "│" },       -- Dấu thay đổi
                    delete = { text = "_" },       -- Dấu xóa dòng
                    topdelete = { text = "‾" },    -- Dấu xóa đầu
                    changedelete = { text = "~" }, -- Dấu thay đổi + xóa
                },
                signcolumn = true,           -- Hiển thị dấu hiệu trên gutter
                numhl = false,               -- Không tô sáng số dòng
                linehl = false,              -- Không tô sáng toàn dòng
                word_diff = false,           -- Không bật diff từng từ
                current_line_blame = true,   -- Hiển thị blame inline cho dòng hiện tại
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = "eol",   -- Đặt blame ở cuối dòng
                    delay = 300,             -- Trễ 300ms để tránh nhấp nháy
                },
                preview_config = {
                    border = "rounded",      -- Viền bo tròn cho preview
                    style = "minimal",
                    relative = "cursor",
                },
                on_attach = function(bufnr)
                    local gs = package.loaded.gitsigns
                    local opts = { buffer = bufnr, desc = "" }

                    -- Phím tắt cho gitsigns
                    opts.desc = "[G]it Xem trước [H]unk"
                    vim.keymap.set("n", "<leader>gh", gs.preview_hunk, opts)

                    opts.desc = "[G]it Reset [H]unk"
                    vim.keymap.set("n", "<leader>gr", gs.reset_hunk, opts)

                    opts.desc = "[G]it Stage [H]unk"
                    vim.keymap.set("n", "<leader>gs", gs.stage_hunk, opts)

                    opts.desc = "[G]it [B]lame Line"
                    vim.keymap.set("n", "<leader>gb", gs.blame_line, opts)
                end,
            })
        end,
    },
    {
        "tpope/vim-fugitive",
        event = { "BufReadPre", "BufNewFile" }, -- Lazy load khi mở file
        config = function()
            -- Phím tắt cho vim-fugitive
            vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "[G]it [B]lame (Xem lịch sử đóng góp)" })
            vim.keymap.set("n", "<leader>gA", ":Git add .<CR>", { desc = "[G]it Thêm [A]ll (Tất cả file)" })
            vim.keymap.set("n", "<leader>ga", ":Git add %<CR>", { desc = "[G]it [A]dd (Thêm file hiện tại)" })
            vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "[G]it [C]ommit (Tạo commit)" })
            vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "[G]it [P]ush (Đẩy commit lên remote)" })
            vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "[G]it [S]tatus (Xem trạng thái)" })
        end,
    },
}

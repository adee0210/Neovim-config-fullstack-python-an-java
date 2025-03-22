return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "BufReadPost",
    config = function()
        require("bufferline").setup({
            options = {
                mode = "buffers",
                numbers = "none",
                close_command = "bdelete! %d",
                right_mouse_command = "bdelete! %d",
                diagnostics = "nvim_lsp",
                diagnostics_indicator = function(count, level)
                    local icon = level:match("error") and " " or " "
                    return " " .. icon .. count
                end,
                offsets = {
                    { filetype = "NvimTree", text = "File Explorer", highlight = "Directory", padding = 1 },
                },
                show_buffer_icons = true,
                show_buffer_close_icons = true,
                separator_style = "slant",
                always_show_bufferline = true,
                hover = {
                    enabled = true,
                    delay = 200,
                    reveal = { "close" },
                },
            },
            highlights = {
                fill = { bg = "#1E2A3C" },
                background = { bg = "#1E2A3C" },
                tab = { bg = "#1E2A3C" },
                tab_selected = { bg = "#4A4A4A", fg = "#FFFFFF" },
                buffer = { bg = "#1E2A3C" },
                buffer_visible = { bg = "#2F3E5C" },
                buffer_selected = { bg = "#4A4A4A", fg = "#FFFFFF", bold = true },
                separator = { fg = "#1E2A3C", bg = "#1E2A3C" },
                separator_selected = { fg = "#4A4A4A", bg = "#4A90E2" },
            },
        })
        vim.opt.cmdheight = 1

        local function close_current_buffer()
            local current_buf = vim.api.nvim_get_current_buf()
            if vim.bo[current_buf].filetype == "NvimTree" then return end

            local bufs = vim.tbl_filter(function(buf)
                return vim.api.nvim_buf_is_loaded(buf)
                    and buf ~= current_buf
                    and vim.bo[buf].filetype ~= "NvimTree"
                    and vim.bo[buf].buflisted
            end, vim.api.nvim_list_bufs())

            if #bufs > 0 then
                vim.api.nvim_set_current_buf(bufs[1])
                vim.api.nvim_buf_delete(current_buf, { force = true })
            else
                vim.api.nvim_buf_delete(current_buf, { force = true })
                vim.cmd("enew")
            end
        end

        vim.keymap.set("n", "<leader><Tab>", ":BufferLineCycleNext<CR>",
            { noremap = true, silent = true, desc = "Chuyển sang buffer tiếp theo" })
        vim.keymap.set("n", "<leader><S-Tab>", ":BufferLineCyclePrev<CR>",
            { noremap = true, silent = true, desc = "Chuyển sang buffer trước đó" })
        vim.keymap.set("n", "<leader>W", close_current_buffer,
            { noremap = true, silent = true, desc = "Đóng buffer hiện tại" })
    end,
}

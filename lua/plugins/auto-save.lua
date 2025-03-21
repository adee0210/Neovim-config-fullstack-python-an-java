return {
    "okuuva/auto-save.nvim",
    version = "*",
    event = { "BufLeave", "FocusLost", "VimLeavePre" },
    dependencies = { "stevearc/conform.nvim" },
    opts = {
        enabled = true,
        trigger_events = {
            immediate_save = { "BufLeave", "FocusLost", "VimLeavePre" },
            defer_save = {},
        },
        cancel_deferred_save = {},
        write_all_buffers = true,
        debounce_delay = 0,
        noautocmd = true,
        lockmarks = false,
        debug = true,
        execution_function = function()
            local ok, conform = pcall(require, "conform")
            if ok then
                -- Format trước khi lưu
                conform.format({ async = false, lsp_fallback = true })
                if vim.g.auto_save_debug then
                    vim.notify("Formatted before saving", vim.log.levels.INFO)
                end
            else
                if vim.g.auto_save_debug then
                    vim.notify("Conform not loaded", vim.log.levels.ERROR)
                end
            end
            -- Lưu tất cả buffer
            local current_win = vim.api.nvim_get_current_win()
            vim.api.nvim_command("silent! wall")
            vim.api.nvim_set_current_win(current_win)
        end,
    },
    config = function(_, opts)
        require("auto-save").setup(opts)
        -- Autocommand cho VimLeavePre
        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                local ok, conform = pcall(require, "conform")
                if ok then
                    conform.format({ async = false, lsp_fallback = true })
                    if vim.g.auto_save_debug then
                        vim.notify("Formatted before exit", vim.log.levels.INFO)
                    end
                end
                vim.api.nvim_command("silent! wall")
            end,
        })
    end,
}

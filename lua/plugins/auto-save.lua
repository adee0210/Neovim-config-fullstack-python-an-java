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
        debug = false, -- Tắt debug để không hiện thông báo
        execution_function = function()
            local ok, conform = pcall(require, "conform")
            if ok then
                vim.api.nvim_command("silent! PyrightOrganizeImports")
                conform.format({ async = false, lsp_fallback = true })
            end
            local current_win = vim.api.nvim_get_current_win()
            vim.api.nvim_command("silent! wall")
            vim.api.nvim_set_current_win(current_win)
        end,
    },
    config = function(_, opts)
        require("auto-save").setup(opts)
        vim.api.nvim_create_autocmd("VimLeavePre", {
            callback = function()
                local ok, conform = pcall(require, "conform")
                if ok then
                    vim.api.nvim_command("silent! PyrightOrganizeImports")
                    conform.format({ async = false, lsp_fallback = true })
                end
                vim.api.nvim_command("silent! wall")
            end,
        })
    end,
}

return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle [E]xplorer", noremap = true, silent = true })

    require("nvim-tree").setup({
      hijack_netrw = true,
      auto_reload_on_write = true,
      view = {
        side = "right",
        width = 50, -- Chiều rộng cố định
        preserve_window_proportions = false, -- Tắt giữ tỷ lệ
        float = { enable = false }, -- Đảm bảo không dùng floating window
      },
      renderer = {
        indent_markers = { enable = false },
        icons = {
          glyphs = {
            default = "",
            symlink = "",
            git = {
              unstaged = "",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "",
              deleted = "",
              ignored = "◌",
            },
            folder = {
              arrow_open = "",
              arrow_closed = "",
              default = "",
              open = "",
              empty = "",
              empty_open = "",
              symlink = "",
              symlink_open = "",
            },
          },
          show = {
            file = true,
            folder = true,
            folder_arrow = true,
            git = true,
          },
        },
        highlight_git = true,
        root_folder_modifier = ":t",
        indent_width = 0.3,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = false, -- Tắt resize tự động
          window_picker = { enable = false },
        },
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        vim.keymap.set("n", "o", function()
          local node = api.tree.get_node_under_cursor()
          if node.nodes then
            api.node.open.edit()
          else
            vim.cmd("edit " .. vim.fn.fnameescape(node.absolute_path))
          end
        end, opts("Open file/folder"))

        api.config.mappings.default_on_attach(bufnr)

        -- Ép chiều rộng Nvim Tree luôn là 50
        local function fix_nvim_tree_width()
          for _, win in pairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win), "filetype") == "NvimTree" then
              vim.api.nvim_win_set_width(win, 50)
            end
          end
        end

        -- Áp dụng sau mỗi thay đổi cửa sổ hoặc buffer
        vim.api.nvim_create_autocmd({"WinEnter", "BufEnter", "WinResized", "WinNew"}, {
          callback = fix_nvim_tree_width,
          group = vim.api.nvim_create_augroup("NvimTreeFixedWidth", { clear = true }),
        })
      end,
    })

    -- Khóa chiều rộng tối đa và tối thiểu của Nvim Tree
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NvimTree",
      callback = function()
        vim.api.nvim_win_set_option(0, "winfixwidth", true) -- Khóa chiều rộng cửa sổ
        vim.api.nvim_win_set_width(0, 50) -- Đặt lại chiều rộng là 50
      end,
    })
  end,
}

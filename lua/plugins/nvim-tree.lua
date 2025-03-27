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
        width = 50,
        preserve_window_proportions = false,
        float = { enable = false },
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
          resize_window = false,
          window_picker = { enable = false },
        },
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- Tùy chỉnh keymap "o" để mở file hoặc thư mục
        vim.keymap.set("n", "o", function()
          local node = api.tree.get_node_under_cursor()
          if node.nodes then
            api.node.open.edit()
          else
            vim.cmd("edit " .. vim.fn.fnameescape(node.absolute_path))
          end
        end, opts("Open file/folder"))

        -- Gán các mapping mặc định
        api.config.mappings.default_on_attach(bufnr)

        -- Thêm keymap để tự động mở rộng tất cả các thư mục
        vim.keymap.set("n", "<leader>a", api.tree.expand_all, opts("Expand All Folders"))

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

        -- Tự động mở rộng tất cả các thư mục khi mở nvim-tree
        api.tree.expand_all()
      end,
    })

    -- Khóa chiều rộng tối đa và tối thiểu của Nvim Tree
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NvimTree",
      callback = function()
        vim.api.nvim_win_set_option(0, "winfixwidth", true)
        vim.api.nvim_win_set_width(0, 50)
      end,
    })
  end,
}

-- ============================================================
--  plugins/navigation.lua — Telescope, Yazi, which-key
-- ============================================================

return {

  -- ── Telescope — fuzzy finder ────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    cmd          = "Telescope",
    version      = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond  = function() return vim.fn.executable("make") == 1 end,
      },
      "nvim-telescope/telescope-ui-select.nvim", -- LSP code actions use Telescope
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",                   desc = "Find files"        },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",                    desc = "Live grep"         },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",                      desc = "Buffers"           },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",                     desc = "Recent files"      },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>",                    desc = "Help tags"         },
      { "<leader>fc", "<cmd>Telescope grep_string<cr>",                  desc = "Find word under cursor" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>",         desc = "Document symbols"  },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>",        desc = "Workspace symbols" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>",                  desc = "Diagnostics"       },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",                      desc = "Keymaps"           },
      { "<leader>fp", "<cmd>Telescope projects<cr>",                     desc = "Projects"          },
      -- Git pickers
      { "<leader>gb", "<cmd>Telescope git_branches<cr>",                 desc = "Git branches"      },
      { "<leader>gs", "<cmd>Telescope git_status<cr>",                   desc = "Git status"        },
    },
    config = function()
      local telescope = require("telescope")
      local actions   = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix   = " ",
          selection_caret = " ",
          path_display    = { "smart" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            vertical   = { mirror = false },
            width      = 0.87,
            height     = 0.80,
            preview_cutoff = 120,
          },
          file_ignore_patterns = {
            "%.git/", "node_modules/", "%.cache/", "build/", "dist/",
            "%.class$", "%.jar$",  -- Java
            "%.o$", "%.elf$",      -- C / embedded binaries
            "__pycache__/", "%.pyc$",
          },
          mappings = {
            i = {
              ["<C-j>"]     = actions.move_selection_next,
              ["<C-k>"]     = actions.move_selection_previous,
              ["<C-q>"]     = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"]     = actions.close,
              ["<C-u>"]     = false, -- clear prompt (default is scroll)
              ["<C-d>"]     = actions.delete_buffer,
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy                   = true,
            override_generic_sorter = true,
            override_file_sorter    = true,
            case_mode               = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  -- ── Yazi — file manager inside Neovim ───────────────────
  -- Press  -  or  <leader>yy  to open Yazi at the current file.
  -- Files you open in Yazi land directly in Neovim buffers.
  -- Requires yazi to be installed: https://yazi-rs.github.io
  {
    "mikavilpas/yazi.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "e",            "<cmd>Yazi<cr>",         desc = "Open Yazi (current file)" },
      { "<leader>e",    "<cmd>Yazi<cr>",          desc = "Open Yazi (current file)" },
      { "<leader>ew",   "<cmd>Yazi cwd<cr>",      desc = "Open Yazi (cwd)" },
      { "<leader>er",   "<cmd>Yazi toggle<cr>",   desc = "Resume last Yazi session" },
    },
    opts = {
      open_for_directories = true,  -- replaces netrw for directory opens
      keymaps = {
        show_help         = "<F1>",
        open_file_in_tab  = "<C-t>",
        open_file_in_vertical_split = "<C-v>",
        open_file_in_horizontal_split = "<C-x>",
      },
    },
  },

  -- ── which-key — keymap cheat-sheet popup ────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts  = {
      plugins = { spelling = { enabled = true, suggestions = 20 } },
      win     = { border = "rounded", padding = { 2, 2, 2, 2 } },
      layout  = { align = "center" },
      spec = {
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Conflict resolve (Diffview)" },
        { "<leader>d", group = "Diagnostics" },
        { "<leader>f", group = "Find / Telescope" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Hunks (gitsigns)" },
        { "<leader>j", group = "Java (jdtls)" },
        { "<leader>l", group = "LSP" },
        { "<leader>r", group = "Rename" },
        { "<leader>s", group = "Swap (treesitter)" },
        { "<leader>t", group = "Terminal" },
        { "e", group = "Yazi (file manager)" },
      },
    },
  },
}

-- ============================================================
--  plugins/git.lua — Lazygit, Diffview (merge conflicts), Gitsigns
-- ============================================================

return {

  -- ── Lazygit ─────────────────────────────────────────────
  {
    "kdheepak/lazygit.nvim",
    cmd          = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>",                  desc = "LazyGit" },
      { "<leader>gG", "<cmd>LazyGitCurrentFile<cr>",       desc = "LazyGit (current file)" },
    },
    config = function()
      vim.g.lazygit_floating_window_winblend = 0
      vim.g.lazygit_floating_window_scaling_factor = 0.9
      vim.g.lazygit_floating_window_border_chars = { "╭","─","╮","│","╯","─","╰","│" }
      vim.g.lazygit_use_neovim_remote = 0 -- set to 1 if you have neovim-remote installed
    end,
  },

  -- ── Diffview — 3-way merge editor & history viewer ──────
  -- Usage:
  --   <leader>gd  → open diff against HEAD (file-by-file)
  --   <leader>gh  → full file history (log + diff)
  --   <leader>gm  → open merge conflict resolver (3-way split)
  --   <leader>gc  → close Diffview panel
  --
  -- Inside the merge view:
  --   ]x / [x     → jump to next/prev conflict hunk
  --   <leader>co  → choose OURS   (left panel)
  --   <leader>ct  → choose THEIRS (right panel)
  --   <leader>cb  → choose BOTH   (ours then theirs)
  --   <leader>cB  → choose BOTH   (theirs then ours)
  --   <leader>cn  → choose NONE   (delete the hunk)
  --   <leader>cO  → choose all OURS   in file
  --   <leader>cT  → choose all THEIRS in file
  --   dp          → diff-put hunk from editor to result
  --   do          → diff-obtain hunk into editor
  --   gf          → open file in previous tab
  {
    "sindrets/diffview.nvim",
    cmd          = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory",
                     "DiffviewToggleFiles", "DiffviewFocusFiles" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",                     desc = "Diffview: diff HEAD" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>",            desc = "Diffview: file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>",              desc = "Diffview: repo history" },
      { "<leader>gm", "<cmd>DiffviewOpen -uno<cr>",                desc = "Diffview: merge conflicts" },
      { "<leader>gc", "<cmd>DiffviewClose<cr>",                    desc = "Diffview: close" },
    },
    config = function()
      local actions = require("diffview.actions")

      require("diffview").setup({
        enhanced_diff_hl  = true,  -- improved conflict highlighting
        use_icons         = true,
        show_help_hints   = true,
        watch_index       = true,  -- auto-refresh when git index changes

        -- Keymaps active inside Diffview panels
        keymaps = {
          disable_defaults = false,

          view = {
            -- Conflict resolution (3-way merge view)
            { "n", "<leader>co", actions.conflict_choose("ours"),         { desc = "Choose OURS" }   },
            { "n", "<leader>ct", actions.conflict_choose("theirs"),       { desc = "Choose THEIRS" } },
            { "n", "<leader>cb", actions.conflict_choose("base"),         { desc = "Choose BASE" }   },
            { "n", "<leader>cB", actions.conflict_choose("all"),          { desc = "Choose BOTH" }   },
            { "n", "<leader>cn", actions.conflict_choose("none"),         { desc = "Delete conflict hunk" } },
            { "n", "<leader>cO", actions.conflict_choose_all("ours"),     { desc = "Choose all OURS" }   },
            { "n", "<leader>cT", actions.conflict_choose_all("theirs"),   { desc = "Choose all THEIRS" } },
            { "n", "<leader>cA", actions.conflict_choose_all("all"),      { desc = "Choose all BOTH" }   },
            { "n", "<leader>cN", actions.conflict_choose_all("none"),     { desc = "Delete all conflicts" } },
            -- Navigate conflicts
            { "n", "]x",         actions.next_conflict,                   { desc = "Next conflict" }     },
            { "n", "[x",         actions.prev_conflict,                   { desc = "Prev conflict" }     },
            -- Toggle file panel
            { "n", "<leader>fp", actions.toggle_files,                    { desc = "Toggle file panel" } },
          },

          file_panel = {
            { "n", "j",           actions.next_entry,           { desc = "Next file" }         },
            { "n", "k",           actions.prev_entry,           { desc = "Prev file" }         },
            { "n", "<cr>",        actions.select_entry,         { desc = "Open file" }         },
            { "n", "s",           actions.toggle_stage_entry,   { desc = "Stage / unstage" }   },
            { "n", "S",           actions.stage_all,            { desc = "Stage all" }         },
            { "n", "U",           actions.unstage_all,          { desc = "Unstage all" }       },
            { "n", "X",           actions.restore_entry,        { desc = "Restore file" }      },
            { "n", "R",           actions.refresh_files,        { desc = "Refresh" }           },
            { "n", "q",           "<cmd>DiffviewClose<cr>",     { desc = "Close Diffview" }    },
          },

          file_history_panel = {
            { "n", "j",   actions.next_entry,    { desc = "Next commit" }  },
            { "n", "k",   actions.prev_entry,    { desc = "Prev commit" }  },
            { "n", "<cr>",actions.select_entry,  { desc = "Open diff" }    },
            { "n", "y",   actions.copy_hash,     { desc = "Copy hash" }    },
            { "n", "q",   "<cmd>DiffviewClose<cr>", { desc = "Close" }     },
          },
        },

        hooks = {
          -- After opening the merge view, notify the user
          diff_buf_read = function(bufnr)
            if vim.bo[bufnr].filetype == "DiffviewMergeEditor" then
              vim.notify(
                "Merge conflicts loaded.\n]x / [x to navigate · <leader>co/ct/cb to resolve",
                vim.log.levels.INFO, { title = "Diffview" }
              )
            end
          end,
        },
      })
    end,
  },

  -- ── Gitsigns — inline git blame, hunk preview & staging ─
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts  = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "" },
        topdelete    = { text = "" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      signcolumn   = true,
      current_line_blame = false, -- toggle with <leader>gb
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = vim.tbl_extend("force", { buffer = bufnr }, opts or {})
          vim.keymap.set(mode, l, r, opts)
        end

        -- Hunk navigation
        map("n", "]h", function()
          if vim.wo.diff then return "]h" end
          vim.schedule(gs.next_hunk)
          return "<Ignore>"
        end, { expr = true, desc = "Next hunk" })

        map("n", "[h", function()
          if vim.wo.diff then return "[h" end
          vim.schedule(gs.prev_hunk)
          return "<Ignore>"
        end, { expr = true, desc = "Prev hunk" })

        -- Stage / reset hunks
        map({ "n", "v" }, "<leader>hs", gs.stage_hunk,       { desc = "Stage hunk"   })
        map({ "n", "v" }, "<leader>hr", gs.reset_hunk,       { desc = "Reset hunk"   })
        map("n",          "<leader>hS", gs.stage_buffer,     { desc = "Stage buffer" })
        map("n",          "<leader>hR", gs.reset_buffer,     { desc = "Reset buffer" })
        map("n",          "<leader>hu", gs.undo_stage_hunk,  { desc = "Undo stage hunk" })
        map("n",          "<leader>hp", gs.preview_hunk,     { desc = "Preview hunk" })

        -- Blame
        map("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle git blame" })
        map("n", "<leader>gB", function() gs.blame_line({ full = true }) end, { desc = "Blame line (full)" })

        -- Diff
        map("n", "<leader>hd", gs.diffthis,                  { desc = "Diff this" })
        map("n", "<leader>hD", function() gs.diffthis("~") end, { desc = "Diff this ~" })

        -- Text objects: ih = inner hunk
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", { desc = "Inner hunk" })
      end,
    },
  },
}

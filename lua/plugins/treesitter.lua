-- ============================================================
--  plugins/treesitter.lua — Syntax highlighting & text objects
--
--  Rewritten for nvim-treesitter's new main-branch API (a full,
--  incompatible rewrite upstream — see the plugin's own README).
--  The old ensure_installed/auto_install/highlight.enable/indent.enable
--  keys are silently ignored by the new .setup() (which only accepts
--  install_dir) -- confirmed live: zero parsers were actually installed
--  under the old-style config below, despite no errors at all. Java
--  dropped from the language list (Java support removed entirely).
-- ============================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- af, if, ac, ic, ...
    },
    config = function()
      require("nvim-treesitter").setup({})

      local ensure_installed = {
        -- Your languages
        "python", "c", "cpp", "sql", "php", "nasm",
        -- Config / tooling
        "lua", "vim", "vimdoc", "query",
        -- Common extras
        "bash", "regex", "json", "yaml", "toml", "markdown", "markdown_inline",
        "cmake", "make",
      }
      local installed = require("nvim-treesitter.config").get_installed()
      local to_install = vim.tbl_filter(function(lang)
        return not vim.list_contains(installed, lang)
      end, ensure_installed)
      if #to_install > 0 then
        require("nvim-treesitter").install(to_install)
      end

      -- Highlighting: no longer a .setup() option, enabled per-buffer.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- Indent: same, wired via indentexpr instead of a .setup() option.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "python", "c", "cpp", "sql", "php", "lua", "markdown" },
        callback = function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    config = function()
      -- Also the new API: select/move/swap config via .setup(), but
      -- keymaps are wired individually — no more nested `keymaps = {...}`
      -- table.
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      local sel = function(q)
        return function() select.select_textobject(q, "textobjects") end
      end
      vim.keymap.set({ "x", "o" }, "af", sel("@function.outer"), { desc = "Outer function" })
      vim.keymap.set({ "x", "o" }, "if", sel("@function.inner"), { desc = "Inner function" })
      vim.keymap.set({ "x", "o" }, "ac", sel("@class.outer"), { desc = "Outer class" })
      vim.keymap.set({ "x", "o" }, "ic", sel("@class.inner"), { desc = "Inner class" })
      vim.keymap.set({ "x", "o" }, "aa", sel("@parameter.outer"), { desc = "Outer argument" })
      vim.keymap.set({ "x", "o" }, "ia", sel("@parameter.inner"), { desc = "Inner argument" })
      vim.keymap.set({ "x", "o" }, "ab", sel("@block.outer"), { desc = "Outer block" })
      vim.keymap.set({ "x", "o" }, "ib", sel("@block.inner"), { desc = "Inner block" })

      local nextStart = function(q)
        return function() move.goto_next_start(q, "textobjects") end
      end
      local nextEnd = function(q)
        return function() move.goto_next_end(q, "textobjects") end
      end
      local prevStart = function(q)
        return function() move.goto_previous_start(q, "textobjects") end
      end
      local prevEnd = function(q)
        return function() move.goto_previous_end(q, "textobjects") end
      end
      vim.keymap.set({ "n", "x", "o" }, "]f", nextStart("@function.outer"), { desc = "Next function start" })
      vim.keymap.set({ "n", "x", "o" }, "]c", nextStart("@class.outer"), { desc = "Next class start" })
      vim.keymap.set({ "n", "x", "o" }, "]F", nextEnd("@function.outer"), { desc = "Next function end" })
      vim.keymap.set({ "n", "x", "o" }, "]C", nextEnd("@class.outer"), { desc = "Next class end" })
      vim.keymap.set({ "n", "x", "o" }, "[f", prevStart("@function.outer"), { desc = "Previous function start" })
      vim.keymap.set({ "n", "x", "o" }, "[c", prevStart("@class.outer"), { desc = "Previous class start" })
      vim.keymap.set({ "n", "x", "o" }, "[F", prevEnd("@function.outer"), { desc = "Previous function end" })
      vim.keymap.set({ "n", "x", "o" }, "[C", prevEnd("@class.outer"), { desc = "Previous class end" })

      vim.keymap.set("n", "<leader>sp", function() swap.swap_next("@parameter.inner") end, { desc = "Swap next argument" })
      vim.keymap.set("n", "<leader>sP", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap previous argument" })
    end,
  },
}

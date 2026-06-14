-- ============================================================
--  plugins/treesitter.lua — Syntax highlighting & text objects
-- ============================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy   = false,
    build  = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- af, if, ac, ic, ...
    },
    config = function()
      require("nvim-treesitter.config").setup({

        ensure_installed = {
          -- Your languages
          "python", "c", "cpp", "java", "sql", "php",
          -- Config / tooling
          "lua", "vim", "vimdoc", "query",
          -- Common extras
          "bash", "regex", "json", "yaml", "toml", "markdown", "markdown_inline",
          "cmake", "make",
        },

        auto_install = true,
        highlight    = { enable = true },
        indent       = { enable = true },

        -- ── Text objects ────────────────────────────────────
        -- Adds motion targets: af = outer function, if = inner function
        -- ac = outer class, ic = inner class, etc.
        textobjects = {
          select = {
            enable    = true,
            lookahead = true,  -- automatically jump forward to the next text object
            keymaps = {
              ["af"] = { query = "@function.outer", desc = "Outer function" },
              ["if"] = { query = "@function.inner", desc = "Inner function" },
              ["ac"] = { query = "@class.outer",    desc = "Outer class"    },
              ["ic"] = { query = "@class.inner",    desc = "Inner class"    },
              ["aa"] = { query = "@parameter.outer",desc = "Outer argument" },
              ["ia"] = { query = "@parameter.inner",desc = "Inner argument" },
              ["ab"] = { query = "@block.outer",    desc = "Outer block"    },
              ["ib"] = { query = "@block.inner",    desc = "Inner block"    },
            },
          },

          move = {
            enable              = true,
            set_jumps           = true,  -- adds to jumplist
            goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_next_end       = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
            goto_previous_end   = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
          },

          swap = {
            enable = true,
            swap_next     = { ["<leader>sp"] = "@parameter.inner" },
            swap_previous = { ["<leader>sP"] = "@parameter.inner" },
          },
        },
      })
    end,
  },
}

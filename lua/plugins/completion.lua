-- ============================================================
--  plugins/completion.lua — nvim-cmp + LuaSnip
-- ============================================================

return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      -- Sources
      "hrsh7th/cmp-nvim-lsp",       -- LSP completions
      "hrsh7th/cmp-buffer",          -- words in current buffer
      "hrsh7th/cmp-path",            -- filesystem paths
      "hrsh7th/cmp-cmdline",         -- : and / command line
      "hrsh7th/cmp-nvim-lsp-signature-help",

      -- Snippet engine
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build   = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" }, -- pre-built snippet library
        config = function()
          -- Load VSCode-style snippets (friendly-snippets)
          require("luasnip.loaders.from_vscode").lazy_load()
          -- Load any custom snippets from ~/.config/nvim/snippets/
          require("luasnip.loaders.from_vscode").lazy_load({
            paths = { vim.fn.stdpath("config") .. "/snippets" }
          })
        end,
      },
      "saadparwaiz1/cmp_luasnip",   -- LuaSnip ↔ cmp bridge
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      -- Helper: checks if there's a word before cursor (for <Tab> behaviour)
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0
          and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },

        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = false }), -- only confirm explicit selection

          -- Tab: expand snippet → navigate snippet → cycle cmp → indent
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp",               priority = 1000 },
          { name = "nvim_lsp_signature_help",priority = 900  },
          { name = "luasnip",                priority = 750  },
          { name = "buffer",                 priority = 500,
            option = { keyword_length = 3 } },
          { name = "path",                   priority = 250  },
        }),

        formatting = {
          format = function(entry, vim_item)
            -- Source label shown on the right
            local source_names = {
              nvim_lsp  = "[LSP]",
              luasnip   = "[Snip]",
              buffer    = "[Buf]",
              path      = "[Path]",
            }
            vim_item.menu = source_names[entry.source.name] or ""
            return vim_item
          end,
        },

        experimental = { ghost_text = true }, -- inline preview of first suggestion
      })

      -- ── Cmdline completion (/search and :commands) ────────
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
      })
    end,
  },
}

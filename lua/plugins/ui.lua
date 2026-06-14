-- ============================================================
--  plugins/ui.lua — Colorscheme, statusline, bufferline,
--                   notifications, indent guides, and more
--
--  Theme pipeline:
--    Matugen reads matugen-template.lua, substitutes Noctalia v4
--    colour tokens, and writes matugen.lua.  nvim-base16 loads
--    that palette at startup.  A SIGUSR1 handler (autocmd.lua)
--    reloads the theme in running instances without a restart.
-- ============================================================

return {

  -- ── Colorscheme: nvim-base16 + Matugen/Noctalia ─────────
  --
  --  How it works:
  --    1. Matugen writes ~/.config/nvim/lua/matugen.lua
  --       (base16 hex table, no leading #) from matugen-template.lua
  --    2. This plugin reads that table and applies it as a
  --       base16 colorscheme at startup.
  --    3. When Matugen regenerates (e.g. on wallpaper change) it
  --       sends SIGUSR1 to all nvim processes — the autocmd in
  --       config/autocmds.lua catches it and calls reload_theme().
  --
  --  First run:  matugen image /path/to/noctalia-wallpaper.png
  --  Manual:     matugen color "#1a1b26"
  --  Re-apply:   <leader>tr  (see keymaps below)
  {
    "RRethy/nvim-base16",
    name     = "nvim-base16",
    priority = 1000,
    config = function()
      -- ── Apply Matugen theme ─────────────────────────────
      local ok, matugen = pcall(require, "matugen")
      if ok then
        matugen.setup()
      else
        vim.notify(
          "matugen.lua not found — run `matugen image <wallpaper>` to generate it.\n"
          .. "Using built-in Noctalia v4 fallback.",
          vim.log.levels.WARN,
          { title = "Theme" }
        )
        require("base16-colorscheme").setup({
          base00 = "#1a1b2e", base01 = "#1f2040", base02 = "#2a2b4a", base03 = "#565f89",
          base04 = "#787c9e", base05 = "#a9b1d6", base06 = "#c0caf5", base07 = "#cdd6f4",
          base08 = "#f7768e", base09 = "#ff9e64", base0A = "#e0af68", base0B = "#9ece6a",
          base0C = "#73daca", base0D = "#7aa2f7", base0E = "#bb9af7", base0F = "#db4b4b",
        })
      end

      local function get_palette()
        local ok2, m = pcall(require, "matugen")
        if ok2 and type(m.get_palette) == "function" then
          return m.get_palette()
        end
        return nil
      end

      -- ── Extra highlights not covered by base16 ──────────
      local function set_extra_highlights(c)
        if not c then return end

        local hi = function(group, opts)
          vim.api.nvim_set_hl(0, group, opts)
        end

        -- Telescope
        hi("TelescopeBorder",        { fg = c.base02 })
        hi("TelescopePromptBorder",  { fg = c.base0D })
        hi("TelescopeResultsBorder", { fg = c.base02 })
        hi("TelescopePreviewBorder", { fg = c.base02 })
        hi("TelescopeSelection",     { bg = c.base02, fg = c.base06, bold = true })
        hi("TelescopeMatching",      { fg = c.base0D, bold = true })

        -- Diffview conflict markers
        hi("DiffviewConflictMarker", { fg = c.base09, bold = true })
        hi("DiffAdd", { bg = c.base0B:gsub("#(..)(..)(..)", function(r,g,b)
          return "#" .. string.format("%02x%02x%02x",
            tonumber(r,16)*0.15, tonumber(g,16)*0.15, tonumber(b,16)*0.15)
        end) })
        hi("DiffDelete", { fg = c.base08 })
        hi("DiffChange", { bg = c.base01 })
        hi("DiffText",   { bg = c.base02, fg = c.base0A, bold = true })

        -- LSP diagnostics
        hi("DiagnosticVirtualTextError", { fg = c.base08, italic = true })
        hi("DiagnosticVirtualTextWarn",  { fg = c.base0A, italic = true })
        hi("DiagnosticVirtualTextInfo",  { fg = c.base0D, italic = true })
        hi("DiagnosticVirtualTextHint",  { fg = c.base0C, italic = true })

        -- Indent blankline scope
        hi("IblScope",   { fg = c.base0E, nocombine = true })

        -- Which-key
        hi("WhichKeyBorder", { fg = c.base02 })
        hi("WhichKey",       { fg = c.base0D })
        hi("WhichKeyGroup",  { fg = c.base0E })

        -- Noice cmdline
        hi("NoiceCmdlinePopupBorder", { fg = c.base0D })

        -- Gitsigns
        hi("GitSignsAdd",    { fg = c.base0B })
        hi("GitSignsChange", { fg = c.base0A })
        hi("GitSignsDelete", { fg = c.base08 })

        -- Floating windows
        hi("FloatBorder", { fg = c.base02, bg = c.base00 })
        hi("NormalFloat", { bg = c.base01 })
      end

      set_extra_highlights(get_palette())

      -- Keymap for manual reload
      vim.keymap.set("n", "<leader>tr", function()
        package.loaded["matugen"] = nil
        local ok3, m = pcall(require, "matugen")
        if ok3 then
          m.setup()
          set_extra_highlights(m.get_palette())
          local ok4, lualine = pcall(require, "lualine")
          if ok4 then
            lualine.setup({ options = { theme = _G.build_lualine_theme() } })
          end
          vim.notify("Theme reloaded from matugen.lua", vim.log.levels.INFO, { title = "Theme" })
        else
          vim.notify("matugen.lua missing — run matugen first", vim.log.levels.ERROR, { title = "Theme" })
        end
      end, { desc = "Reload Matugen theme" })
    end,
  },

  -- ── Lualine — statusline ─────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event        = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Build a lualine theme dynamically from the live base16 palette.
      -- Exposed as _G.build_lualine_theme() so reload_theme() can call it.
      _G.build_lualine_theme = function()
        local ok, m = pcall(require, "matugen")
        if not ok or type(m.get_palette) ~= "function" then return "auto" end
        local p = m.get_palette()
        return {
          normal   = {
            a = { fg = p.base00, bg = p.base0D, gui = "bold" },
            b = { fg = p.base05, bg = p.base02 },
            c = { fg = p.base04, bg = p.base01 },
          },
          insert   = { a = { fg = p.base00, bg = p.base0B, gui = "bold" } },
          visual   = { a = { fg = p.base00, bg = p.base0E, gui = "bold" } },
          replace  = { a = { fg = p.base00, bg = p.base08, gui = "bold" } },
          command  = { a = { fg = p.base00, bg = p.base0A, gui = "bold" } },
          inactive = {
            a = { fg = p.base03, bg = p.base01 },
            b = { fg = p.base03, bg = p.base01 },
            c = { fg = p.base03, bg = p.base00 },
          },
        }
      end

      require("lualine").setup({
        options = {
          theme                = _G.build_lualine_theme(),
          component_separators = { left = "|", right = "|" },
          section_separators   = { left = "", right = "" },
          globalstatus         = true,
          disabled_filetypes   = { statusline = { "dashboard", "alpha" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } },
          },
          lualine_x = {
            { "encoding" },
            { "fileformat" },
            { "filetype", icon_only = false },
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ── Bufferline — tab bar ─────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event        = "VeryLazy",
    version      = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        mode            = "buffers",
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons     = true,
        diagnostics     = "nvim_lsp",
        diagnostics_indicator = function(_, _, diagnostics_dict)
          local s = " "
          for e, n in pairs(diagnostics_dict) do
            local sym = e == "error" and " " or (e == "warning" and " " or "")
            s = s .. n .. sym
          end
          return s
        end,
        offsets = {
          { filetype = "neo-tree",   text = "Explorer",   highlight = "Directory", text_align = "left" },
        },
      },
    },
  },

  -- ── Indent guides ────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = { "BufReadPre", "BufNewFile" },
    opts  = {
      indent  = { char = "│", tab_char = "│" },
      scope   = { enabled = true, show_start = true, show_end = false },
      exclude = {
        filetypes = { "help", "dashboard", "lazy", "mason", "notify", "toggleterm" },
      },
    },
  },

  -- ── Noice — better cmdline, search, and notifications ───
  {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"]   = true,
        },
      },
      presets = {
        bottom_search        = true,  -- classic / at the bottom
        command_palette      = true,  -- position the cmdline and popupmenu together
        long_message_to_split = true, -- send long messages to a split
        inc_rename           = false,
        lsp_doc_border       = true,  -- add a border to hover docs and signature help
      },
      routes = {
        -- Suppress the "written" message on save
        { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
      },
    },
    keys = {
      { "<leader>nl", function() require("noice").cmd("last") end,    desc = "Noice: last message" },
      { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice: history" },
      { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Noice: dismiss" },
    },
  },

  -- ── nvim-notify (used by noice) ──────────────────────────
  {
    "rcarriga/nvim-notify",
    opts = {
      background_colour = "#000000",
      timeout           = 3000,
      render            = "compact",
      stages            = "fade",
      max_width         = 60,
    },
  },

  -- ── Dashboard — start screen ─────────────────────────────
  {
    "goolord/alpha-nvim",
    event        = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.buttons.val = {
        dashboard.button("f", "  Find file",    ":Telescope find_files <cr>"),
        dashboard.button("r", "  Recent files", ":Telescope oldfiles <cr>"),
        dashboard.button("g", "  Live grep",    ":Telescope live_grep <cr>"),
        dashboard.button("n", "  New file",     ":enew <BAR> startinsert <cr>"),
        dashboard.button("l", "  Lazy",         ":Lazy<cr>"),
        dashboard.button("q", "  Quit",         ":qa<cr>"),
      }
      require("alpha").setup(dashboard.config)
    end,
  },

  -- ── Icons (shared dependency) ───────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },
  { "echasnovski/mini.icons", lazy = true, opts = {} },

  -- ── Autopairs ────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts  = {
      check_ts        = true,    -- use treesitter to avoid pairing in strings/comments
      ts_config       = { lua = { "string" }, python = { "string" } },
      fast_wrap       = {
        map           = "<M-e>",  -- Alt-e to fast-wrap the word
        chars         = { "{", "[", "(", '"', "'" },
        pattern       = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset        = 0,
        end_key       = "$",
        keys          = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma   = true,
        highlight     = "PmenuSel",
        highlight_grey= "LineNr",
      },
    },
    config = function(_, opts)
      local npairs = require("nvim-autopairs")
      npairs.setup(opts)
      -- Integrate with nvim-cmp: add parentheses after function completion
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ── Toggleterm — floating/split terminal ─────────────────
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys    = {
      { "<C-\\>",     "<cmd>ToggleTerm<cr>",                       desc = "Toggle terminal" },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>",       desc = "Float terminal" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>",  desc = "Horizontal terminal" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>",    desc = "Vertical terminal" },
    },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then return 15
        elseif term.direction == "vertical" then return vim.o.columns * 0.4
        end
      end,
      open_mapping  = [[<C-\>]],
      shell         = vim.o.shell,
      float_opts    = { border = "curved", winblend = 0 },
      direction     = "float",
    },
  },

  -- ── Trouble — pretty diagnostics list ────────────────────
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd          = { "Trouble", "TroubleToggle" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",               desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",  desc = "Buffer diagnostics" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                    desc = "Location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                    desc = "Quickfix list" },
    },
    opts = { use_diagnostic_signs = true },
  },

  -- ── Comment.nvim — gcc / gc to comment ──────────────────
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts  = {
      -- Treesitter-aware context comments (jsx, embedded sql, etc.)
      pre_hook = function(ctx)
        local ok, ts_ctx = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
        if ok then return ts_ctx.create_pre_hook()(ctx) end
      end,
    },
  },

  -- Required for Comment.nvim treesitter context awareness
  { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },

  -- ── Surround — ys, cs, ds for surrounding pairs ──────────
  {
    "kylechui/nvim-surround",
    version = "*",
    event   = "VeryLazy",
    opts    = {},
  },

  -- ── Markdown inline preview (render-markdown) ──────────
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "norg", "rmd", "org" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}

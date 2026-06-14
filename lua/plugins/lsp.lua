-- ============================================================
--  plugins/lsp.lua — LSP, Mason, formatters & linters
--
--  Languages covered:
--    Python  → pyright (LSP) + ruff (lint/format)
--    C/C++   → clangd  (reads compile_commands.json)
--    Java    → nvim-jdtls (full-featured jdt.ls wrapper)
--    SQL     → sqls    (LSP with DB completion)
-- ============================================================

return {

  -- ── Mason: install & manage LSP servers ─────────────────
  {
    "williamboman/mason.nvim",
    cmd  = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        border = "rounded",
        icons  = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  -- ── Mason ↔ lspconfig bridge ────────────────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "pyright",   -- Python type checking
        "ruff",      -- Python formatting + linting
        "clangd",    -- C / C++
        "sqls",      -- SQL
        "phpactor",  -- PHP LSP
        -- jdtls is handled by nvim-jdtls below (not lspconfig)
      },
      automatic_installation = true,
    },
  },

  -- ── Core LSP config ─────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",        -- feeds LSP completions into nvim-cmp
    },
    config = function()
      -- ── Diagnostic signs & display ──────────────────────
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end
      vim.diagnostic.config({
        virtual_text   = { prefix = "●" },
        severity_sort  = true,
        float          = { border = "rounded", source = "always" },
        update_in_insert = false,
      })

      -- ── Register lspconfig server defaults ──────────────
      require("lspconfig")

      -- ── Shared on_attach: keymaps active only when LSP attaches ──
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        on_attach = function(client, bufnr)
          local nmap = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
          end
          nmap("gd",          vim.lsp.buf.definition,       "Go to definition")
          nmap("gD",          vim.lsp.buf.declaration,      "Go to declaration")
          nmap("gr",          "<cmd>Telescope lsp_references<cr>", "References")
          nmap("gi",          vim.lsp.buf.implementation,   "Go to implementation")
          nmap("K",           vim.lsp.buf.hover,            "Hover docs")
          nmap("<C-k>",       vim.lsp.buf.signature_help,   "Signature help")
          nmap("<leader>rn",  vim.lsp.buf.rename,           "Rename symbol")
          nmap("<leader>ca",  vim.lsp.buf.code_action,      "Code action")
          nmap("<leader>D",   vim.lsp.buf.type_definition,  "Type definition")
          nmap("<leader>lf",  function() vim.lsp.buf.format({ async = true }) end, "Format file")
          nmap("<leader>li",  "<cmd>LspInfo<cr>",           "LSP info")
          nmap("<leader>lr",  "<cmd>LspRestart<cr>",        "Restart LSP")
        end,
      })

      -- ── Python: ruff (formatting + linting) ────────────
      vim.lsp.config("ruff", {
        settings = {
          ruff = {
            lineLength = 100,
            format = { preview = true },
            lint = { preview = true },
          },
        },
      })

      -- ── Python: pyright ─────────────────────────────────
      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              typeCheckingMode      = "basic",
              autoSearchPaths       = true,
              useLibraryCodeForTypes = true,
              diagnosticMode        = "openFilesOnly",
            },
          },
        },
      })

      -- ── C / C++: clangd ─────────────────────────────────
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          -- Uncomment for cross-compilation (STM32 / ESP-IDF):
          -- "--query-driver=/path/to/arm-none-eabi-gcc",
          -- "--query-driver=/path/to/xtensa-esp32-elf-gcc",
        },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".git", "CMakeLists.txt" },
      })

      -- ── SQL: sqls ───────────────────────────────────────
      vim.lsp.config("sqls", {
        on_attach = function(client, bufnr)
          require("sqls").on_attach(client, bufnr)
        end,
      })

      -- ── Lua (for editing this config) ───────────────────
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            completion = { callSnippet = "Replace" },
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
          },
        },
      })

      -- ── PHP: phpactor ──────────────────────────────────
      vim.lsp.config("phpactor", {
        filetypes = { "php" },
        settings = {
          phpactor = {
            enable_register_command = true,
          },
        },
      })

      -- ── Enable all configured servers ──────────────────
      vim.lsp.enable({
        "pyright",
        "ruff",
        "clangd",
        "sqls",
        "lua_ls",
        "phpactor",
      })
    end,
  },

  -- ── Java: nvim-jdtls (replaces plain lspconfig for Java) ─
  -- Gives you: proper project detection, organize imports,
  -- test running, and DAP integration.
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local jdtls     = require("jdtls")
      local jdtls_dir = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
      local project   = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
      local workspace = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project

      local config = {
        cmd = {
          "java",
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Xms1g",
          "--add-modules=ALL-SYSTEM",
          "--add-opens", "java.base/java.util=ALL-UNNAMED",
          "--add-opens", "java.base/java.lang=ALL-UNNAMED",
          "-jar", vim.fn.glob(jdtls_dir .. "/plugins/org.eclipse.equinox.launcher_*.jar"),
          "-configuration", jdtls_dir .. "/config_linux",  -- change to config_mac or config_win
          "-data", workspace,
        },
        root_dir = jdtls.setup.find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
        settings = {
          java = {
            format          = { enabled = true },
            saveActions     = { organizeImports = true },
            completion      = { favoriteStaticMembers = {
              "org.junit.Assert.*", "org.junit.Assume.*",
              "org.junit.jupiter.api.Assertions.*",
            }},
            sources         = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
            codeGeneration  = { toString = { template = "${object.className}[${member.name()}=${member.value}, ${otherMembers}]" } },
          },
        },
        on_attach = function(_, bufnr)
          -- Standard LSP keymaps
          local nmap = function(k, f, d)
            vim.keymap.set("n", k, f, { buffer = bufnr, desc = "LSP: " .. d })
          end
          nmap("gd",         vim.lsp.buf.definition,        "Go to definition")
          nmap("gr",         "<cmd>Telescope lsp_references<cr>", "References")
          nmap("K",          vim.lsp.buf.hover,             "Hover docs")
          nmap("<leader>rn", vim.lsp.buf.rename,            "Rename")
          nmap("<leader>ca", vim.lsp.buf.code_action,       "Code action")
          nmap("<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Format")
          -- Java extras
          nmap("<leader>jo", jdtls.organize_imports,        "Organize imports")
          nmap("<leader>jt", jdtls.test_nearest_method,     "Test nearest method")
          nmap("<leader>jT", jdtls.test_class,              "Test class")
          nmap("<leader>ju", "<cmd>JdtUpdateConfig<cr>",    "Update jdtls config")
        end,
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern  = "java",
        callback = function() jdtls.start_or_attach(config) end,
      })
    end,
  },

  -- ── none-ls: formatters & linters via LSP protocol ──────
  {
    "nvimtools/none-ls.nvim",
    event        = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "williamboman/mason.nvim",
    },
    config = function()
      local null_ls = require("null-ls")
      local b       = null_ls.builtins

      null_ls.setup({
        sources = {
          -- Python formatting/linting is handled by ruff LSP (see lspconfig.ruff above)

          -- C / C++ (clang-format reads .clang-format in project root)
          b.formatting.clang_format.with({
            filetypes = { "c", "cpp" },
          }),

          -- SQL
          b.formatting.sqlfluff.with({
            extra_args = { "--dialect", "ansi" },
          }),

          -- Lua
          b.formatting.stylua,

          -- PHP
          b.formatting.phpcsfixer.with({
            extra_args = { "--rules", "@PSR12" },
          }),
        },
        on_attach = function(client, bufnr)
          -- Format on save
          if client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer   = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr, async = false })
              end,
            })
          end
        end,
      })
    end,
  },

  -- ── sqls.nvim helper (DB execution commands) ─────────────
  {
    "nanotee/sqls.nvim",
    ft = { "sql", "mysql", "plsql" },
  },
}

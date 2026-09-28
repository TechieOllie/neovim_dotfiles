-- ============================================================
--  plugins/assembly.lua — NASM x86-64 (The Assembly Wall)
--
--  Toolchain (nasm, gdb, asm-lsp) comes from the project's flake
--  via direnv, not Mason — so start nvim from a terminal inside
--  the project directory.
--
--  <leader>a → Assembly (NASM buffers only)
--    <leader>ar  build + run, shows exit code
--    <leader>ab  build only
--    <leader>ad  build, then debug with gdb (nvim-dap)
-- ============================================================

-- .asm is NASM here, not GNU as. Top-level so it applies before
-- any buffer opens.
vim.filetype.add({ extension = { asm = "nasm" } })

-- ── LSP: asm-lsp from the flake ─────────────────────────────
-- Picks up the shared on_attach (K, gd, <leader>l…) from
-- vim.lsp.config("*") in lsp.lua. Only enabled when the binary
-- is on PATH, i.e. nvim was started inside the direnv shell.
vim.lsp.config("asm_lsp", {
  cmd          = { "asm-lsp" },
  filetypes    = { "nasm", "asm" },
  root_markers = { ".asm-lsp.toml", ".git" },
})
if vim.fn.executable("asm-lsp") == 1 then
  vim.lsp.enable("asm_lsp")
end

-- ── Helpers ─────────────────────────────────────────────────
local function target()
  return vim.fn.expand("%:p:h"), vim.fn.expand("%:t:r")
end

local function run_in_term(run)
  vim.cmd("write")
  local dir, name = target()
  local cmd = "make " .. name
  if run then
    cmd = cmd .. " && ./" .. name .. '; echo "exit code: $?"'
  end
  -- terminal #9 so it doesn't clobber your usual <C-\> terminal
  require("toggleterm").exec(cmd, 9, 15, dir, "horizontal")
end

local dap_ready = false
local function setup_gdb_dap()
  if dap_ready then return end
  local dap = require("dap")
  -- gdb 14+ speaks DAP natively; no extra adapter to install
  dap.adapters.gdb = {
    type    = "executable",
    command = "gdb",
    args    = { "--interpreter=dap", "--eval-command", "set print pretty on" },
  }
  dap.configurations.nasm = {
    {
      name    = "Debug this program (gdb)",
      type    = "gdb",
      request = "launch",
      program = function() return vim.fn.expand("%:p:r") end,
      cwd     = "${workspaceFolder}",
      stopAtBeginningOfMainSubprogram = false,
    },
  }
  dap_ready = true
end

local function debug()
  vim.cmd("write")
  local dir, name = target()
  local out = vim.fn.system({ "make", "-C", dir, name })
  if vim.v.shell_error ~= 0 then
    vim.notify(out, vim.log.levels.ERROR, { title = "make " .. name })
    return
  end
  setup_gdb_dap()
  require("dap").continue()
end

-- ── NASM buffers ────────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = vim.api.nvim_create_augroup("user_nasm", { clear = true }),
  pattern = "nasm",
  callback = function(ev)
    vim.bo[ev.buf].commentstring = "; %s"

    local map = function(lhs, fn, desc)
      vim.keymap.set("n", lhs, fn, { buffer = ev.buf, silent = true, desc = desc })
    end
    map("<leader>ar", function() run_in_term(true) end,  "Build + run")
    map("<leader>ab", function() run_in_term(false) end, "Build")
    map("<leader>ad", debug,                             "Build + debug (gdb)")

    pcall(function()
      require("which-key").add({ { "<leader>a", group = "Assembly", buffer = ev.buf } })
    end)
  end,
})

-- Keymaps live in the autocmd above; no extra plugins needed.
return {}

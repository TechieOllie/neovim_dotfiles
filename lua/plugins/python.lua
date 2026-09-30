-- ============================================================
--  plugins/python.lua — Run the current Python file
--
--  LSP (pyright + ruff) lives in lsp.lua, debugging in dap.lua.
--  This is just the quick "run it and show me the output" path,
--  same shape as the assembly runner in assembly.lua.
--
--  <leader>p → Python (Python buffers only)
--    <leader>pr  run this file, shows exit code
-- ============================================================

-- ── Interpreter ─────────────────────────────────────────────
-- An active venv wins; otherwise look for one next to the file
-- or in any parent dir, so `python3 foo.py` still sees the
-- project's packages. Falls back to whatever is on PATH.
local function interpreter(start)
  local venv = vim.env.VIRTUAL_ENV
  if venv and vim.fn.executable(venv .. "/bin/python") == 1 then
    return venv .. "/bin/python"
  end
  local found = vim.fs.find(
    { ".venv/bin/python", "venv/bin/python" },
    { path = start, upward = true, type = "file" }
  )[1]
  return found or "python3"
end

local function run()
  vim.cmd("write")
  local dir  = vim.fn.expand("%:p:h")
  local file = vim.fn.expand("%:t")
  local cmd = vim.fn.shellescape(interpreter(dir))
    .. " " .. vim.fn.shellescape(file)
    .. '; echo "exit code: $?"'
  -- terminal #10 (assembly uses #9) so neither clobbers <C-\>
  require("toggleterm").exec(cmd, 10, 15, dir, "horizontal")
end

-- ── Python buffers ──────────────────────────────────────────
vim.api.nvim_create_autocmd("FileType", {
  group   = vim.api.nvim_create_augroup("user_python_run", { clear = true }),
  pattern = "python",
  callback = function(ev)
    vim.keymap.set("n", "<leader>pr", run,
      { buffer = ev.buf, silent = true, desc = "Run this file" })

    pcall(function()
      require("which-key").add({ { "<leader>p", group = "Python", buffer = ev.buf } })
    end)
  end,
})

-- Keymap lives in the autocmd above; no extra plugins needed.
return {}

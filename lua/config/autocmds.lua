-- ============================================================
--  config/autocmds.lua — Autocommands
-- ============================================================

local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ higroup = "Visual", timeout = 200 })
  end,
})

-- Restore cursor position on file open
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when terminal is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- Close certain buffers with just <q>
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "qf", "notify", "lspinfo", "checkhealth",
              "man", "mason", "lazy", "startuptime" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true })
  end,
})

-- ── Language-specific settings ───────────────────────────────

-- Python: 4-space tabs (PEP 8)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("python"),
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.colorcolumn = "88" -- Black formatter default
  end,
})

-- C: 2-space tabs common in embedded (adjust to taste)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("c_cpp"),
  pattern = { "c", "cpp" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.commentstring = "// %s"
  end,
})

-- Java: 4 spaces
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("java"),
  pattern = "java",
  callback = function()
    vim.opt_local.tabstop    = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- SQL: 2-space tabs
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("sql"),
  pattern = { "sql", "mysql", "plsql" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- Remove trailing whitespace on save (all files)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_whitespace"),
  callback = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd([[%s/\s\+$//e]])
    vim.api.nvim_win_set_cursor(0, pos)
  end,
})

-- Auto-create parent dirs on save if they don't exist
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(ev)
    local dir = vim.fn.fnamemodify(ev.match, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- SIGUSR1 live theme reload is handled directly by matugen.lua
-- (libuv signal watcher registered in the matugen module).

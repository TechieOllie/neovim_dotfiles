-- ============================================================
--  config/options.lua — Core Neovim settings
-- ============================================================

local opt = vim.opt

-- Leader keys (must be set before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ── UI ──────────────────────────────────────────────────────
opt.number = true -- show line numbers
opt.relativenumber = true -- relative numbers for easy jumps
opt.cursorline = true -- highlight current line
opt.signcolumn = "yes" -- always show sign column (no layout shift)
opt.colorcolumn = "100" -- ruler at 100 chars
opt.termguicolors = true -- 24-bit colour
opt.scrolloff = 8 -- keep 8 lines visible above/below cursor
opt.sidescrolloff = 8
opt.showmode = false -- lualine shows the mode already
opt.splitbelow = true -- new horizontal splits go below
opt.splitright = true -- new vertical splits go right
opt.laststatus = 3 -- single global statusline
opt.cmdheight = 1

-- ── Editing ─────────────────────────────────────────────────
opt.tabstop = 4 -- 4-space tabs (Python & C style)
opt.shiftwidth = 4
opt.expandtab = true -- spaces, not tab characters
opt.smartindent = true
opt.wrap = true -- line wrap
opt.linebreak = true -- if wrap is enabled, break at words
opt.clipboard = "unnamedplus" -- use system clipboard
opt.undofile = true -- persistent undo across sessions
opt.undolevels = 10000
opt.updatetime = 200 -- faster CursorHold & swap writes
opt.timeoutlen = 300 -- faster which-key popup

-- ── Search ──────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true -- case-sensitive if uppercase typed
opt.hlsearch = true
opt.incsearch = true

-- ── Files ───────────────────────────────────────────────────
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- ── Folds (treesitter-based) ─────────────────────────────────
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldenable = false -- open all folds on file open

-- ── Completion ──────────────────────────────────────────────
opt.completeopt = { "menu", "menuone", "noselect" }
opt.pumheight = 10 -- max completion popup entries

-- ── Misc ────────────────────────────────────────────────────
opt.mouse = "a"
opt.virtualedit = "block" -- free cursor in visual block mode
opt.inccommand = "split" -- live preview of :s substitutions
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.formatoptions:remove({ "c", "r", "o" }) -- no auto-comment on newline

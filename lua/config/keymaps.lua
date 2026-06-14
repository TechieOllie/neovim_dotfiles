-- ============================================================
--  config/keymaps.lua — Custom keymaps
--  <leader> = Space
-- ============================================================

local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ── General ─────────────────────────────────────────────────
map("n", "<Esc>",       "<cmd>nohlsearch<cr>",         { desc = "Clear search highlight" })
map("n", "<leader>w",   "<cmd>w<cr>",                  { desc = "Save file" })
map("n", "<leader>q",   "<cmd>q<cr>",                  { desc = "Quit" })
map("n", "<leader>Q",   "<cmd>qa!<cr>",                { desc = "Quit all (force)" })

-- ── Window navigation ────────────────────────────────────────
map("n", "<C-h>",       "<C-w>h",                      { desc = "Move to left window" })
map("n", "<C-j>",       "<C-w>j",                      { desc = "Move to lower window" })
map("n", "<C-k>",       "<C-w>k",                      { desc = "Move to upper window" })
map("n", "<C-l>",       "<C-w>l",                      { desc = "Move to right window" })

-- ── Window resize ────────────────────────────────────────────
map("n", "<C-Up>",      "<cmd>resize +2<cr>",          { desc = "Increase window height" })
map("n", "<C-Down>",    "<cmd>resize -2<cr>",          { desc = "Decrease window height" })
map("n", "<C-Left>",    "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>",   "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- ── Buffer navigation ────────────────────────────────────────
map("n", "<S-h>",       "<cmd>bprevious<cr>",          { desc = "Previous buffer" })
map("n", "<S-l>",       "<cmd>bnext<cr>",              { desc = "Next buffer" })
map("n", "<leader>bd",  "<cmd>bdelete<cr>",            { desc = "Delete buffer" })
map("n", "<leader>bo",  "<cmd>%bdelete|edit#|bdelete#<cr>", { desc = "Close other buffers" })

-- ── Indenting in visual mode (keeps selection) ───────────────
map("v", "<",           "<gv",                         { desc = "Indent left" })
map("v", ">",           ">gv",                         { desc = "Indent right" })

-- ── Move lines up/down ───────────────────────────────────────
map("n", "<A-j>",       "<cmd>m .+1<cr>==",            { desc = "Move line down" })
map("n", "<A-k>",       "<cmd>m .-2<cr>==",            { desc = "Move line up" })
map("v", "<A-j>",       ":m '>+1<cr>gv=gv",           { desc = "Move selection down" })
map("v", "<A-k>",       ":m '<-2<cr>gv=gv",           { desc = "Move selection up" })

-- ── Better up/down (respects wrapped lines) ──────────────────
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up" })

-- ── Paste without overwriting register ───────────────────────
map("v", "p",           '"_dP',                        { desc = "Paste (keep register)" })

-- ── Diagnostic navigation ────────────────────────────────────
map("n", "[d",          vim.diagnostic.goto_prev,      { desc = "Previous diagnostic" })
map("n", "]d",          vim.diagnostic.goto_next,      { desc = "Next diagnostic" })
map("n", "<leader>e",   vim.diagnostic.open_float,     { desc = "Show diagnostic" })
map("n", "<leader>dl",  "<cmd>Telescope diagnostics<cr>", { desc = "Diagnostics list" })

-- ── Terminal ─────────────────────────────────────────────────
map("t", "<Esc><Esc>",  "<C-\\><C-n>",                { desc = "Exit terminal mode" })

-- ── Git (Lazygit + Diffview — see plugins/git.lua) ──────────
-- <leader>gg  → Lazygit
-- <leader>gd  → Diffview open
-- <leader>gh  → Diffview file history
-- <leader>gm  → Merge conflicts (Diffview)
-- <leader>gc  → Close Diffview

-- ── Navigation hints (see plugins/navigation.lua) ────────────
-- <leader>ff  → Find files
-- <leader>fg  → Live grep
-- <leader>fb  → Buffers
-- <leader>fr  → Recent files
-- -           → Open Yazi

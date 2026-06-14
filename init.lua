-- ============================================================
--  init.lua — Neovim entry point
--  Bootstraps lazy.nvim, then loads config & plugins
-- ============================================================

-- Load core settings first (no plugin deps)
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- ── Bootstrap lazy.nvim ─────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Load plugins ────────────────────────────────────────────
require("lazy").setup("plugins", {
  change_detection = { notify = false },
  install = { colorscheme = { "base16-default-dark", "habamax" } },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen",
        "netrwPlugin", "tarPlugin", "tohtml",
        "tutor", "zipPlugin",
      },
    },
  },
})

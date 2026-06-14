local M = {}

function M.setup()
  require("base16-colorscheme").setup({
    base00 = "#0f131c",                -- background
    base01 = "#1b2029",      -- status bars
    base02 = "#262a33", -- selection bg
    base03 = "#8891a5",                -- comments
    base04 = "#bec6dc",     -- dark fg
    base05 = "#dfe2ef",             -- default fg
    base06 = "#dfe2ef",             -- light fg
    base07 = "#dfe2ef",          -- lightest fg
    base08 = "#ffb4ab",                  -- variables, errors
    base09 = "#abc7ff",               -- integers, constants
    base0A = "#83d2e4",              -- classes
    base0B = "#53d7f1",                -- strings
    base0C = "#abc7ff",     -- regex, escapes
    base0D = "#53d7f1",      -- functions
    base0E = "#83d2e4",    -- keywords
    base0F = "#93000a",        -- deprecated
  })
end

-- Hot-reload on SIGUSR1 sent by Noctalia's post_hook
local signal = vim.uv.new_signal()
signal:start("sigusr1", vim.schedule_wrap(function()
  package.loaded.matugen = nil
  require("matugen").setup()
end))

return M

# Dotfiles — Neovim · Yazi · Lazygit

A modular Neovim configuration themed by **Noctalia v4** through the
[Matugen](https://github.com/InioX/matugen) colour-generation pipeline.
Theme changes propagate to all three tools live via `SIGUSR1` — no
restart required.

---

## Contents

```
~/.config/
├── nvim/
│   ├── init.lua                    Entry point, lazy.nvim bootstrap
│   ├── lua/
│   │   ├── matugen-template.lua    Matugen INPUT  (module template)
│   │   ├── matugen.lua             Matugen OUTPUT (module with .setup(), gitignored)
│   │   ├── config/
│   │   │   ├── options.lua         Core Neovim settings
│   │   │   ├── keymaps.lua         Key bindings
│   │   │   └── autocmds.lua        Autocommands (SIGUSR1 handled by matugen.lua)
│   │   └── plugins/
│   │       ├── lsp.lua             Mason · lspconfig (vim.lsp.config API)
│   │       ├── dap.lua             nvim-dap · nvim-dap-ui · Python debugging (debugpy)
│   │       ├── completion.lua      nvim-cmp · LuaSnip · friendly-snippets
│   │       ├── treesitter.lua      Syntax · indent · text-objects
│   │       ├── git.lua             Lazygit · Diffview (merge TUI) · Gitsigns
│   │       ├── navigation.lua      Telescope · Yazi · which-key
│   │       └── ui.lua              nvim-base16 · lualine · bufferline · Noice · render-markdown
├── matugen/
│   └── config.toml                 Matugen pipeline config (all three tools)
├── yazi/
│   └── flavor/
│       ├── noctalia-template.toml  Matugen INPUT  for Yazi
│       └── noctalia.toml           Matugen OUTPUT (generated, gitignored)
└── lazygit/
    ├── noctalia-template.yml       Matugen INPUT  for Lazygit
    └── noctalia-theme.yml          Matugen OUTPUT (generated, gitignored)
```

---

## Requirements

| Tool | Version | Install |
|---|---|---|
| Neovim | ≥ 0.12 | [neovim.io](https://neovim.io) |
| Matugen | latest | `cargo install matugen` |
| Lazygit | latest | [GitHub](https://github.com/jesseduffield/lazygit) |
| Yazi | latest | [GitHub](https://github.com/sxyazi/yazi) |
| Nerd Font | any | [nerdfonts.com](https://www.nerdfonts.com) |
| `make` | any | For telescope-fzf-native build |
| `bear` | optional | For `compile_commands.json` on Makefile projects |

**LSP / tooling installed automatically by Mason on first launch:**

- `pyright` — Python type checking
- `ruff` — Python formatter + linter (standalone LSP)
- `clangd` — C / C++ LSP (reads `compile_commands.json`)
- `sqls` — SQL LSP
- `lua_ls` — Lua LSP (for config files)
- `phpactor` — PHP LSP
- `clang-format` — C / C++ formatter (reads `.clang-format`)
- `sqlfluff` — SQL formatter
- `stylua` — Lua formatter
- `php-cs-fixer` — PHP formatter (via Composer)
- `debugpy` — Python debug adapter (via `mason-tool-installer.nvim`,
  used by `nvim-dap`/`nvim-dap-python`, see `plugins/dap.lua`)

---

## Installation

### 1. Clone

```bash
git clone https://github.com/you/dotfiles ~/.dotfiles
```

### 2. Link configs

```bash
# Back up existing configs first
mv ~/.config/nvim    ~/.config/nvim.bak    2>/dev/null
mv ~/.config/yazi    ~/.config/yazi.bak    2>/dev/null
mv ~/.config/lazygit ~/.config/lazygit.bak 2>/dev/null

ln -sf ~/.dotfiles/nvim    ~/.config/nvim
ln -sf ~/.dotfiles/yazi    ~/.config/yazi
ln -sf ~/.dotfiles/lazygit ~/.config/lazygit
ln -sf ~/.dotfiles/matugen ~/.config/matugen
```

### 3. Add Matugen config

`~/.config/matugen/config.toml`:

```toml
[templates.nvim-base16]
input_path  = "~/.config/nvim/lua/matugen-template.lua"
output_path = "~/.config/nvim/lua/matugen.lua"
post_hook   = "pkill -SIGUSR1 nvim"

[templates.yazi]
input_path  = "~/.config/yazi/flavor/noctalia-template.toml"
output_path = "~/.config/yazi/flavor/noctalia.toml"
post_hook   = "pkill -SIGUSR1 yazi"

[templates.lazygit]
input_path  = "~/.config/lazygit/noctalia-template.yml"
output_path = "~/.config/lazygit/noctalia-theme.yml"
post_hook   = "pkill -SIGUSR1 lazygit"
```

### 4. Generate the theme

```bash
# From a wallpaper image:
matugen image /path/to/noctalia-wallpaper.png

# Or from a seed colour:
matugen color "#1a1b26"
```

This writes `matugen.lua`, `noctalia.toml`, and `noctalia-theme.yml`,
then signals any running instances via `SIGUSR1`.

### 5. Launch Neovim

```bash
nvim
```

lazy.nvim bootstraps itself, installs all plugins (~1 min), then Mason
installs the LSP servers. On subsequent starts, load time is under 50 ms.

---

## Theme pipeline

```
Noctalia v4 wallpaper / seed colour
        │
        ▼
    matugen
        │
        ├──▶ matugen.lua (Lua module with M.setup())
        │         │
        │         └──▶ nvim-base16 ──▶ Neovim highlights
        │                   │
        │                   └──▶ lualine theme (built dynamically)
        │
        ├──▶ noctalia.toml        ──▶ Yazi flavour
        │
        └──▶ noctalia-theme.yml   ──▶ Lazygit colour theme
                                          │
                    SIGUSR1 ◀─────────────┘ (post_hook in all three)
                        │
                        └──▶ matugen.lua signal handler
                             (libuv, busts cache, calls M.setup())
```

To reload manually inside Neovim: `<leader>tr`

---

## Key bindings — quick reference

`<leader>` is **Space**.

### Files & Search

| Key | Action |
|---|---|
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep |
| `<leader>fb` | Open buffers |
| `<leader>fr` | Recent files |
| `<leader>fc` | Find word under cursor |
| `e` | Open Yazi (current file) |
| `<leader>e` | Open Yazi (current file) |
| `<leader>ew` | Open Yazi (working dir) |
| `<leader>er` | Resume last Yazi session |

### LSP

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>lf` | Format file |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>xx` | Toggle Trouble diagnostics |

### Git

| Key | Action |
|---|---|
| `<leader>gg` | Open Lazygit |
| `<leader>gd` | Diffview — diff against HEAD |
| `<leader>gm` | Diffview — merge conflict TUI |
| `<leader>gh` | Diffview — file history |
| `<leader>gc` | Close Diffview |
| `<leader>gb` | Toggle inline git blame |
| `]h` / `[h` | Next / previous hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |

### Merge conflict resolution (inside Diffview)

| Key | Action |
|---|---|
| `]x` / `[x` | Next / previous conflict |
| `<leader>co` | Choose **ours** |
| `<leader>ct` | Choose **theirs** |
| `<leader>cb` | Keep **both** |
| `<leader>cn` | Delete conflict hunk |
| `<leader>cO` | Choose ours for **all** conflicts |
| `<leader>cT` | Choose theirs for **all** conflicts |

### Debug (Python, via nvim-dap)

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dt` | Terminate session |
| `<leader>du` | Toggle DAP UI |

### Windows & Buffers

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move between windows |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<leader>bd` | Delete buffer |
| `<C-\>` | Toggle floating terminal |

### Theme

| Key | Action |
|---|---|
| `<leader>tr` | Reload Matugen theme (manual) |

---

## Language notes

### Python

Uses `pyright` for type checking and `ruff` (as a standalone LSP) for
formatting and linting. `ruff` replaces Black + isort + flake8 in one
fast binary. Configure per-project with a `pyproject.toml` or `ruff.toml`.

**Debugging**: `nvim-dap` + `nvim-dap-ui`, adapter via `nvim-dap-python`,
debugger itself (`debugpy`) installed automatically by Mason on first
launch. Set a breakpoint and start debugging from any Python buffer:

| Key | Action |
|---|---|
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start debugging |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dt` | Terminate session |
| `<leader>du` | Toggle DAP UI |

### C / C++ (STM32, Espressif)

`clangd` needs a `compile_commands.json` at the project root:

```bash
# CMake projects
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build && \
  ln -sf build/compile_commands.json .

# ESP-IDF
idf.py reconfigure   # writes sdkconfig + compile_commands.json

# Makefile projects
bear -- make
```

For cross-compilation, uncomment the `--query-driver` line in
`plugins/lsp.lua` and point it at your toolchain binary:

```lua
"--query-driver=/home/user/.espressif/tools/xtensa-esp32-elf/*/bin/xtensa-esp32-elf-gcc",
-- or for STM32:
"--query-driver=/usr/bin/arm-none-eabi-gcc",
```

### PHP

Uses `phpactor` for LSP features (completion, navigation, refactoring)
and `php-cs-fixer` for formatting via PSR-12 rules. Install PHP + Composer:

```bash
sudo pacman -S php composer
composer global require friendsofphp/php-cs-fixer
```

### SQL

`sqls` connects to your databases for context-aware completion. Configure
connections in `~/.config/sqls/config.yml`. `vim-dadbod-ui` is available
for running queries interactively (`:DBUI`).

---

## Gitignore recommendations

Add these generated files to your dotfiles `.gitignore` since Matugen
re-creates them at runtime:

```gitignore
nvim/lua/matugen.lua
yazi/flavor/noctalia.toml
lazygit/noctalia-theme.yml
```

Keep the templates (`*-template.*`) — those are the source of truth.

---

## Updating plugins

```vim
:Lazy update
```

Updating LSP servers / formatters:

```vim
:Mason
```

Then press `U` inside Mason to update all installed packages.

---

## Troubleshooting

**Theme not applied on startup** — Run `matugen image <wallpaper>` at
least once to generate `matugen.lua`. Until then, the built-in Noctalia
v4 fallback palette is used.

**SIGUSR1 not triggering reload** — Check that `pkill` is available and
that you are running Neovim as the same user as Matugen. On macOS,
`pkill -SIGUSR1 nvim` is replaced by `pkill -USR1 nvim`.

**clangd not finding headers** — Ensure `compile_commands.json` exists
at the project root and that the `--query-driver` path in `lsp.lua`
matches your actual toolchain location.

**DAP not stopping at breakpoints** — Confirm `debugpy` installed
correctly via `:Mason` (look for it under the "DAP" category); if
missing, run `:MasonToolsInstall` to trigger `mason-tool-installer.nvim`.

**Slow startup** — Run `:Lazy profile` to identify slow plugins. Most
plugins are lazy-loaded; if startup is still slow check your LSP
`on_attach` functions for expensive synchronous calls.

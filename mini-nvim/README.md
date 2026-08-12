# mini-nvim

Minimal Neovim config — small plugin count, but not ascetic. Four plugins:

- `mini.nvim` — its own plugin manager (`mini.deps`, installs everything else), statusline (`mini.statusline`), buffer tabline (`mini.tabline`), file tree (`mini.files`)
- `telescope.nvim` (+ its required `plenary.nvim`)
- `nvim-lspconfig` — used only as a source of server config data for Neovim's built-in LSP client (`vim.lsp.config`/`vim.lsp.enable`, 0.11+); no completion plugin, uses the builtin `vim.lsp.completion`

Constraints, on purpose:
- no nerd font, no icons, no unicode glyphs (ASCII borders/prompts, plain-letter diagnostic signs, no icons in the file tree/tabline)
- colors limited to the terminal's 16 ANSI colors — `colors/sixteen.lua` sets `ctermfg`/`ctermbg` only, never gui/hex, so it looks like whatever palette your terminal defines
- requires Neovim >= 0.11 (native `vim.lsp.config`/`vim.lsp.enable` API)

LSP servers only auto-enable if their binary is already on `$PATH` (checked in `lua/lsp.lua`) — install what you need via pacman/npm/cargo/etc. on the Arch box, no `mason.nvim` here to keep the plugin count down.

## Layout

```
init.lua           entrypoint
lua/options.lua     vim.opt settings
lua/plugins.lua      mini.deps bootstrap + mini.statusline/tabline/files + telescope setup
lua/lsp.lua           native LSP: enable installed servers, LspAttach keymaps
lua/keymaps.lua        telescope pickers, buffers, file tree, window nav
colors/sixteen.lua      the colorscheme
```

## Install on a new machine (e.g. the Arch box)

Copy this folder to `~/.config/mini-nvim`, then either:

```sh
# run standalone, alongside any existing ~/.config/nvim
NVIM_APPNAME=mini-nvim nvim

# or make it the only config
mv ~/.config/mini-nvim ~/.config/nvim
```

First launch clones `mini.nvim`, `plenary.nvim`, and `telescope.nvim` automatically via `mini.deps` — needs `git` and network access once.

Make sure your terminal emulator's theme actually defines a 16-color ANSI palette you like — that's the only "theming" this config has.

## Keymaps

Leader is `<Space>`.

| Keys | Action |
|---|---|
| `<leader>ff` | find files |
| `<leader>fg` | live grep |
| `<leader>fb` | buffers |
| `<leader>fh` | help tags |
| `<leader>fo` | recent files |
| `<leader>fd` | diagnostics |
| `<leader>bn` / `<leader>bp` | next / prev buffer |
| `<leader>bd` | delete buffer |
| `<leader>e` | toggle file tree |
| `<C-h/j/k/l>` | move between windows |
| `<Esc>` | clear search highlight |

LSP (buffer-local, active once a server attaches):

| Keys | Action |
|---|---|
| `K` | hover |
| `gd` / `gD` / `gi` | definition / declaration / implementation |
| `gr` | references (telescope) |
| `<leader>rn` | rename |
| `<leader>ca` | code action |
| `<leader>df` | format buffer |
| `[d` / `]d` | prev / next diagnostic |

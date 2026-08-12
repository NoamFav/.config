-- mini-nvim: hyper-minimal neovim config
-- plugins: mini.nvim (statusline, plugin manager) + telescope.nvim
-- constraints: no nerd font, no glyphs/icons, 16-color terminal palette only

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

require('options')

vim.o.termguicolors = false
vim.cmd.colorscheme('sixteen')

require('plugins')
require('completion')
require('lsp')
require('keymaps')

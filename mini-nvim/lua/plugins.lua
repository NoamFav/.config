-- plugin manager: mini.deps, bundled inside mini.nvim itself.
-- this is the only bootstrap needed: everything else installs through it.
local uv = vim.uv or vim.loop

local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'

if not uv.fs_stat(mini_path) then
  vim.cmd('echo "Installing mini.nvim..." | redraw')
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path,
  })
  vim.cmd('packadd mini.nvim | helptags ALL')
end

require('mini.deps').setup({ path = { package = path_package } })

local add = MiniDeps.add

add('nvim-lua/plenary.nvim')
add('nvim-telescope/telescope.nvim')
-- data-only: bundles `lsp/*.lua` server configs consumed by vim.lsp.config
-- below, no setup() call needed with the native 0.11+ LSP API
add('neovim/nvim-lspconfig')
-- fuzzy matcher is a prebuilt binary downloaded on first use; falls back to
-- a pure-lua matcher automatically if that download fails (no cargo needed).
-- pinned to v1: v2 requires blink.lib installed via a system package manager
add({ source = 'saghen/blink.cmp', checkout = 'v1' })

require('mini.statusline').setup({ use_icons = false })
require('mini.tabline').setup({ show_icons = false })
require('mini.files').setup({
  content = { prefix = function() return '', '' end },
  options = { use_as_default_explorer = true },
})

require('telescope').setup({
  defaults = {
    prompt_prefix = '> ',
    selection_caret = '> ',
    entry_prefix = '  ',
    multi_icon = '+ ',
    borderchars = { '-', '|', '-', '|', '+', '+', '+', '+' },
  },
})

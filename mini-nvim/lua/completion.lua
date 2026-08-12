-- blink.cmp: completion popup, text-only (no kind icons), ascii borders,
-- same shape as everything else in this config. must load before lsp.lua
-- sets up servers, since it registers the completion capabilities every
-- server needs to know about.

local border = { '+', '-', '+', '|', '+', '-', '+', '|' }

require('blink.cmp').setup({
  keymap = { preset = 'default' },
  completion = {
    menu = {
      border = border,
      draw = {
        columns = { { 'label', 'label_description', gap = 1 }, { 'kind' } },
      },
    },
    documentation = {
      auto_show = true,
      window = { border = border },
    },
  },
  signature = {
    enabled = true,
    window = { border = border },
  },
  sources = {
    default = { 'lsp', 'path', 'buffer' },
  },
})

-- merges into every server's client capabilities, so they all know this
-- client supports blink's completion features
vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })

local map = vim.keymap.set

local telescope = require('telescope.builtin')
map('n', '<leader>ff', telescope.find_files, { desc = 'Find files' })
map('n', '<leader>fg', telescope.live_grep, { desc = 'Live grep' })
map('n', '<leader>fb', telescope.buffers, { desc = 'Find buffers' })
map('n', '<leader>fh', telescope.help_tags, { desc = 'Help tags' })
map('n', '<leader>fo', telescope.oldfiles, { desc = 'Recent files' })
map('n', '<leader>fd', telescope.diagnostics, { desc = 'Diagnostics' })

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

-- buffers
map('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next buffer' })
map('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Prev buffer' })
map('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

-- file tree (mini.files, bundled with mini.nvim — no extra plugin)
map('n', '<leader>e', function()
  if not MiniFiles.close() then
    MiniFiles.open(vim.api.nvim_buf_get_name(0))
  end
end, { desc = 'Toggle file tree' })

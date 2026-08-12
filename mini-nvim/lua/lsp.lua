-- native LSP client + vim.lsp.config/vim.lsp.enable (0.11+). server configs
-- come from nvim-lspconfig's bundled lsp/*.lua data files on the runtimepath
-- (installed in plugins.lua). completion.lua (loaded before this file) wires
-- up blink.cmp's capabilities, which is what actually drives the popup.

-- name -> binary to check for before enabling, so opening a file never
-- errors just because that language's server isn't installed on this machine
local servers = {
  lua_ls = 'lua-language-server',
  pyright = 'pyright-langserver',
  clangd = 'clangd',
  rust_analyzer = 'rust-analyzer',
  ts_ls = 'typescript-language-server',
  bashls = 'bash-language-server',
  gopls = 'gopls',
}

local enabled = {}
for name, bin in pairs(servers) do
  if vim.fn.executable(bin) == 1 then
    table.insert(enabled, name)
  end
end

if #enabled > 0 then
  vim.lsp.enable(enabled)
end

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
    end

    map('n', 'K', vim.lsp.buf.hover, 'LSP hover')
    map('n', 'gd', vim.lsp.buf.definition, 'Goto definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'Goto declaration')
    map('n', 'gi', vim.lsp.buf.implementation, 'Goto implementation')
    map('n', 'gr', require('telescope.builtin').lsp_references, 'References')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename')
    map('n', '<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('n', '<leader>df', vim.lsp.buf.format, 'Format buffer')
    map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Prev diagnostic')
    map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, 'Next diagnostic')
  end,
})

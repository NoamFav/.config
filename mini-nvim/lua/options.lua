local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.cursorline = true

opt.wrap = false
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true

opt.splitright = true
opt.splitbelow = true

opt.mouse = 'a'
opt.clipboard = 'unnamedplus'
opt.scrolloff = 4
opt.updatetime = 250

opt.undofile = true
opt.swapfile = false

-- ascii-only UI: no box-drawing or unicode glyphs anywhere
opt.fillchars = {
  eob = ' ',
  fold = '-',
  vert = '|',
  horiz = '-',
  horizup = '-',
  horizdown = '-',
  vertleft = '|',
  vertright = '|',
  verthoriz = '+',
}
opt.list = false

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = 'E',
      [vim.diagnostic.severity.WARN] = 'W',
      [vim.diagnostic.severity.INFO] = 'I',
      [vim.diagnostic.severity.HINT] = 'H',
    },
  },
  virtual_text = true,
})

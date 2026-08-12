-- 16-color-only colorscheme.
-- every highlight group below sets ONLY ctermfg/ctermbg (values 0-15, the
-- basic ANSI palette). no guifg/guibg/hex anywhere, so the editor always
-- renders using whatever 16 colors the terminal itself defines.

vim.cmd('highlight clear')
if vim.fn.exists('syntax_on') == 1 then
  vim.cmd('syntax reset')
end
vim.o.background = 'dark'
vim.g.colors_name = 'sixteen'

local c = {
  black = 0, red = 1, green = 2, yellow = 3, blue = 4, magenta = 5, cyan = 6, white = 7,
  bblack = 8, bred = 9, bgreen = 10, byellow = 11, bblue = 12, bmagenta = 13, bcyan = 14, bwhite = 15,
  none = 'NONE',
}

local function hi(group, fg, bg, attrs)
  local opts = { ctermfg = fg or c.none, ctermbg = bg or c.none }
  if attrs then
    for _, a in ipairs(attrs) do
      opts[a] = true
    end
  end
  vim.api.nvim_set_hl(0, group, opts)
end

-- base UI
hi('Normal', c.white, c.none)
hi('NormalFloat', c.white, c.none)
hi('FloatBorder', c.bblack, c.none)
hi('SignColumn', c.bblack, c.none)
hi('LineNr', c.bblack, c.none)
hi('CursorLine', nil, c.black)
hi('CursorLineNr', c.byellow, c.none, { bold = true })
hi('Visual', nil, c.bblack)
hi('Search', c.black, c.yellow)
hi('IncSearch', c.black, c.byellow)
hi('MatchParen', c.byellow, c.none, { bold = true })
hi('Pmenu', c.white, c.bblack)
hi('PmenuSel', c.black, c.white)
hi('StatusLine', c.white, c.bblack)
hi('StatusLineNC', c.bblack, c.black)
hi('WinSeparator', c.bblack, c.none)
hi('NonText', c.bblack, c.none)
hi('EndOfBuffer', c.bblack, c.none)
hi('ColorColumn', nil, c.black)

-- diffs
hi('DiffAdd', c.green, c.none)
hi('DiffChange', c.yellow, c.none)
hi('DiffDelete', c.red, c.none)
hi('DiffText', c.byellow, c.none, { bold = true })

-- syntax
hi('Comment', c.bblack, c.none, { italic = true })
hi('Constant', c.cyan, c.none)
hi('String', c.green, c.none)
hi('Character', c.green, c.none)
hi('Number', c.magenta, c.none)
hi('Boolean', c.magenta, c.none)
hi('Identifier', c.white, c.none)
hi('Function', c.blue, c.none, { bold = true })
hi('Statement', c.red, c.none)
hi('Keyword', c.red, c.none)
hi('Operator', c.white, c.none)
hi('PreProc', c.cyan, c.none)
hi('Type', c.yellow, c.none)
hi('Special', c.cyan, c.none)
hi('Underlined', c.blue, c.none, { underline = true })
hi('Todo', c.black, c.byellow, { bold = true })
hi('Error', c.white, c.red, { bold = true })

-- diagnostics (text only, no icon-driven groups needed)
hi('DiagnosticError', c.red, c.none)
hi('DiagnosticWarn', c.yellow, c.none)
hi('DiagnosticInfo', c.blue, c.none)
hi('DiagnosticHint', c.cyan, c.none)
hi('DiagnosticUnderlineError', c.red, c.none, { underline = true })
hi('DiagnosticUnderlineWarn', c.yellow, c.none, { underline = true })
hi('DiagnosticUnderlineInfo', c.blue, c.none, { underline = true })
hi('DiagnosticUnderlineHint', c.cyan, c.none, { underline = true })

-- telescope (falls back sensibly, override the couple that matter)
hi('TelescopeSelection', c.black, c.white, { bold = true })
hi('TelescopeMatching', c.byellow, c.none, { bold = true })
hi('TelescopeBorder', c.bblack, c.none)
hi('TelescopePromptBorder', c.bblack, c.none)
hi('TelescopeNormal', c.white, c.none)

-- mini.tabline (buffer list)
hi('TabLine', c.bblack, c.black)
hi('TabLineSel', c.black, c.white, { bold = true })
hi('TabLineFill', c.bblack, c.none)
hi('MiniTablineCurrent', c.black, c.white, { bold = true })
hi('MiniTablineVisible', c.white, c.bblack)
hi('MiniTablineHidden', c.bblack, c.black)
hi('MiniTablineFill', c.bblack, c.none)
hi('MiniTablineModifiedCurrent', c.black, c.byellow, { bold = true })
hi('MiniTablineModifiedHidden', c.byellow, c.black)

-- mini.files (file tree)
hi('MiniFilesDirectory', c.blue, c.none, { bold = true })
hi('MiniFilesFile', c.white, c.none)
hi('MiniFilesNormal', c.white, c.none)
hi('MiniFilesCursorLine', c.black, c.white, { bold = true })
hi('MiniFilesTitle', c.bblack, c.none)
hi('MiniFilesTitleFocused', c.byellow, c.none, { bold = true })

-- blink.cmp (completion popup, docs, signature help)
hi('BlinkCmpMenu', c.white, c.none)
hi('BlinkCmpMenuBorder', c.bblack, c.none)
hi('BlinkCmpMenuSelection', c.black, c.white, { bold = true })
hi('BlinkCmpLabelMatch', c.byellow, c.none, { bold = true })
hi('BlinkCmpDoc', c.white, c.none)
hi('BlinkCmpDocBorder', c.bblack, c.none)
hi('BlinkCmpSignatureHelp', c.white, c.none)
hi('BlinkCmpSignatureHelpBorder', c.bblack, c.none)
hi('BlinkCmpSignatureHelpActiveParameter', c.byellow, c.none, { bold = true })

-- general settings
vim.o.number = true
vim.o.mouse = 'a'
vim.o.termguicolors = true
vim.o.autoindent = true
vim.o.cursorline = true
vim.o.signcolumn = 'yes'

vim.o.splitright = true
vim.o.splitbelow = true
vim.o.wildmenu = true
vim.o.wildmode = 'longest:list,full'
vim.o.updatetime = 100

-- searching
vim.o.showmatch = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true

-- display invisible characters
vim.o.list = true
vim.o.listchars = 'tab:» ,space:·'

-- don't display border
vim.o.fillchars = 'vert:│,horiz:─'

-- auto read file
vim.o.autoread = true

-- persistent undo
vim.o.undofile = true

local autocmd = vim.api.nvim_create_autocmd
local function keymap(mode, lhs, rhs, options)
  if type(lhs) == 'table' then
    for _, key in pairs(lhs) do
      keymap(mode, key, rhs, options)
    end
    return
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local function noremap(mode, lhs, rhs, options)
  local opts = options or {}
  opts['remap'] = false
  opts['nowait'] = true
  keymap(mode, lhs, rhs, opts)
end

local function noremap_all(lhs, rhs, options)
  noremap({'n', 'i', 'v'}, lhs, rhs, options)
end

-- common Emacs-like editor hotkeys
-- copy
noremap('n', {'<C-c>', '<C-S-c>'}, '"+yy')
noremap('v', {'<C-c>', '<C-S-c>'}, '"+y')
-- cut
noremap('n', '<C-x>', 'dd')
noremap('v', '<C-x>', 'd')
-- paste
noremap('n', '<C-v>', '"+p')
noremap('n', '<C-S-v>', '"+p')
-- go to line begin / end
noremap({'n', 'v'}, '<C-a>', '^')
noremap('i', '<C-a>', '<esc>^i')
noremap({'n', 'v'}, '<C-e>', '$')
noremap('i', '<C-e>', '<esc>$a')
-- save
noremap_all('<C-s>', '<cmd>wa<cr>')
-- quit
noremap_all('<C-q>', '<cmd>confirm qa<cr>')
-- close tab
noremap_all('<C-w>', '<cmd>confirm bd<cr>')
-- new tab
noremap_all('<C-n>', '<cmd>enew<cr>')
-- undo / redo
noremap_all('<C-z>', '<cmd>undo<cr>')
noremap_all({'<C-y>', '<C-S-z>'}, '<cmd>redo<cr>')
-- backspace
noremap('n', '<bs>', '"_dd')
noremap('v', '<bs>', '"_d')
-- shift indentation
noremap('v', '<Tab>', '>gv')
noremap('n', '<Tab>', '>>')
noremap('v', '<S-Tab>', '<gv')
noremap('n', '<S-Tab>', '<<')
noremap('i', '<S-Tab>', '<C-d>')
-- comment
keymap('n', '<C-_>', 'gcc', { remap = true })
keymap('i', '<C-_>', '<esc>gcci', { remap = true })
keymap('v', '<C-_>', 'gc', { remap = true })

if not vim.g.loaded_clipboard_provider then
  vim.g.clipboard = 'osc52'
end

-- plugins
vim.pack.add {
  "https://github.com/Shatur/neovim-ayu",
  "https://github.com/jake-stewart/multicursor.nvim",
  "https://github.com/tpope/vim-sleuth",
  "https://github.com/lukas-reineke/indent-blankline.nvim",
  "https://github.com/nvim-mini/mini.icons",
  "https://github.com/nvim-mini/mini.completion",
  "https://github.com/nvim-mini/mini.move",
  "https://github.com/nvim-mini/mini.tabline",
  "https://github.com/nvim-mini/mini.statusline",
  "https://github.com/nvim-mini/mini.pick",
}

-- ayu colors
local ayu = require('ayu')
local bg_overrides = {}
for _, hi in pairs {
  'Normal', 'NormalFloat', 'ColorColumn', 'SignColumn',
  'FoldColumn', 'VertSplit', 'WinSeparator'
} do
  bg_overrides[hi] = { bg = 'None' }
end
ayu.setup {
  mirage = true,
  terminal = true,
  overrides = bg_overrides,
}
ayu.colorscheme()

-- multi-cursors
local mc = require('multicursor-nvim')
mc.setup()
noremap({"n", "x"}, "<C-up>", function() mc.lineAddCursor(-1) end)
noremap({"n", "x"}, "<C-down>", function() mc.lineAddCursor(1) end)
noremap({"n", "x"}, "<C-d>", function() mc.matchAddCursor(1) end)
noremap({"n", "x"}, "<C-S-d>", function() mc.matchAddCursor(-1) end)

noremap("n", "<C-leftmouse>", mc.handleMouse)
noremap("n", "<C-leftdrag>", mc.handleMouseDrag)
noremap("n", "<C-leftrelease>", mc.handleMouseRelease)

mc.addKeymapLayer(function(layerSet)
  layerSet("n", "<esc>", function()
    if not mc.cursorsEnabled() then
      mc.enableCursors()
    else
      mc.clearCursors()
    end
  end)
end)

-- indentation guide lines
require('ibl').setup {
  indent = { char = '│' },
}

-- mini.nvim
require('mini.icons').setup()
require('mini.completion').setup()
require('mini.move').setup {
  mappings = {
    left = '<A-left>', right = '<A-right>', down = '<A-down>', up = '<A-up>',
    line_left = '<A-left>', line_right = '<A-right>', line_down = '<A-down>', line_up = '<A-up>',
  },
  options = {
    reindent_linewise = true,
  },
}
require('mini.tabline').setup()
require('mini.statusline').setup()
require('mini.pick').setup()
noremap_all('<C-b>', MiniPick.builtin.files)
noremap_all('<C-f>', MiniPick.builtin.grep_live)


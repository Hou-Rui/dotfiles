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

-- semi-transparent UI
vim.o.termguicolors = true
vim.o.pumblend = 10
vim.o.winblend = 10

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
local overrides = {}
for _, hi in pairs {
  'Normal', 'ColorColumn', 'SignColumn', 'FoldColumn',
  'WinSeparator', 'PmenuBorder'
} do
  overrides[hi] = { bg = 'None' }
end
for _, hi in pairs {
  'Pmenu', 'WildMenu', 'NormalFloat'
} do
  overrides[hi] = { blend = vim.o.pumblend }
end
ayu.setup {
  mirage = true,
  terminal = true,
  overrides = overrides,
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

-- icons
require('mini.icons').setup()

-- completions
require('mini.completion').setup()

-- move using Alt + direction keys
local move_mappings = {}
for _, d in pairs { 'left', 'right', 'down', 'up' } do
  local key = '<A-' .. d .. '>'
  move_mappings[d] = key
  move_mappings['line_' .. d] = key
end
require('mini.move').setup {
  mappings = move_mappings,
  options = {
    reindent_linewise = true,
  },
}

-- tab line
require('mini.tabline').setup()

vim.api.nvim_create_autocmd({ 'VimEnter', 'BufAdd', 'BufDelete' }, {
  desc = 'Hide the tabline when empty',
  group = group,
  callback = vim.schedule_wrap(function()
    local listed_buffers = vim.tbl_filter(function(buf)
      return vim.bo[buf].buflisted
    end, vim.api.nvim_list_bufs())
    vim.o.showtabline = #listed_buffers > 1 and 2 or 0
  end)
})

-- status line
require('mini.statusline').setup()

-- picker
require('mini.pick').setup()
noremap_all('<C-b>', MiniPick.builtin.files)
noremap_all('<C-f>', MiniPick.builtin.grep_live)


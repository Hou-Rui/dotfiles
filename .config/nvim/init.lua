-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git', '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- utilities
local autocmd = vim.api.nvim_create_autocmd
local keymap = vim.keymap.set

local function noremap(mode, lhs, rhs)
  if type(lhs) == 'table' then
    for _, key in pairs(lhs) do
      noremap(mode, key, rhs)
    end
    return
  end
  keymap(mode, lhs, rhs, {noremap = true})
end

local function noremap_all(lhs, rhs)
  noremap({'n', 'i', 'v'}, lhs, rhs)
end

local function file_assoc(pattern, filetype)
  autocmd({'BufRead', 'BufNewFile'}, {
    pattern = pattern,
    command = 'set filetype=' .. filetype,
  })
end

local function is_not_large_file()
  local threshold = 100 * 1024 * 1024 -- 100 MB
  return vim.fn.getfsize(vim.fn.expand('%')) < threshold
end

-- general settings
vim.o.number = true
vim.o.mouse = 'a'
vim.o.termguicolors = true
vim.o.autoindent = true
vim.o.signcolumn = 'yes'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.wildmenu = true
vim.o.wildmode = 'longest:list,full'

-- searching
vim.o.showmatch = true
vim.o.hlsearch = true
vim.o.incsearch = true

-- display invisible characters
vim.o.list = true
vim.o.listchars = 'tab:» ,space:·'

-- don't display border
vim.o.fillchars = 'vert:│,horiz:─'

-- auto read file
vim.o.autoread = true

-- semi-transparent popups
vim.o.pumblend = 8
vim.o.winblend = 8

-- open help on right side
autocmd('FileType', {
  pattern = 'help',
  command = 'wincmd L',
})

-- use Q rather than q to start record macro
keymap('n', 'Q', 'q')
keymap('n', 'q', '<nop>')

-- diagnostic signs
vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })

-- custom file association
file_assoc('*.qml', 'qml')
file_assoc('*.kvconfig', 'ini')

-- common Emacs-like editor hotkeys
-- copy
noremap('n', {'<C-c>', '<C-S-c>'}, '"+yy')
noremap('v', {'<C-c>', '<C-S-c>'}, '"+y')
-- cut
noremap('n', '<C-x>', 'dd')
noremap('v', '<C-x>', '"+d')
-- paste
noremap('n', '<C-v>', '"+p')
noremap('n', '<C-S-v>', '"+p')
-- go to line begin / end
noremap({'n', 'v'}, '<C-a>', '^')
noremap('i', '<C-a>', '<esc>^i')
noremap({'n', 'v'}, '<C-e>', '$')
noremap('i', '<C-e>', '<esc>$a')
-- delete word
noremap({'n', 'v'}, {'<C-w>', '<C-h>', '<C-bs>'}, 'bdW')
noremap('i', {'<C-w>', '<C-h>', '<C-bs>'}, '<esc>bdWa')
-- save
noremap_all('<C-s>', '<cmd>wa<cr>')
-- quit
noremap_all('<C-q>', '<cmd>qa<cr>')
-- search
noremap('n', '<C-f>', 'f')
noremap('v', '<C-f>', [[y/\V<C-R>=escape(@",'/\')<cr><cr>]])
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
-- swap lines
noremap('n', '<A-Up>', 'ddkP')
noremap('i', '<A-Up>', '<esc>ddkP')
noremap('n', '<A-Down>', 'ddp')
noremap('i', '<A-Down>', '<esc>ddp')
-- select all
noremap('n', '<A-a>', 'gg^vG$')
noremap({'i', 'x', 'v'}, '<A-a>', '<esc>gg^vG$')

-- set up plugins
local lazy = require('lazy')
lazy.setup(
  { -- plugin list
    -- color theme
    {
      'Shatur/neovim-ayu',
      config = function()
        local ayu = require('ayu')
        local bg_overrides = {}
        for _, hi in pairs {
          'Normal', 'NormalFloat', 'ColorColumn', 'SignColumn',
          'Folded', 'FoldColumn', 'CursorLine', 'CursorColumn',
          'CursorLine', 'CursorColumn', 'VertSplit', 'WinSeparator'
        } do
          bg_overrides[hi] = { bg = 'None' }
        end
        ayu.setup {
          mirage = true,
          overrides = bg_overrides
        }
        ayu.colorscheme()
      end
    },
    -- git integration
    {
      'lewis6991/gitsigns.nvim',
      config = true,
    },
    -- multi cursor
    {
      'mg979/vim-visual-multi',
      branch = 'master',
      init = function()
        vim.g.VM_theme = 'codedark'
        vim.g.VM_maps = {
          ['Find Under'] = '<C-d>',
          ['Find Subword Under'] = '<C-d>',
        }
        vim.g.VM_set_statusline = 0
      end
    },
    -- toggle comment
    {
      'tpope/vim-commentary',
      config = function()
        noremap({'n', 'v'}, '<C-_>', ':Commentary<cr>')
        noremap('i', '<C-_>', '<cmd>Commentary<cr>')
      end
    },
    -- sudo handling
    {
      'lambdalisue/suda.vim',
      init = function()
        if not vim.opt.diff:get() then
          vim.g.suda_smart_edit = true
        end
      end
    },
    -- neovim tree
    {
      'nvim-tree/nvim-tree.lua',
      version = "*",
      lazy = false,
      dependencies = {
        'nvim-tree/nvim-web-devicons',
      },
      config = function()
        -- disable netrw
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwplugin = 1
        require('nvim-tree').setup {}
        -- key mapping
        noremap({'n', 'i'}, '<C-b>', ':NvimTreeToggle<cr>')
      end,
    },
    -- editor config
    {
      "tpope/vim-sleuth",
    },
    -- indentation guide
    {
      "lukas-reineke/indent-blankline.nvim",
      main = 'ibl',
      opts = {
        indent = { char = '│' },
      },
    },
    -- tab line
    {
      'romgrk/barbar.nvim',
      opts = {
        animation = false,
        auto_hide = true,
      },
    },
    -- tree sitter
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      main = 'nvim-treesitter.configs',
      cond = is_not_large_file,
      opts = {
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        ignore_install = { 'help' },
      }
    },
    -- airline themes
    {
      'nvim-lualine/lualine.nvim',
      dependencies = {'nvim-tree/nvim-web-devicons'},
      opts = {
        options = {
          theme = "onedark",
          component_separators = {left = '', right = ''},
          section_separators = {left = '', right = ''},
        },
      }
    },
    -- formatting
    {
      'vim-autoformat/vim-autoformat',
      config = function()
        noremap({'n', 'v'}, 'ff', ':Autoformat')
      end
    },
    -- LSP
    {
      'saghen/blink.cmp',
      version = '*',
      cond = is_not_large_file,
      opts = {
        keymap = {
          preset = "enter"
        },
        sources = {
          default = { 'path', 'buffer' }
        },
      },
      opts_extend = { "sources.default" }
    }
  }, -- end of plugin list
  { -- lazy.nvim options
    install = {
      missing = true,
      colorscheme = {'ayu-mirage'},
    },
  }
)


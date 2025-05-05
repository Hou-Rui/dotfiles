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
  keymap(mode, lhs, rhs, opts)
end

local function noremap_all(lhs, rhs, options)
  noremap({'n', 'i', 'v'}, lhs, rhs, options)
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
noremap('n', 'Q', 'q')
noremap('n', 'q', '<nop>')

-- hide search highlights when press enter in command mode
noremap('n', '<cr>', '<cmd>noh<cr><cr>', {silent = true})

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
noremap('n', {'<C-w>', '<C-h>', '<C-bs>'}, 'vB"_d')
noremap('i', {'<C-h>', '<C-bs>'}, '<C-w>')
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
        vim.g.VM_mouse_mappings = 1
        vim.g.VM_maps = {
          ['Find Under'] = '<C-d>',
          ['Find Subword Under'] = '<C-d>',
        }
        vim.g.VM_set_statusline = 3 -- refresh
        vim.g.VM_silent_exit = 1
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
      config = function()
        local function vm_mode(mode)
          return vim.iter(string.gmatch(vim.fn['vm#themes#statusline'](), "%S+")):nth(2) or mode
        end

        local function vm_status()
          return vim.fn['VMInfos']().status or ''
        end

        require('lualine').setup {
          options = {
            theme = "ayu",
            component_separators = {left = '', right = ''},
            section_separators = {left = '', right = ''},
          },
          sections = {
            lualine_a = {{'mode', fmt = vm_mode}},
            lualine_b = {vm_status, 'branch', 'diff', 'diagnostics'},
          },
        }

        autocmd('CmdlineEnter', {
          pattern = {'@'},
          callback = function(ev)
            if vim.b.visual_multi then
              vim.defer_fn(function() vim.cmd('execute "redrawstatus"') end, 0)
            end
          end
        })
      end
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
          preset = "super-tab"
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


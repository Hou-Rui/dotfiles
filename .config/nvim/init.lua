-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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
noremap('n', '<C-c>', '"+yy')
noremap('n', '<C-S-c>', '"+yy')
noremap('v', '<C-c>', '"+y')
noremap('v', '<C-S-c>', '"+y')
-- cut
noremap('n', '<C-x>', 'dd')
noremap('v', '<C-x>', '"+d')
-- paste
noremap('n', '<C-v>', '"+p')
noremap('n', '<C-S-v>', '"+p')
-- go to line begin / end
noremap_all('<C-a>', '^')
noremap_all('<C-e>', '$')
-- close buffer
noremap_all('<C-w>', '<cmd>BufferClose<cr>')
-- save
noremap_all('<C-s>', '<cmd>wa<cr>')
-- quit
noremap_all('<C-q>', '<cmd>qa<cr>')
-- search
noremap('n', '<C-f>', 'f')
noremap('v', '<C-f>', [[y/\V<C-R>=escape(@",'/\')<cr><cr>]])
-- undo / redo
noremap_all('<C-z>', '<cmd>undo<cr>')
noremap_all('<C-y>', '<cmd>redo<cr>')
noremap_all('<C-S-z>', '<cmd>redo<cr>')
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
noremap({'i', 'n'}, '<A-Up>', 'ddkkp')
noremap({'i', 'n'}, '<A-Down>', 'ddp')

-- set up plugins
local lazy = require('lazy')
lazy.setup(
  { -- plugin list
    -- color theme
    {
      'Hou-Rui/ayu-vim',
      lazy = false,
      priority = 1000,
      init = function()
        vim.g.ayucolor = 'minimal'
        vim.cmd.colorscheme('ayu')
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
    "tpope/vim-sleuth",
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
    -- scroll bar
    {
      'petertriho/nvim-scrollbar',
      config = true,
    },
    -- tree sitter
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      main = 'nvim-treesitter.configs',
      opts = {
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      }
    },
    -- airline themes
    {
      'nvim-lualine/lualine.nvim',
      dependencies = {'nvim-tree/nvim-web-devicons'},
      opts = {
        options = {
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
      'VonHeikemen/lsp-zero.nvim',
      branch = 'v3.x',
      dependencies = {
        'williamboman/mason.nvim',
        'neovim/nvim-lspconfig',
        'williamboman/mason-lspconfig.nvim',
        'hrsh7th/nvim-cmp',
        'hrsh7th/cmp-nvim-lsp',
        'L3MON4D3/LuaSnip',
      },
      config = function()
        -- lsp_zero setup
        local lsp_zero = require('lsp-zero')
        lsp_zero.setup()
        lsp_zero.on_attach(function(_, bufnr)
          lsp_zero.default_keymaps { buffer = bufnr }
        end)
        -- mason & lspconfig setup
        require('mason').setup {}
        require('mason-lspconfig').setup {
          handlers = {
            lsp_zero.default_setup,
            lua_ls = function()
              local lua_opts = lsp_zero.nvim_lua_ls()
              require('lspconfig').lua_ls.setup(lua_opts)
            end,
          },
        }
        -- cmp setup
        local cmp = require('cmp')
        local mapping = cmp.mapping
        cmp.setup {
          sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
          },
          format = lsp_zero.cmp_format(),
          mapping = mapping.preset.insert {
            -- Enter/Tab key to confirm completion
            ['<cr>'] = mapping.confirm { select = false },
            ['<tab>'] = mapping.confirm { select = false },
            -- Scroll up and down in the completion documentation
            ['<C-k>'] = mapping.scroll_docs(-4),
            ['<C-j>'] = mapping.scroll_docs(4),
          }
        }
      end
    },
  }, -- end of plugin list
  { -- lazy.nvim options
    install = {
      missing = true,
      colorscheme = {'ayu'},
    },
  }
)




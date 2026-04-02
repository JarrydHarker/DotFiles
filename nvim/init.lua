-- Basic settings
vim.env.JAVA_HOME = '/usr/lib/jvm/java-21-amazon-corretto'
vim.g.mapleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = ''
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.clipboard = 'unnamedplus'
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = function(lines)
      local s = vim.base64.encode(table.concat(lines, '\n'))
      local esc = vim.env.TMUX
        and ('\027Ptmux;\027\027]52;c;%s\a\027\\'):format(s)
        or ('\027]52;c;%s\027\\'):format(s)
      vim.api.nvim_chan_send(2, esc)
    end,
    ['*'] = function(lines)
      local s = vim.base64.encode(table.concat(lines, '\n'))
      local esc = vim.env.TMUX
        and ('\027Ptmux;\027\027]52;c;%s\a\027\\'):format(s)
        or ('\027]52;c;%s\027\\'):format(s)
      vim.api.nvim_chan_send(2, esc)
    end,
  },
  paste = { ['+'] = function() return 0 end, ['*'] = function() return 0 end },
}

-- Install lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require('lazy').setup({
  -- Colorscheme
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- OSC52 clipboard (nvim 0.11+ built-in)
  -- No plugin needed; just set the clipboard provider


  -- fzf-lua for fast fuzzy finding
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup({
        winopts = {
          height = 0.85,
          width = 0.80,
          preview = {
            layout = 'vertical',
            vertical = 'down:45%',
          },
        },
        files = {
          cmd = 'rg --files --ignore-case',
        },
        grep = {
          rg_opts = '--column --line-number --no-heading --color=always --smart-case --ignore-case',
        },
      })
    end,
    keys = {
      { '<leader>ff', '<cmd>FzfLua files<cr>', desc = 'Find Files' },
      { '<leader>fg', '<cmd>FzfLua live_grep<cr>', desc = 'Live Grep' },
      { '<leader>fb', '<cmd>FzfLua buffers<cr>', desc = 'Buffers' },
    },
  },

  -- Neo-tree file explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    config = function()
      require('neo-tree').setup({
        filesystem = {
          follow_current_file = {
            enabled = false,
          },
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
            never_show = {},
          },
          group_empty_dirs = false,
        },
        enable_git_status = true,
        enable_diagnostics = true,
        git_status_async = true,
      })
    end,
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle File Explorer' },
    },
  },

  -- Gitsigns for git decorations
  {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup({
        current_line_blame = true,
        current_line_blame_opts = {
          delay = 500,
        },
      })
    end,
  },

  -- Autopairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup()
    end,
  },

  -- Comment.nvim
  {
    'numToStr/Comment.nvim',
    keys = {
      { 'gcc', mode = 'n', desc = 'Comment line' },
      { 'gc', mode = 'v', desc = 'Comment selection' },
    },
    config = function()
      require('Comment').setup()
    end,
  },

  -- Which-key
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      require('which-key').setup()
    end,
  },

  -- Lualine statusline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'tokyonight',
        },
      })
    end,
  },

  -- Bufferline
  {
    'akinsho/bufferline.nvim',
    version = '*',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup()
    end,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    config = function()
      require('ibl').setup()
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local ok, configs = pcall(require, 'nvim-treesitter.configs')
      if not ok then return end
      configs.setup({
        ensure_installed = { 'lua', 'python', 'javascript', 'typescript', 'java', 'bash', 'json', 'yaml' },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Trouble for diagnostics
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('trouble').setup()
    end,
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>', desc = 'Diagnostics' },
      { '<leader>xd', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', desc = 'Buffer Diagnostics' },
    },
  },

  -- Surround for quotes/brackets
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup()
    end,
  },



  -- Better text objects
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    config = function()
      require('mini.ai').setup()
    end,
  },

  -- Colorizer
  {
    'norcalli/nvim-colorizer.lua',
    config = function()
      require('colorizer').setup()
    end,
  },

  -- Mason for LSP installer
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'lua_ls', 'pyright', 'ts_ls' },
      })
    end,
  },

  -- LSP config
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason-lspconfig.nvim', 'saghen/blink.cmp' },
    config = function()
      local lspconfig = require('lspconfig')
      local capabilities = require('blink.cmp').get_lsp_capabilities()
      
      -- Auto-setup installed servers
      local mason_lspconfig = require('mason-lspconfig')
      if mason_lspconfig.setup_handlers then
        mason_lspconfig.setup_handlers({
          function(server_name)
            lspconfig[server_name].setup({ capabilities = capabilities })
          end,
        })
      end
      
      -- LSP keybindings
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
        end,
      })
    end,
  },

  -- Completion with blink.cmp (faster, Rust-based)
  {
    'saghen/blink.cmp',
    version = '*',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
    },
    opts = {
      keymap = {
        preset = 'default',
        ['<Tab>'] = { 'select_and_accept' },
        ['<C-j>'] = { 'select_next' },
        ['<C-k>'] = { 'select_prev' },
        ['<Down>'] = { 'select_next' },
        ['<Up>'] = { 'select_prev' },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono',
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },
})

-- Show diagnostic sign only, float on cursor hold
vim.diagnostic.config({ virtual_text = false })
vim.opt.updatetime = 500
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    vim.diagnostic.open_float(nil, { focusable = false, scope = 'cursor' })
  end,
})

require('config.keymaps')

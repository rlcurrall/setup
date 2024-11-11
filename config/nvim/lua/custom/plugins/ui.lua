return {
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    init = function ()
      vim.cmd.colorscheme 'tokyonight-night'
      vim.cmd.hi 'Comment gui=none'
    end
  },

  -- {
  --   'rose-pine/neovim',
  --   name = 'rose-pine',
  --   lazy = false,
  --   priority = 1000,
  --   opts = {
  --     disable_background = true,
  --     styles = {
  --       transparency = true,
  --     },
  --   },
  --   init = function()
  --     vim.cmd.colorscheme 'rose-pine-moon'
  --     vim.cmd.hi 'Comment gui=none'
  --
  --     -- vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  --     -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
  --   end,
  -- },

  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      views = {
        cmdline_popup = {
          position = { row = 5, col = '50%' },
          size = { width = 60, height = 'auto' },
        },
        popupmenu = {
          relative = 'editor',
          position = { row = 8, col = '50%' },
          size = { width = 60, height = 10 },
          border = {
            style = 'rounded',
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
          },
        },
      },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',

      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
  },

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require('which-key').setup()

      -- Document existing key chains
      require('which-key').add {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      }
    end,
  },

  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.cmd.colorscheme 'tokyonight-night'
      end,
      set_light_mode = function()
        vim.cmd.colorscheme 'tokyonight-day'
      end,
    },
  },
}

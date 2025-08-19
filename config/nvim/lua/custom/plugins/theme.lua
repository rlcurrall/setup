return {
  -- -- Tokyo Night theme
  -- {
  --   'folke/tokyonight.nvim',
  --   lazy = false,
  --   priority = 1000,
  --   opts = {},
  --   init = function()
  --     vim.cmd.colorscheme 'tokyonight-storm'
  --     vim.cmd.hi 'Comment gui=none'
  --   end,
  -- },
  --
  -- {
  --   'f-person/auto-dark-mode.nvim',
  --   opts = {
  --     update_interval = 1000,
  --     set_dark_mode = function()
  --       vim.cmd.colorscheme 'tokyonight-storm'
  --     end,
  --     set_light_mode = function()
  --       vim.cmd.colorscheme 'tokyonight-day'
  --     end,
  --   },
  -- },

  -- -- Rose Pine theme
  -- {
  --   'rose-pine/neovim',
  --   name = 'rose-pine',
  --   lazy = false,
  --   priority = 1000,
  --   opts = {},
  --   init = function()
  --     vim.cmd.colorscheme 'rose-pine-moon'
  --     vim.cmd.hi 'Comment gui=none'
  --   end,
  -- },
  --
  -- {
  --   'f-person/auto-dark-mode.nvim',
  --   opts = {
  --     update_interval = 1000,
  --     set_dark_mode = function()
  --       vim.cmd.colorscheme 'rose-pine-moon'
  --     end,
  --     set_light_mode = function()
  --       vim.cmd.colorscheme 'rose-pine-dawn'
  --     end,
  --   },
  -- },

  -- Catppuccin theme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      vim.cmd.colorscheme 'catppuccin-frappe'
      vim.cmd.hi 'Comment gui=none'
    end,
  },

  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.cmd.colorscheme 'catppuccin-frappe'
      end,
      set_light_mode = function()
        vim.cmd.colorscheme 'catppuccin-latte'
      end,
    },
  },
}

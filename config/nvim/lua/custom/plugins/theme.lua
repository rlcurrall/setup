return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      vim.cmd.colorscheme 'tokyonight-storm'
      vim.cmd.hi 'Comment gui=none'
    end,
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
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.cmd.colorscheme 'tokyonight-storm'
      end,
      set_light_mode = function()
        vim.cmd.colorscheme 'tokyonight-day'
      end,
    },
  },
}

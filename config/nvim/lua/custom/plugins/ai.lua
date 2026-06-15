return {
  -- { 'zbirenbaum/copilot.lua', opts = {} },
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup {}
    end,
  },
}

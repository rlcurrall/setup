return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  {
    'folke/zen-mode.nvim',
    keys = {
      { '<leader>z', ':ZenMode<CR>', desc = 'Toggle Zen Mode' },
    },
    opts = {
      {
        window = {
          backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
          options = {
            -- signcolumn = "no", -- disable signcolumn
            -- number = false, -- disable number column
            -- relativenumber = false, -- disable relative numbers
            -- cursorline = false, -- disable cursorline
            -- cursorcolumn = false, -- disable cursor column
            -- foldcolumn = "0", -- disable fold column
            -- list = false, -- disable whitespace characters
          },
        },
        plugins = {
          options = {
            enabled = true,
            ruler = false, -- disables the ruler text in the cmd line area
            showcmd = false, -- disables the command in the last line of the screen
            laststatus = 0, -- turn off the statusline in zen mode
          },
          todo = { enabled = true }, -- if set to "true", todo-comments.nvim highlights will be disabled
          wezterm = {
            enabled = true,
            font = '+4', -- (10% increase per step)
          },
        },
        on_open = function(win) end,
        on_close = function() end,
      },
    },
  },
}

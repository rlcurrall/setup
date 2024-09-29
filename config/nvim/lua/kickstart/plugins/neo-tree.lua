-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '<leader>e', ':Neotree focus filesystem right<CR>', desc = 'Open File Explorer' },
    { '<leader>g', ':Neotree focus git_status right<CR>', desc = 'Open Git Status' },
    { '<leader>b', ':Neotree focus buffers right<CR>', desc = 'Open Buffers' },
  },
  opts = {
    close_if_last_window = true,
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
  },
}

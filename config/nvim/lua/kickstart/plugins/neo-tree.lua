-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    '3rd/image.nvim', -- Add image support in preview window
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree focus filesystem right<CR>', desc = 'Open File Explorer' },
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

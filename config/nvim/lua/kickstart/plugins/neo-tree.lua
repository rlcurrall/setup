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
    { '\\', ':Neotree focus filesystem right<CR>', desc = 'Open File Explorer' },
  },
  opts = {
    close_if_last_window = true,
    source_selector = {
      winbar = false,
      statusline = true,
    },
    window = {
      mappings = {
        ['\\'] = 'close_window',
      },
    },
    filesystem = {
      hijack_netrw_behavior = 'open_default',
      follow_current_file = {
        enabled = false,
        leave_dirs_open = true,
      },
    },
  },
}

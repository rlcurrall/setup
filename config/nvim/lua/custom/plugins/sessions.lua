return {
  {
    'rmagatti/auto-session',
    lazy = false,
    keys = {
      { '<leader>wr', '<cmd>AutoSession search<CR>', desc = 'Session search' },
    },
    opts = {
      session_lens = {
        picker = 'snacks',
        load_on_setup = false,
        previewer = false,
        mappings = {
          -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
          delete_session = { 'i', '<C-D>' },
          alternate_session = { 'i', '<C-S>' },
          copy_session = { 'i', '<C-Y>' },
        },
      },
    },
  },
}

return {
  {
    'saghen/blink.cmp',
    version = '1.*',
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      keymap = {
        preset = 'default',
        ['<C-l>'] = { 'snippet_forward', 'fallback' },
        ['<C-h>'] = { 'snippet_backward', 'fallback' },
      },
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = { auto_show = true },
        accept = { auto_brackets = { enabled = true } },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = { lua = { inherit_defaults = true, 'lazydev' } },
        providers = {
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },
      snippets = { preset = 'default' }, -- Neovim's native snippet engine.
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
  },
}

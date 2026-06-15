-- code folding

return {
  {
    'chrisgrieser/nvim-origami',
    event = 'VeryLazy',
    opts = {
      useLspFoldsWithTreesitterFallback = {
        enabled = true,
      },
      pauseFoldsOnSearch = true,
      foldtext = {
        enabled = true,
        padding = {
          character = ' ',
          width = 3,
        },
        lineCount = {
          template = '%d lines',
          hlgroup = 'Comment',
        },
        diagnosticsCount = true,
        gitsignsCount = true,
      },
      autoFold = {
        enabled = true,
        kinds = { 'comment', 'imports' },
      },
      foldKeymaps = {
        setup = true,
        closeOnlyOnFirstColumn = false,
      },
    },
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
  },
}

-- code folding

return {
  {
    'chrisgrieser/nvim-origami',
    event = 'VeryLazy',
    opts = {
      useLspFoldsWithTreesitterFallback = true,
      pauseFoldsOnSearch = true,
      foldtext = {
        enabled = true,
        padding = 3,
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
        hOnlyOpensOnFirstColumn = false,
      },
    },
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
  },
}

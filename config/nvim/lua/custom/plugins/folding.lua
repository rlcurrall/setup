-- code folding

return {
  {
    'chrisgrieser/nvim-origami',
    event = 'BufReadPost',
    opts = {},
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    event = 'UIEnter',
    init = function()
      vim.opt.foldlevel = 99
      vim.opt.foldlevelstart = 99
    end,
    opts = {
      provider_selector = function(_, ft, _)
        local lspWithOutFolding = { 'markdown', 'sh', 'css', 'html', 'python', 'json', 'powershell' }
        if vim.tbl_contains(lspWithOutFolding, ft) then
          return { 'treesitter', 'indent' }
        end
        return { 'lsp', 'indent' }
      end,
      close_fold_kinds_for_ft = {
        default = { 'imports', 'comment' },
      },
      open_fold_hl_timeout = 800,
    },
  },
}

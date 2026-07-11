return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      -- Parsers to install. On the `main` branch there is no `auto_install`;
      -- parsers are installed explicitly (or on demand via `:TSInstall`).
      local ensure_installed = {
        'bash',
        'c',
        'c_sharp',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      }

      require('nvim-treesitter').install(ensure_installed)

      -- The `main` branch no longer enables highlighting/indent for you.
      -- Start Treesitter on ANY buffer whose filetype has a parser available,
      -- so new languages "just work" once their parser is installed.
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          if not lang then
            return
          end

          if not pcall(vim.treesitter.language.add, lang) then
            return
          end

          if not pcall(vim.treesitter.start, args.buf, lang) then
            return
          end

          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}

return {
  -- LSP Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'mason-org/mason.nvim', config = true }, -- NOTE: Must be loaded before dependents
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Completion capabilities from Blink
      'saghen/blink.cmp',

      -- JSON schemas
      'b0o/schemastore.nvim',
    },
    config = function()
      require('custom.lsp').setup()

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      require('mason-tool-installer').setup {
        ensure_installed = {
          'clangd',
          'rust_analyzer',
          'powershell_es',
          'eslint',
          'jsonls',
          'lua_ls',
          'ts_ls',
          'html',
          'stylua',
          'csharpier',
          'js-debug-adapter',
        },
      }

      -- Apply completion capabilities to all servers
      vim.lsp.config('*', { capabilities = capabilities })

      vim.lsp.config('eslint', {
        root_markers = { 'package.json', '.git' },
      })

      vim.lsp.config('jsonls', {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      })

      -- Use Neovim's LSP client for TypeScript and JavaScript, too.
      vim.lsp.config('ts_ls', {
        init_options = {
          preferences = {
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          },
        },
      })

      -- Configure servers before Mason enables them for matching buffers.
      require('mason-lspconfig').setup {
        -- Conform handles StyLua; roslyn.nvim activates the C# server.
        automatic_enable = { exclude = { 'stylua', 'roslyn_ls' } },
      }
    end,
  },
  {
    'seblyng/roslyn.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    build = function()
      require('custom.tools').install 'roslyn'
    end,
    opts = {},
    config = function(_, opts)
      require('custom.tools').ensure 'roslyn'
      vim.lsp.config('roslyn', {
        cmd = { require('custom.tools').roslyn_path(), '--stdio' },
        settings = {
          ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_types = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = false,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = false,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = false,
          },
          ['csharp|completion'] = { dotnet_show_completion_items_from_unimported_namespaces = true },
        },
      })
      require('roslyn').setup(opts)
    end,
  },
}

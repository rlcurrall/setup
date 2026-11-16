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
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', function()
            Snacks.picker.lsp_definitions()
          end, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', function()
            Snacks.picker.lsp_references()
          end, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', function()
            Snacks.picker.lsp_implementations()
          end, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', function()
            Snacks.picker.lsp_type_definitions()
          end, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', function()
            Snacks.picker.lsp_symbols()
          end, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', function()
            Snacks.picker.lsp_workspace_symbols()
          end, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
            map('<leader>tj', function()
              local new_config = not vim.diagnostic.config().virtual_lines
              vim.diagnostic.config { virtual_lines = new_config }
            end, 'Toggle diagnostic virtual_lines')
          end
        end,
      })

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

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
      { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependents
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- Useful status updates for LSP.
      { 'j-hui/fidget.nvim', opts = {} },

      -- Allows extra capabilities provided by nvim-cmp
      'hrsh7th/cmp-nvim-lsp',

      -- JSON schemas
      'b0o/schemastore.nvim',

      -- csharp
      { 'Hoffs/omnisharp-extended-lsp.nvim', lazy = true },
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
          map('gd', function() Snacks.picker.lsp_definitions() end, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', function() Snacks.picker.lsp_references() end, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', function() Snacks.picker.lsp_implementations() end, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', function() Snacks.picker.lsp_type_definitions() end, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', function() Snacks.picker.lsp_symbols() end, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', function() Snacks.picker.lsp_workspace_symbols() end, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

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

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      require('mason').setup()

      require('mason-tool-installer').setup {
        ensure_installed = {
          'clangd',
          'rust_analyzer',
          'powershell_es',
          'eslint',
          'jsonls',
          'lua_ls',
          'stylua',
          'omnisharp',
          'csharpier',
          'json-lsp',
        },
      }

      require('mason-lspconfig').setup {
        -- stylua is a formatter managed by conform, not an LSP server
        automatic_enable = {
          exclude = { 'stylua' },
        },
      }

      -- Apply cmp-nvim-lsp capabilities to all servers
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

      vim.lsp.config('omnisharp', {
        on_attach = function(_, bufnr)
          vim.keymap.set('n', 'gd', "<cmd>lua require('omnisharp_extended').lsp_definition()<cr>", { buffer = bufnr, desc = 'Goto [d]efinition' })
          vim.keymap.set('n', 'gr', "<cmd>lua require('omnisharp_extended').lsp_references()<cr>", { buffer = bufnr, desc = 'Goto [r]eferences' })
          vim.keymap.set('n', 'gI', "<cmd>lua require('omnisharp_extended').lsp_implementation()<cr>", { buffer = bufnr, desc = 'Goto [I]mplementation' })
          vim.keymap.set('n', 'gD', "<cmd>lua require('omnisharp_extended').lsp_type_definition()<cr>", { buffer = bufnr, desc = 'Goto Type [D]efinition' })
        end,
        root_dir = function(fname)
          return vim.fs.root(fname, function(dir)
            return vim.fn.glob(dir .. '/*.sln') ~= '' or vim.fn.glob(dir .. '/*.csproj') ~= ''
          end)
        end,
        enable_roslyn_analyzers = true,
        organize_imports_on_format = true,
        enable_import_completion = true,
        settings = {
          FormattingOptions = {
            EnableEditorConfigSupport = true,
            OrganizeImports = true,
          },
          MsBuild = { LoadProjectsOnDemand = nil },
          RoslynExtensionsOptions = {
            EnableAnalyzersSupport = true,
            EnableImportCompletion = true,
            AnalyzeOpenDocumentsOnly = nil,
            EnableDecompilationSupport = true,
            InlayHintsOptions = {
              EnableForParameters = true,
              ForLiteralParameters = true,
              ForIndexerParameters = true,
              ForObjectCreationParameters = true,
              ForOtherParameters = true,
              SuppressForParametersThatDifferOnlyBySuffix = false,
              SuppressForParametersThatMatchMethodIntent = false,
              SuppressForParametersThatMatchArgumentName = false,
              EnableForTypes = true,
              ForImplicitVariableTypes = true,
              ForLambdaParameterTypes = true,
              ForImplicitObjectCreation = true,
            },
          },
          Sdk = { IncludePrereleases = true },
        },
      })


    end,
  },

  { -- Add TypeScript Support
    'pmizio/typescript-tools.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' },
    opts = {
      settings = {
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
        -- Enable project-wide TypeScript support for monorepos
        tsserver_plugins = {},
        -- Ensure it finds the root tsconfig.json
        root_dir = function(fname)
          local util = require('lspconfig.util')
          return util.root_pattern('tsconfig.json', 'package.json', '.git')(fname)
        end,
      },
    },
  },
}

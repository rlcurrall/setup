-- Buffer-local LSP shortcuts and inlay-hint preferences.
local M = {}

function M.on_attach(event)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
  end

  map('gd', function()
    Snacks.picker.lsp_definitions()
  end, '[G]oto [D]efinition')

  map('gr', function()
    Snacks.picker.lsp_references()
  end, '[G]oto [R]eferences')

  map('gI', function()
    Snacks.picker.lsp_implementations()
  end, '[G]oto [I]mplementation')

  map('<leader>D', function()
    Snacks.picker.lsp_type_definitions()
  end, 'Type [D]efinition')

  map('<leader>ds', function()
    Snacks.picker.lsp_symbols()
  end, '[D]ocument [S]ymbols')

  map('<leader>ws', function()
    Snacks.picker.lsp_workspace_symbols()
  end, '[W]orkspace [S]ymbols')

  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

  map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
    -- Default C# hints on once; preserve this buffer's choice across
    -- buffer switches, additional clients, and LSP restarts.
    if vim.b[event.buf].custom_inlay_hints == nil then
      vim.b[event.buf].custom_inlay_hints = vim.bo[event.buf].filetype == 'cs' or vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
    end
    vim.lsp.inlay_hint.enable(vim.b[event.buf].custom_inlay_hints, { bufnr = event.buf })
    map('<leader>th', function()
      local enabled = not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }
      vim.b[event.buf].custom_inlay_hints = enabled
      vim.lsp.inlay_hint.enable(enabled, { bufnr = event.buf })
    end, '[T]oggle Inlay [H]ints')
  end
  -- Diagnostics do not depend on the server supporting inlay hints.
  map('<leader>tj', function()
    local new_config = not vim.diagnostic.config().virtual_lines
    vim.diagnostic.config { virtual_lines = new_config }
  end, 'Toggle diagnostic virtual_lines')
end

function M.setup()
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('CustomLspAttach', { clear = true }),
    callback = M.on_attach,
  })
end

return M

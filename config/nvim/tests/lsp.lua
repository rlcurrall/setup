return function(T)
  local lsp = require 'custom.lsp'
  T.test('LSP setup registers only one attach callback', function()
    lsp.setup()
    lsp.setup()
    local callbacks = vim.api.nvim_get_autocmds { event = 'LspAttach', group = 'CustomLspAttach' }
    T.equal(#callbacks, 1)
    assert(type(callbacks[1].callback) == 'function')
  end)

  T.test('inlay preferences stay buffer-local across switches and reattachments', function()
    local hints = vim.lsp.inlay_hint
    local lookup = vim.lsp.get_client_by_id
    T.defer(function()
      vim.lsp.get_client_by_id = lookup
    end)
    vim.lsp.get_client_by_id = function(id)
      return {
        supports_method = function(_, method)
          return id ~= 99 and method == vim.lsp.protocol.Methods.textDocument_inlayHint
        end,
      }
    end
    local base = T.tempdir()
    local function buffer(name, filetype)
      local buf = vim.api.nvim_create_buf(false, true)
      T.defer(function()
        vim.api.nvim_buf_delete(buf, { force = true })
      end)
      vim.api.nvim_buf_set_name(buf, base .. '/' .. name)
      vim.bo[buf].filetype = filetype
      return buf
    end
    local function enabled(buf)
      return hints.is_enabled { bufnr = buf }
    end
    local function attach(buf, id)
      lsp.on_attach { buf = buf, data = { client_id = id or 1 } }
    end
    local function call(buf, key)
      vim.api.nvim_set_current_buf(buf)
      local map = vim.fn.maparg(key, 'n', false, true)
      assert(type(map.callback) == 'function', 'Missing mapping: ' .. key)
      map.callback()
    end
    local global_default = hints.is_enabled()
    local a, b = buffer('A.cs', 'cs'), buffer('B.cs', 'cs')
    attach(a)
    attach(b)
    assert(enabled(a) and enabled(b), 'C# hints should start on')
    call(a, '<leader>th')
    assert(not enabled(a) and enabled(b), 'Toggle leaked to another buffer')
    vim.api.nvim_set_current_buf(b)
    vim.api.nvim_set_current_buf(a)
    assert(not enabled(a), 'Buffer switch reset preference')
    attach(a, 2)
    assert(not enabled(a), 'Additional client reset preference')
    hints.enable(false, { bufnr = b }) -- Simulate native LspDetach cleanup.
    attach(b, 3)
    assert(enabled(b), 'Reattachment did not restore on preference')
    attach(a, 3)
    assert(not enabled(a), 'Reattachment reset off preference')
    local ts = buffer('app.ts', 'typescript')
    attach(ts)
    T.equal(enabled(ts), global_default, 'TypeScript default changed')
    call(ts, '<leader>th')
    T.equal(enabled(ts), not global_default)
    assert(not enabled(a) and enabled(b))
    T.equal(hints.is_enabled(), global_default)
    local plain = buffer('plain.txt', 'text')
    attach(plain, 99)
    vim.api.nvim_set_current_buf(plain)
    assert(vim.tbl_isempty(vim.fn.maparg('<leader>th', 'n', false, true)))
    local virtual = vim.diagnostic.config().virtual_lines
    T.defer(function()
      vim.diagnostic.config { virtual_lines = virtual }
    end)
    call(plain, '<leader>tj')
    T.equal(vim.diagnostic.config().virtual_lines, not virtual, 'Diagnostics require an inlay-capable server')
    -- All navigation maps are buffer-local even without inlay support.
    for _, key in ipairs { 'gd', 'gr', 'gI', '<leader>D', '<leader>ds', '<leader>ws', '<leader>rn', '<leader>ca', 'gD' } do
      T.equal(vim.fn.maparg(key, 'n', false, true).buffer, 1, key)
    end
  end)
end

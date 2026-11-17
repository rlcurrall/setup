-- Run from any directory: nvim --clean --headless -l /path/to/tests/run.lua
local tests = vim.fs.dirname(vim.fs.abspath(debug.getinfo(1, 'S').source:sub(2)))
local config = vim.fs.dirname(tests)
vim.opt.rtp:prepend(config)
package.path = tests .. '/?.lua;' .. package.path
vim.g.mapleader = ' '

local T = { passed = 0, failed = 0, integration = vim.tbl_contains(vim.v.argv, '--integration') }
local cleanup
function T.defer(fn)
  cleanup[#cleanup + 1] = fn
end
function T.tempdir()
  local path = vim.fs.normalize(vim.fn.tempname())
  vim.fn.mkdir(path, 'p')
  T.defer(function()
    vim.fn.delete(path, 'rf')
  end)
  return path
end
function T.file(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  assert(vim.fn.writefile(lines or {}, path) == 0)
end
function T.equal(actual, expected, message)
  assert(vim.deep_equal(actual, expected), (message or 'Values differ') .. '\nexpected: ' .. vim.inspect(expected) .. '\nactual: ' .. vim.inspect(actual))
end
function T.test(name, fn)
  cleanup = {}
  local ok, err = xpcall(fn, debug.traceback)
  -- Avoid switching back to fixture files while cleanup deletes buffers/files.
  vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(false, true))
  for i = #cleanup, 1, -1 do
    local cleaned, problem = pcall(cleanup[i])
    if not cleaned then
      ok, err = false, tostring(err or '') .. '\nCleanup: ' .. tostring(problem)
    end
  end
  if ok then
    T.passed = T.passed + 1
    print('PASS ' .. name)
  else
    T.failed = T.failed + 1
    io.stderr:write('FAIL ' .. name .. '\n' .. tostring(err) .. '\n')
  end
end

for _, suite in ipairs { 'paths', 'project', 'lsp' } do
  local ok, err = xpcall(function()
    require(suite)(T)
  end, debug.traceback)
  if not ok then
    T.failed = T.failed + 1
    io.stderr:write('FAIL loading ' .. suite .. '\n' .. err .. '\n')
  end
end
print(('%d passed, %d failed%s'):format(T.passed, T.failed, T.integration and ' (including integration tests)' or ''))
vim.cmd(T.failed == 0 and 'qa!' or 'cquit 1')

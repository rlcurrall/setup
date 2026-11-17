-- Buffer-local project shortcuts, using the nearest project or repository root.
local M = {}

local markers = {
  ['.git'] = true,
  ['.nvim.lua'] = true,
  ['package.json'] = true,
  ['Cargo.toml'] = true,
  ['pyproject.toml'] = true,
  ['requirements.txt'] = true,
  ['setup.py'] = true,
}

local function dotnet_marker(name)
  return name:match '%.csproj$' or name:match '%.sln$' or name:match '%.slnx$'
end

function M.find_root(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].buftype ~= '' or vim.api.nvim_buf_get_name(bufnr) == '' then
    return nil
  end
  -- One predicate gives all markers equal priority: a nested package/project
  -- wins over an ancestor repository, and .git also bounds the upward search.
  return vim.fs.root(bufnr, function(name)
    return markers[name] or dotnet_marker(name) ~= nil
  end)
end

local function run(root, args)
  local cwd = vim.fn.getcwd()
  local restore = vim.fn.haslocaldir() == 1 and 'lcd' or (vim.fn.haslocaldir(-1) == 1 and 'tcd' or 'cd')
  local function directory(command, path)
    vim.api.nvim_cmd({ cmd = command, args = { path }, magic = { file = false }, mods = { noautocmd = true } }, {})
  end
  -- Preserve the existing :! output/interactive workflow, without changing
  -- Neovim's working directory or its global/tab/window scope afterwards.
  directory('lcd', root)
  local ok, err = pcall(function()
    local escaped = vim.tbl_map(function(arg)
      return vim.fn.shellescape(arg, 1)
    end, args)
    vim.cmd('!' .. table.concat(escaped, ' '))
  end)
  directory(restore, cwd)
  if not ok then
    error(err)
  end
end

function M.setup_project_settings(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  for _, key in ipairs(vim.b[bufnr].custom_project_keys or {}) do
    pcall(vim.keymap.del, 'n', key, { buffer = bufnr })
  end
  vim.b[bufnr].custom_project_keys = {}

  local root = M.find_root(bufnr)
  if not root then
    return
  end
  local keys, files, dotnet = {}, {}, false
  for name in vim.fs.dir(root) do
    files[name] = true
    dotnet = dotnet or dotnet_marker(name) ~= nil
  end
  local function map(key, args, desc)
    keys[#keys + 1] = key
    vim.keymap.set('n', key, function()
      run(root, type(args) == 'function' and args() or args)
    end, { desc = desc, buffer = bufnr })
  end

  if dotnet then
    map('<leader>cb', { 'dotnet', 'build' }, 'Build C# project')
    map('<leader>ct', { 'dotnet', 'test' }, 'Run C# tests')
    map('<leader>cr', { 'dotnet', 'run' }, 'Run C# project')
  end
  if files['package.json'] then
    map('<leader>ni', { 'npm', 'install' }, 'npm install')
    map('<leader>nt', { 'npm', 'test' }, 'npm test')
    map('<leader>nr', { 'npm', 'run', 'dev' }, 'npm run dev')
    map('<leader>nb', { 'npm', 'run', 'build' }, 'npm run build')
  end
  if files['Cargo.toml'] then
    map('<leader>rb', { 'cargo', 'build' }, 'Cargo build')
    map('<leader>rt', { 'cargo', 'test' }, 'Cargo test')
    map('<leader>rr', { 'cargo', 'run' }, 'Cargo run')
    map('<leader>rc', { 'cargo', 'check' }, 'Cargo check')
  end
  if files['pyproject.toml'] or files['requirements.txt'] or files['setup.py'] then
    map('<leader>pr', function()
      return { 'python', vim.api.nvim_buf_get_name(bufnr) }
    end, 'Run Python file')
    map('<leader>pt', { 'python', '-m', 'pytest' }, 'Run pytest')
  end
  vim.b[bufnr].custom_project_keys = keys
end

function M.setup()
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile', 'BufFilePost' }, {
    group = vim.api.nvim_create_augroup('ProjectConfig', { clear = true }),
    callback = function(event)
      M.setup_project_settings(event.buf)
    end,
  })
end

return M

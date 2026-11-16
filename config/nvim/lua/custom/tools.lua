local M = {}
local function is_windows()
  return vim.fn.has 'win32' == 1
end
local function path(...)
  return vim.fs.joinpath(vim.fn.stdpath 'data', 'tools', ...)
end
function M.roslyn_path()
  return path('roslyn', 'roslyn-language-server' .. (is_windows() and '.exe' or ''))
end
function M.debugger_path()
  return path('netcoredbg', 'current', 'netcoredbg' .. (is_windows() and '.exe' or ''))
end
function M.install(kind)
  local scripts = vim.fs.joinpath(vim.fn.stdpath 'config', 'scripts')
  local cmd
  if is_windows() then
    cmd = {
      vim.fn.executable 'pwsh' == 1 and 'pwsh' or 'powershell',
      '-NoProfile',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      vim.fs.joinpath(scripts, 'install-tools.ps1'),
      kind,
    }
  else
    cmd = { 'sh', vim.fs.joinpath(scripts, 'install-tools.sh'), kind }
  end
  local result = vim.system(cmd, { text = true, env = { NVIM_TOOLS_DATA = vim.fn.stdpath 'data' } }):wait()
  if result.code ~= 0 then
    error('Unable to install ' .. kind .. ':\n' .. (result.stderr or '') .. (result.stdout or ''))
  end
end
function M.ensure(kind)
  local pins = vim.json.decode(table.concat(vim.fn.readfile(vim.fs.joinpath(vim.fn.stdpath 'config', 'scripts', 'tool-versions.json')), '\n'))
  local exe = kind == 'roslyn' and M.roslyn_path() or M.debugger_path()
  local expected = kind == 'roslyn' and pins.roslyn or pins.netcoredbg
  local stamp = vim.fs.joinpath(vim.fs.dirname(exe), '.version')
  local installed = vim.fn.filereadable(stamp) == 1 and vim.trim(table.concat(vim.fn.readfile(stamp), '\n')) or ''
  if vim.fn.executable(exe) ~= 1 or installed ~= expected then
    vim.notify('Installing configured ' .. kind .. ' tools…', vim.log.levels.INFO)
    M.install(kind)
  end
end
return M

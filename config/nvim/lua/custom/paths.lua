-- Keep plugin pins writable for standalone configs and read-only deployments.
local M = {}

local function writable(path)
  local stat = vim.uv.fs_stat(path)
  if stat then
    return stat.type == 'file' and vim.fn.filewritable(path) == 1
  end
  local parent = vim.fs.dirname(path)
  while not vim.uv.fs_stat(parent) do
    local ancestor = vim.fs.dirname(parent)
    if parent == ancestor then
      return false
    end
    parent = ancestor
  end
  return vim.fn.filewritable(parent) == 2
end

local function prepare(path, shipped)
  assert(writable(path), 'Lazy lockfile is not writable: ' .. path)
  vim.fn.mkdir(vim.fs.dirname(path), 'p')
  -- Seed an external lockfile once; never replace existing user pins.
  if not vim.uv.fs_stat(path) and vim.fn.filereadable(shipped) == 1 then
    local ok, err = vim.uv.fs_copyfile(shipped, path)
    assert(ok, 'Cannot seed Lazy lockfile: ' .. tostring(err))
    -- fs_copyfile preserves read-only source permissions (e.g. the Nix store).
    local chmod_ok, chmod_err = vim.uv.fs_chmod(path, 420) -- 0644
    assert(chmod_ok, 'Cannot make Lazy lockfile writable: ' .. tostring(chmod_err))
  end
  return path
end

function M.lockfile()
  local shipped = vim.fs.joinpath(vim.fn.stdpath 'config', 'lazy-lock.json')
  local override = vim.env.NVIM_LOCKFILE
  if override and override ~= '' then
    return prepare(vim.fs.abspath(vim.fs.normalize(override)), shipped)
  end
  if writable(shipped) then
    return shipped
  end
  return prepare(vim.fs.joinpath(vim.fn.stdpath 'data', 'lazy-lock.json'), shipped)
end

return M

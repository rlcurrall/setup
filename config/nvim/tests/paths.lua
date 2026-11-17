return function(T)
  local paths = require 'custom.paths'
  local function fixture()
    local base = T.tempdir()
    local config, data = base .. '/config', base .. '/data'
    vim.fn.mkdir(config, 'p')
    local original = vim.fn.stdpath
    local override = vim.env.NVIM_LOCKFILE
    vim.fn.stdpath = function(kind)
      if kind == 'config' then
        return config
      elseif kind == 'data' then
        return data
      end
      return original(kind)
    end
    vim.env.NVIM_LOCKFILE = nil
    T.defer(function()
      vim.fn.stdpath = original
      vim.env.NVIM_LOCKFILE = override
    end)
    return config, data, base
  end

  T.test('standalone lockfile stays in the config directory', function()
    local config = fixture()
    T.equal(paths.lockfile(), config .. '/lazy-lock.json')
    T.file(config .. '/lazy-lock.json', { '{"existing":true}' })
    T.equal(paths.lockfile(), config .. '/lazy-lock.json')
    T.equal(vim.fn.readfile(paths.lockfile()), { '{"existing":true}' })
  end)

  T.test('explicit lockfile seeds once and preserves updated pins', function()
    local config, _, base = fixture()
    T.file(config .. '/lazy-lock.json', { '{"original":true}' })
    vim.env.NVIM_LOCKFILE = base .. '/checkout with # spaces/nested/lazy-lock.json'
    local destination = paths.lockfile()
    T.equal(destination, vim.env.NVIM_LOCKFILE)
    T.equal(vim.fn.readfile(destination), { '{"original":true}' })
    T.file(destination, { '{"updated":true}' })
    T.equal(vim.fn.readfile(paths.lockfile()), { '{"updated":true}' })
  end)

  T.test('explicit destination expands environment variables', function()
    local _, _, base = fixture()
    local old = vim.env.NVIM_TEST_LOCK_ROOT
    T.defer(function()
      vim.env.NVIM_TEST_LOCK_ROOT = old
    end)
    vim.env.NVIM_TEST_LOCK_ROOT = base
    vim.env.NVIM_LOCKFILE = '$NVIM_TEST_LOCK_ROOT/expanded/lazy-lock.json'
    T.equal(paths.lockfile(), base .. '/expanded/lazy-lock.json')
  end)

  T.test('invalid explicit lockfile reports its destination', function()
    local config = fixture()
    vim.env.NVIM_LOCKFILE = config -- A directory cannot be a lockfile.
    local ok, err = pcall(paths.lockfile)
    assert(not ok and tostring(err):find('Lazy lockfile is not writable: ' .. config, 1, true))
  end)

  T.test('read-only config seeds a writable data lockfile once', function()
    local config, data = fixture()
    local shipped = config .. '/lazy-lock.json'
    T.file(shipped, { '{"shipped":true}' })
    if vim.fn.has 'win32' == 1 then
      -- Windows ACLs do not behave like Unix mode bits.
      local filewritable = vim.fn.filewritable
      vim.fn.filewritable = function(path)
        return path == shipped and 0 or filewritable(path)
      end
      T.defer(function()
        vim.fn.filewritable = filewritable
      end)
    else
      assert(vim.uv.fs_chmod(shipped, 292)) -- 0444, like the Nix store.
      T.defer(function()
        assert(vim.uv.fs_chmod(shipped, 420))
      end)
    end
    local destination = paths.lockfile()
    T.equal(destination, data .. '/lazy-lock.json')
    T.equal(vim.fn.readfile(destination), { '{"shipped":true}' })
    T.file(destination, { '{"updated":true}' })
    T.equal(vim.fn.readfile(paths.lockfile()), { '{"updated":true}' })
  end)

  if vim.fn.has 'win32' == 0 then
    T.test('writable symlink writes through to the checkout', function()
      local config, _, base = fixture()
      local source = base .. '/checkout/lazy-lock.json'
      T.file(source, { '{}' })
      assert(vim.uv.fs_symlink(source, config .. '/lazy-lock.json'))
      T.file(paths.lockfile(), { '{"updated":true}' })
      T.equal(vim.fn.readfile(source), { '{"updated":true}' })
    end)
  end
end

return function(T)
  local project = require 'custom.project'
  project.setup()
  local function canonical(path)
    return vim.uv.fs_realpath(path) or path
  end
  local function fixture()
    local base = T.tempdir()
    local cwd = vim.fn.getcwd()
    T.defer(function()
      vim.api.nvim_cmd({ cmd = 'cd', args = { cwd }, magic = { file = false } }, {})
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_get_name(buf):find(base, 1, true) == 1 then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end)
    return base
  end
  local function edit(path)
    vim.cmd.edit(vim.fn.fnameescape(path))
  end
  local function mapped(key)
    return vim.fn.maparg(key, 'n', false, true)
  end
  local function call(key)
    local map = mapped(key)
    assert(type(map.callback) == 'function', 'Missing mapping: ' .. key)
    map.callback()
  end
  local function package_fixture(base)
    T.file(base .. '/package.json', { '{}' })
    T.file(base .. '/src/main.ts')
    edit(base .. '/src/main.ts')
  end
  local function scope_snapshot()
    return { vim.fn.getcwd(), vim.fn.haslocaldir(), vim.fn.haslocaldir(-1) }
  end

  for _, case in ipairs {
    { 'App.csproj', 'src/Program.cs', '<leader>cb' },
    { 'App.sln', 'src/Program.cs', '<leader>ct' },
    { 'App.slnx', 'src/Program.cs', '<leader>cr' },
    { 'requirements.txt', 'src/main.py', '<leader>pt' },
    { 'Cargo.toml', 'src/main.rs', '<leader>rb' },
  } do
    T.test('project root and shortcut: ' .. case[1], function()
      local base = fixture()
      T.file(base .. '/' .. case[1])
      T.file(base .. '/' .. case[2])
      edit(base .. '/' .. case[2])
      T.equal(canonical(project.find_root()), canonical(base))
      assert(type(mapped(case[3]).callback) == 'function')
    end)
  end

  T.test('nested package wins over ancestor package and Git repository', function()
    local base = fixture()
    vim.fn.mkdir(base .. '/.git', 'p')
    T.file(base .. '/package.json', { '{}' })
    local nested = base .. '/packages/app'
    package_fixture(nested)
    T.equal(canonical(project.find_root()), canonical(nested))
  end)

  T.test('Git worktree boundary blocks unrelated outer package', function()
    local base = fixture()
    T.file(base .. '/package.json', { '{}' })
    T.file(base .. '/inner/.git', { 'gitdir: elsewhere' })
    T.file(base .. '/inner/src/main.ts')
    edit(base .. '/inner/src/main.ts')
    T.equal(canonical(project.find_root()), canonical(base .. '/inner'))
    assert(vim.tbl_isempty(mapped '<leader>nb'))
  end)

  T.test('renaming out of a project clears its shortcuts', function()
    local base = fixture()
    package_fixture(base .. '/app')
    assert(type(mapped('<leader>nb').callback) == 'function')
    vim.api.nvim_buf_set_name(0, base .. '/orphan.ts')
    assert(vim.tbl_isempty(mapped '<leader>nb'))
    local unnamed = vim.api.nvim_create_buf(false, true)
    T.defer(function()
      vim.api.nvim_buf_delete(unnamed, { force = true })
    end)
    T.equal(project.find_root(unnamed), nil)
  end)

  for _, scope in ipairs { 'cd', 'tcd', 'lcd' } do
    T.test('project command preserves ' .. scope .. ' scope, including on failure', function()
      local base = fixture()
      local package = base .. "/space #! ' app"
      package_fixture(package)
      vim.api.nvim_cmd({ cmd = scope, args = { base } }, {})
      local before = scope_snapshot()
      local original, ran = vim.cmd, false
      T.defer(function()
        vim.cmd = original
      end)
      vim.cmd = function(command)
        ran = true
        T.equal(canonical(vim.fn.getcwd()), canonical(package))
        T.equal(command, '!' .. vim.fn.shellescape('npm', 1) .. ' ' .. vim.fn.shellescape('run', 1) .. ' ' .. vim.fn.shellescape('build', 1))
      end
      call '<leader>nb'
      assert(ran)
      T.equal(scope_snapshot(), before)
      vim.cmd = function()
        error 'intentional command failure'
      end
      local ok, err = pcall(call, '<leader>nb')
      assert(not ok and tostring(err):find('intentional command failure', 1, true))
      T.equal(scope_snapshot(), before)
      vim.cmd = original
    end)
  end

  if T.integration then
    T.test('integration: npm build runs in a package with shell-sensitive characters', function()
      assert(vim.fn.executable 'npm' == 1, 'npm is required for --integration')
      local base = fixture()
      local package = base .. "/space #! ' app"
      package_fixture(package)
      T.file(package .. '/package.json', {
        vim.json.encode {
          name = 'nvim-regression',
          scripts = { build = [=[node -e "require('fs').writeFileSync('cwd.txt', process.cwd())"]=] },
        },
      })
      vim.cmd.cd(vim.fn.fnameescape(base))
      call '<leader>nb'
      T.equal(vim.v.shell_error, 0)
      T.equal(canonical(vim.fn.readfile(package .. '/cwd.txt')[1]), canonical(package))
    end)

    T.test('integration: C# shortcut builds a throwaway .NET project', function()
      assert(vim.fn.executable 'dotnet' == 1, 'the .NET SDK is required for --integration')
      local version = vim.fn.system({ 'dotnet', '--version' }):match '^(%d+)'
      assert(vim.v.shell_error == 0 and version, 'Cannot detect .NET SDK version')
      local target = 'net' .. version .. '.0'
      local base = fixture()
      local project_dir = base .. '/csharp'
      T.file(project_dir .. '/App.csproj', {
        '<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup><OutputType>Exe</OutputType><TargetFramework>'
          .. target
          .. '</TargetFramework></PropertyGroup></Project>',
      })
      T.file(project_dir .. '/Program.cs', { 'System.Console.WriteLine(42);' })
      edit(project_dir .. '/Program.cs')
      vim.cmd.cd(vim.fn.fnameescape(base))
      call '<leader>cb'
      T.equal(vim.v.shell_error, 0)
      assert(vim.fn.filereadable(project_dir .. '/bin/Debug/' .. target .. '/App.dll') == 1)
    end)
  end
end

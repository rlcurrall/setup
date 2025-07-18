-- [[ Project-specific configuration ]]
-- This module handles loading project-specific settings

local M = {}

-- Function to find project root
local function find_project_root()
  local markers = { '.git', '.nvim.lua', 'package.json', '*.sln', '*.csproj', 'Cargo.toml', 'pyproject.toml' }
  local current_dir = vim.fn.expand('%:p:h')
  
  for _, marker in ipairs(markers) do
    local found = vim.fn.findfile(marker, current_dir .. ';')
    if found ~= '' then
      return vim.fn.fnamemodify(found, ':p:h')
    end
    
    local found_dir = vim.fn.finddir(marker, current_dir .. ';')
    if found_dir ~= '' then
      return vim.fn.fnamemodify(found_dir, ':p:h:h')
    end
  end
  
  return nil
end

-- Load project-specific configuration
function M.load_project_config()
  local project_root = find_project_root()
  if not project_root then
    return
  end
  
  local config_file = project_root .. '/.nvim.lua'
  if vim.fn.filereadable(config_file) == 1 then
    dofile(config_file)
  end
end

-- Set up project-specific settings based on file types and patterns
function M.setup_project_settings()
  local current_file = vim.fn.expand('%:p')
  local project_root = find_project_root()
  
  if not project_root then
    return
  end
  
  -- C# Projects
  if vim.fn.glob(project_root .. '/*.sln') ~= '' or vim.fn.glob(project_root .. '/*.csproj') ~= '' then
    -- C# specific settings
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    
    -- Set up C# specific keybindings
    vim.keymap.set('n', '<leader>cb', '<cmd>!dotnet build<CR>', { desc = 'Build C# project', buffer = true })
    vim.keymap.set('n', '<leader>ct', '<cmd>!dotnet test<CR>', { desc = 'Run C# tests', buffer = true })
    vim.keymap.set('n', '<leader>cr', '<cmd>!dotnet run<CR>', { desc = 'Run C# project', buffer = true })
  end
  
  -- Node.js Projects
  if vim.fn.filereadable(project_root .. '/package.json') == 1 then
    -- Node.js specific settings
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
    
    -- Set up Node.js specific keybindings
    vim.keymap.set('n', '<leader>ni', '<cmd>!npm install<CR>', { desc = 'npm install', buffer = true })
    vim.keymap.set('n', '<leader>nt', '<cmd>!npm test<CR>', { desc = 'npm test', buffer = true })
    vim.keymap.set('n', '<leader>nr', '<cmd>!npm run dev<CR>', { desc = 'npm run dev', buffer = true })
    vim.keymap.set('n', '<leader>nb', '<cmd>!npm run build<CR>', { desc = 'npm run build', buffer = true })
  end
  
  -- Rust Projects
  if vim.fn.filereadable(project_root .. '/Cargo.toml') == 1 then
    -- Rust specific settings
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    
    -- Set up Rust specific keybindings
    vim.keymap.set('n', '<leader>rb', '<cmd>!cargo build<CR>', { desc = 'Cargo build', buffer = true })
    vim.keymap.set('n', '<leader>rt', '<cmd>!cargo test<CR>', { desc = 'Cargo test', buffer = true })
    vim.keymap.set('n', '<leader>rr', '<cmd>!cargo run<CR>', { desc = 'Cargo run', buffer = true })
    vim.keymap.set('n', '<leader>rc', '<cmd>!cargo check<CR>', { desc = 'Cargo check', buffer = true })
  end
  
  -- Python Projects
  if vim.fn.filereadable(project_root .. '/pyproject.toml') == 1 or 
     vim.fn.filereadable(project_root .. '/requirements.txt') == 1 or
     vim.fn.filereadable(project_root .. '/setup.py') == 1 then
    -- Python specific settings
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = true
    
    -- Set up Python specific keybindings
    vim.keymap.set('n', '<leader>pr', '<cmd>!python %<CR>', { desc = 'Run Python file', buffer = true })
    vim.keymap.set('n', '<leader>pt', '<cmd>!python -m pytest<CR>', { desc = 'Run pytest', buffer = true })
  end
end

-- Auto-detect and apply project settings
function M.setup()
  local augroup = vim.api.nvim_create_augroup('ProjectConfig', { clear = true })
  
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
    group = augroup,
    callback = function()
      M.load_project_config()
      M.setup_project_settings()
    end,
  })
end

return M
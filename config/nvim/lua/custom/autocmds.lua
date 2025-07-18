-- [[ Autocommands ]]
-- See `:help lua-guide-autocommands`

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ===== FILE TYPE SPECIFIC SETTINGS =====
local filetype_settings = augroup('FileTypeSettings', { clear = true })

-- Web development files (2 spaces)
autocmd('FileType', {
  group = filetype_settings,
  pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'json', 'html', 'css', 'scss', 'yaml', 'yml' },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Lua files (2 spaces)
autocmd('FileType', {
  group = filetype_settings,
  pattern = 'lua',
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Markdown files
autocmd('FileType', {
  group = filetype_settings,
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
    vim.opt_local.conceallevel = 2
  end,
})

-- Git commit messages
autocmd('FileType', {
  group = filetype_settings,
  pattern = 'gitcommit',
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 72
  end,
})

-- ===== EDITOR BEHAVIOR =====
local editor_behavior = augroup('EditorBehavior', { clear = true })

-- Highlight on yank
autocmd('TextYankPost', {
  group = editor_behavior,
  desc = 'Highlight when yanking text',
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Remove trailing whitespace on save
autocmd('BufWritePre', {
  group = editor_behavior,
  desc = 'Remove trailing whitespace on save',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})

-- Auto-create directories when saving files
autocmd('BufWritePre', {
  group = editor_behavior,
  desc = 'Auto-create directories when saving files',
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Remember cursor position
autocmd('BufReadPost', {
  group = editor_behavior,
  desc = 'Restore cursor position when opening files',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ===== WINDOW MANAGEMENT =====
local window_management = augroup('WindowManagement', { clear = true })

-- Equalize splits when Vim is resized
autocmd('VimResized', {
  group = window_management,
  desc = 'Equalize splits when Vim is resized',
  callback = function()
    vim.cmd('wincmd =')
  end,
})

-- Close certain filetypes with 'q'
autocmd('FileType', {
  group = window_management,
  pattern = { 'help', 'startuptime', 'qf', 'lspinfo', 'man', 'checkhealth' },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = event.buf, silent = true })
  end,
})

-- ===== DEVELOPMENT WORKFLOW =====
local dev_workflow = augroup('DevWorkflow', { clear = true })

-- Auto-reload files changed outside of Neovim
autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  group = dev_workflow,
  desc = 'Auto-reload files changed outside of Neovim',
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd('checktime')
    end
  end,
})

-- Auto-save when focus is lost
autocmd('FocusLost', {
  group = dev_workflow,
  desc = 'Auto-save when focus is lost',
  callback = function()
    if vim.bo.modified and not vim.bo.readonly and vim.fn.expand('%') ~= '' and vim.bo.buftype == '' then
      vim.cmd('silent! write')
    end
  end,
})

-- Format on save for specific filetypes
autocmd('BufWritePre', {
  group = dev_workflow,
  pattern = { '*.lua', '*.js', '*.ts', '*.jsx', '*.tsx', '*.cs' },
  desc = 'Format code on save',
  callback = function()
    if vim.lsp.buf.format then
      vim.lsp.buf.format({ async = false })
    end
  end,
})

-- ===== TERMINAL SETTINGS =====
local terminal_settings = augroup('TerminalSettings', { clear = true })

-- Terminal settings
autocmd('TermOpen', {
  group = terminal_settings,
  desc = 'Terminal settings',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
    vim.cmd('startinsert')
  end,
})

-- ===== PROJECT SPECIFIC =====
local project_specific = augroup('ProjectSpecific', { clear = true })

-- C# project settings
autocmd('BufEnter', {
  group = project_specific,
  pattern = '*.cs',
  desc = 'C# project settings',
  callback = function()
    -- Enable inlay hints for C#
    if vim.lsp.inlay_hint then
      vim.lsp.inlay_hint.enable(true, { bufnr = 0 })
    end
  end,
})
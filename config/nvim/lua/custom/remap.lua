-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- ===== WINDOW MANAGEMENT =====
-- Navigation: CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Resizing: ALT+<hjkl> to resize windows
vim.keymap.set('n', '<A-h>', '<C-w>>', { desc = 'Increase window width' })
vim.keymap.set('n', '<A-l>', '<C-w><', { desc = 'Decrease window width' })
vim.keymap.set('n', '<A-j>', '<C-w>+', { desc = 'Increase window height' })
vim.keymap.set('n', '<A-k>', '<C-w>-', { desc = 'Decrease window height' })

-- Quick window operations
vim.keymap.set('n', '<leader>wv', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>wh', '<C-w>s', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>wq', '<C-w>q', { desc = 'Close current window' })
vim.keymap.set('n', '<leader>wo', '<C-w>o', { desc = 'Close other windows' })

-- ===== BUFFER MANAGEMENT =====
vim.keymap.set('n', '<leader>bd', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })
vim.keymap.set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader>ba', '<cmd>%bd|e#<CR>', { desc = 'Delete all buffers except current' })

-- ===== MOVEMENT IMPROVEMENTS =====
-- Better line movement
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Center screen on navigation
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down and center' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up and center' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result (centered)' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result (centered)' })

-- ===== TEXT MANIPULATION =====
-- Move lines up/down
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Better indenting
vim.keymap.set('v', '<', '<gv', { desc = 'Indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent right and reselect' })

-- Paste without losing register
vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste without losing register' })

-- ===== QUICK ACTIONS =====
-- Save and quit shortcuts
vim.keymap.set('n', '<leader>w', '<cmd>w<CR>', { desc = 'Save file' })
vim.keymap.set('n', '<leader>q', '<cmd>q<CR>', { desc = 'Quit' })
vim.keymap.set('n', '<leader>Q', '<cmd>qa!<CR>', { desc = 'Quit all without saving' })

-- Toggle options
vim.keymap.set('n', '<leader>tw', '<cmd>set wrap!<CR>', { desc = 'Toggle word wrap' })
vim.keymap.set('n', '<leader>ts', '<cmd>set spell!<CR>', { desc = 'Toggle spell check' })
vim.keymap.set('n', '<leader>tn', '<cmd>set number!<CR>', { desc = 'Toggle line numbers' })
vim.keymap.set('n', '<leader>tr', '<cmd>set relativenumber!<CR>', { desc = 'Toggle relative numbers' })

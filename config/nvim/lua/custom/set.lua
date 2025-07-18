-- Set <space> as the leader key
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable spell checking
vim.opt.spelllang = 'en_us'
vim.opt.spell = true

-- Set to true if a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Enable line numbers, use relative numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, useful for resizing splits
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Do not wrap text
-- vim.o.wrap = false
vim.o.linebreak = true

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Tab width defaults
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.expandtab = true

-- if jit.os == 'Windows' then
--   vim.opt.shell = 'pwsh'
-- end

-- Enable virtial diagnostic lines
vim.diagnostic.config { virtual_lines = true }

-- ===== PERFORMANCE OPTIMIZATIONS =====
-- Faster completion
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Better search performance
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Reduce redraw frequency
vim.opt.lazyredraw = false -- Keep false for better UX
vim.opt.ttyfast = true

-- Memory management
vim.opt.hidden = true
vim.opt.history = 1000
vim.opt.undolevels = 1000

-- File handling
vim.opt.autoread = true
vim.opt.autowrite = true

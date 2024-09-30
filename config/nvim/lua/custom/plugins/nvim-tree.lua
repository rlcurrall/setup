return {
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      {
        '\\',
        function()
          local api = require 'nvim-tree.api'

          local currentBuf = vim.api.nvim_get_current_buf()
          local currentBufFt = vim.api.nvim_get_option_value('filetype', { buf = currentBuf })
          if currentBufFt == 'NvimTree' then
            api.tree.toggle()
          else
            api.tree.focus()
          end
        end,
        desc = 'Toggle file tree',
      },
    },
    opts = {
      sync_root_with_cwd = true,
      reload_on_bufenter = true,
      respect_buf_cwd = true,
      renderer = { highlight_opened_files = 'all' },
      update_focused_file = { enable = true },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = false,
        },
      },
      view = {
        side = 'right',
        preserve_window_proportions = true,
      },
    },
    config = function(_, opts)
      local api = require 'nvim-tree.api'
      local view = require 'nvim-tree.view'
      local augroup = vim.api.nvim_create_augroup
      local autocmd = vim.api.nvim_create_autocmd

      require('nvim-tree').setup(opts)

      -- disable status line for nvim-tree
      vim.api.nvim_create_autocmd('Filetype', {
        pattern = 'NvimTree',
        callback = function(args)
          local filetype = vim.bo[args.buf].filetype

          if filetype == 'NvimTree' then
            vim.b[args.buf].ministatusline_disable = true
          end
        end,
      })

      -- close nvim-tree if it is the last open window
      vim.api.nvim_create_autocmd('QuitPre', {
        callback = function()
          local tree_wins = {}
          local floating_wins = {}
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
            if bufname:match 'NvimTree_' ~= nil then
              table.insert(tree_wins, w)
            end
            if vim.api.nvim_win_get_config(w).relative ~= '' then
              table.insert(floating_wins, w)
            end
          end
          if 1 == #wins - #floating_wins - #tree_wins then
            -- Should quit, so we close all invalid windows.
            for _, w in ipairs(tree_wins) do
              vim.api.nvim_win_close(w, true)
            end
          end
        end,
      })

      -- save nvim-tree window width on WinResized event
      augroup('save_nvim_tree_width', { clear = true })
      autocmd('WinResized', {
        group = 'save_nvim_tree_width',
        pattern = '*',
        callback = function()
          local filetree_winnr = view.get_winnr()
          if filetree_winnr ~= nil and vim.tbl_contains(vim.v.event['windows'], filetree_winnr) then
            vim.t['filetree_width'] = vim.api.nvim_win_get_width(filetree_winnr)
          end
        end,
      })

      -- restore window size when openning nvim-tree
      api.events.subscribe(api.events.Event.TreeOpen, function()
        if vim.t['filetree_width'] ~= nil then
          view.resize(vim.t['filetree_width'])
        end
      end)

      -- automatically open file upon creation
      api.events.subscribe(api.events.Event.FileCreated, function(file)
        vim.cmd('edit ' .. file.fname)
      end)
    end,
  },
}

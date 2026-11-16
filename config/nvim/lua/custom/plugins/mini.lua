return {
  { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    priority = 1000,
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- Highlight comment tags without a separate plugin or Plenary dependency.
      local highlighters = {}
      local tags = {
        MiniHipatternsFixme = { 'FIX', 'FIXME', 'BUG', 'FIXIT', 'ISSUE' },
        MiniHipatternsTodo = { 'TODO' },
        MiniHipatternsHack = { 'HACK', 'WARN', 'WARNING', 'XXX' },
        MiniHipatternsNote = { 'NOTE', 'INFO', 'PERF', 'OPTIM', 'PERFORMANCE', 'OPTIMIZE', 'TEST', 'TESTING', 'PASSED', 'FAILED' },
      }
      for group, keywords in pairs(tags) do
        local patterns = {}
        for _, keyword in ipairs(keywords) do
          patterns[#patterns + 1] = '%f[%w_]()' .. keyword .. '()%s*:'
        end
        highlighters[group] = {
          pattern = patterns,
          group = function(bufnr, _, data)
            for _, capture in ipairs(vim.treesitter.get_captures_at_pos(bufnr, data.line - 1, data.from_col - 1)) do
              if capture.capture:find 'comment' then
                return group
              end
            end
          end,
        }
      end
      require('mini.hipatterns').setup { highlighters = highlighters }

      require('mini.pairs').setup()
      require('mini.icons').setup()
      require('mini.icons').mock_nvim_web_devicons()
      require('mini.statusline').setup {
        use_icons = vim.g.have_nerd_font,
        content = {
          active = function()
            local status = require 'mini.statusline'
            local mode, mode_hl = status.section_mode { trunc_width = 120 }
            return status.combine_groups {
              { hl = mode_hl, strings = { mode } },
              {
                hl = 'MiniStatuslineDevinfo',
                strings = {
                  status.section_git { trunc_width = 40 },
                  status.section_diff { trunc_width = 75 },
                  status.section_diagnostics { trunc_width = 75 },
                },
              },
              '%<',
              { hl = 'MiniStatuslineFilename', strings = { status.section_filename { trunc_width = 140 } } },
              '%=',
              { hl = 'MiniStatuslineFileinfo', strings = { vim.bo.filetype } },
              { hl = mode_hl, strings = { '%p%% %l:%c' } },
            }
          end,
        },
      }
      vim.opt.laststatus = 3
    end,
  },
}

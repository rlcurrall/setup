-- Derive editor colors from the hosting terminal by default.
-- Launch NVIM_THEME=rose-pine nvim for the previous system light/dark theme.
local terminal_theme = vim.env.NVIM_THEME ~= 'rose-pine'

return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1100,
    config = function()
      require('rose-pine').setup {}
      -- A readable initial theme while the terminal query runs, or if it fails.
      vim.cmd.colorscheme(vim.o.background == 'light' and 'rose-pine-dawn' or 'rose-pine-moon')
      vim.cmd.hi 'Comment gui=none'
    end,
  },
  {
    'GooseRooster/osc-colors.nvim',
    cond = terminal_theme,
    lazy = false,
    priority = 1000,
    opts = {
      refresh_on = { 'UIEnter', 'FocusGained' },
      ui = { transparent = true }, -- Let Rex/Ghostty draw their pane background.
      capabilities = { undercurl = true },
      styles = { comments = { italic = false, bold = false } },
      highlights = {
        overrides = function(palette)
          -- Select light/dark before highlights are applied. Changing it after
          -- application can reset built-in groups, including Normal/diagnostics.
          vim.o.background = palette.variant
          -- Reuse the generated keyword color as the UI accent. It is selected
          -- from prominent palette hues and contrast-adjusted for this background.
          local accent = palette.syntax.keyword.default
          local background = palette.ui.global.background.normal
          local foreground = palette.ui.global.foreground.normal
          return {
            MiniStatuslineModeNormal = { fg = background, bg = accent, bold = true },
            WinSeparator = { fg = accent },
            FloatBorder = { fg = accent, bg = background },
            FloatTitle = { fg = accent, bg = background, bold = true },
            NormalFloat = { fg = foreground, bg = background },
            Pmenu = { fg = foreground, bg = background },
            PmenuSel = { fg = background, bg = accent, bold = true },
            BlinkCmpMenu = { link = 'Pmenu' },
            BlinkCmpMenuBorder = { link = 'FloatBorder' },
            BlinkCmpDoc = { link = 'NormalFloat' },
            BlinkCmpDocBorder = { link = 'FloatBorder' },
            BlinkCmpSignatureHelp = { link = 'NormalFloat' },
            BlinkCmpSignatureHelpBorder = { link = 'FloatBorder' },
            NoiceCmdlinePopup = { link = 'NormalFloat' },
            NoiceCmdlinePopupBorder = { link = 'FloatBorder' },
            NoiceCmdlinePopupTitle = { link = 'FloatTitle' },
            NoiceCmdlineIcon = { fg = accent },
            NoiceConfirm = { link = 'NormalFloat' },
            SnacksPickerBox = { link = 'NormalFloat' },
            SnacksPickerInput = { link = 'NormalFloat' },
            SnacksPickerList = { link = 'NormalFloat' },
            SnacksPickerPreview = { link = 'NormalFloat' },
            SnacksPickerInputBorder = { link = 'FloatBorder' },
            SnacksPickerBoxBorder = { link = 'FloatBorder' },
            SnacksPickerPrompt = { fg = accent },
          }
        end,
      },
    },
  },
  {
    'f-person/auto-dark-mode.nvim',
    cond = not terminal_theme, -- The terminal owns appearance in the default mode.
    branch = 'main',
    dependencies = { 'rose-pine/neovim' },
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.cmd.colorscheme 'rose-pine-moon'
        vim.cmd.hi 'Comment gui=none'
      end,
      set_light_mode = function()
        vim.cmd.colorscheme 'rose-pine-dawn'
        vim.cmd.hi 'Comment gui=none'
      end,
    },
  },
}

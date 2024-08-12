local wezterm = require("wezterm")
local h = require("utils.helpers")

local config = wezterm.config_builder()

config.color_scheme = h.theme

config.window_decorations = "RESIZE"
config.enable_tab_bar = false
config.window_close_confirmation = "NeverPrompt"

config.font_size = 14
config.font = wezterm.font("Fira Code", {})

config.enable_wayland = true

return config

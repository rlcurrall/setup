local wezterm = require("wezterm")
local helpers = require("utils.helpers")
local keybind = require("custom.keybind")
local tabs = require("custom.tabs")
local theme = require("custom.theme")

local config = wezterm.config_builder()

keybind.setup(config)
tabs.setup(config)
theme.setup(config)

config.window_close_confirmation = "NeverPrompt"

config.enable_wayland = true

if helpers.is_windows() then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
end

-- Always maximize on startup
wezterm.on("gui-startup", function()
	local _, _, window = wezterm.mux.spawn_window({})
	window:gui_window():maximize()
end)

return config

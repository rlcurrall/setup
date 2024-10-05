local wezterm = require("wezterm")
local helpers = require("utils.helpers")
local theme = require("custom.theme")
local keybind = require("custom.keybind")

local config = wezterm.config_builder()

theme.apply(config)
keybind.apply(config)

config.window_close_confirmation = "NeverPrompt"

config.enable_wayland = true

if helpers.is_windows() then
	config.default_prog = { "pwsh.exe", "-NoLogo" }
end

config.unix_domains = { { name = "unix" } }

-- Always maximize on startup
-- wezterm.on("gui-startup", function()
-- 	local _, _, window = wezterm.mux.spawn_window({})
-- 	window:gui_window():maximize()
-- end)

return config

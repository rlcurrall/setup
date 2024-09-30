local wezterm = require("wezterm")
local helpers = require("utils.helpers")
local session_manager = require("wezterm-session-manager.session-manager")

local config = wezterm.config_builder()

config.window_close_confirmation = "NeverPrompt"

config.color_scheme = helpers.theme
config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.switch_to_last_active_tab_when_closing_tab = true
config.window_frame = {
	font = wezterm.font("Fira Code"),
}
config.window_padding = {
	left = 5,
	right = 5,
	top = 5,
	bottom = 5,
}

config.font_size = 14
config.font = wezterm.font("Fira Code")

config.enable_wayland = true

if helpers.is_windows() then
	config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe", "-NoLogo" }
end

config.unix_domains = { { name = "unix" } }

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },

	-- Configuration for Panes (split, nav)
	{ key = "|", mods = "LEADER|SHIFT", action = wezterm.action.SplitPane({ direction = "Right" }) },
	{ key = "-", mods = "LEADER", action = wezterm.action.SplitPane({ direction = "Down" }) },
	{ key = "h", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
	{ key = "l", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
	{ key = "j", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
	{ key = "k", mods = "CTRL|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },

	-- Configuration for Tabs (open, close, rename)
	{ key = "q", mods = "LEADER", action = wezterm.action.CloseCurrentTab({ confirm = true }) },
	{ key = "t", mods = "LEADER", action = wezterm.action.ShowTabNavigator },
	{ -- Rename current tab
		key = ",",
		mods = "LEADER",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	{ key = "a", mods = "LEADER", action = wezterm.action.AttachDomain("unix") },
	{ key = "d", mods = "LEADER", action = wezterm.action.DetachDomain({ DomainName = "unix" }) },
	{ -- Rename current workspace
		key = "R",
		mods = "LEADER|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for session",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					wezterm.mux.rename_workspace(window:mux_window():get_workspace(), line)
				end
			end),
		}),
	},
	{ --Show list of workspaces
		key = "w",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }),
	},
	{ -- Save current session
		key = "s",
		mods = "LEADER",
		action = wezterm.action({ EmitEvent = "save_session" }),
	},
	{ -- Load a session
		key = "l",
		mods = "LEADER",
		action = wezterm.action({ EmitEvent = "load_session" }),
	},
	{ -- Restore current session to last save
		key = "r",
		mods = "LEADER",
		action = wezterm.action({ EmitEvent = "restore_session" }),
	},
}

wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)
wezterm.on("load_session", function(window)
	session_manager.load_state(window)
end)
wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

return config

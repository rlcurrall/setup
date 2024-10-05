local wezterm = require("wezterm")
local Module = {}

Module.setup = function(config)
	config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
	config.keys = {
		{ key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },

		-- Configuration for Panes (split, navigation)
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
	}
end

return Module

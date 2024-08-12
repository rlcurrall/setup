local M = {}
local wezterm = require("wezterm")

M.get_appearance = function()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

M.scheme_for_appearance = function(appearance)
	if appearance:find("Dark") then
		return "Tokyo Night"
	else
		return "Tokyo Night Day"
	end
end

M.is_dark = M.get_appearance():find("Dark")
M.theme = M.scheme_for_appearance(M.get_appearance())

return M

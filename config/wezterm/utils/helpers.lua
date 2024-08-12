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

M.is_linux = function()
	return wezterm.target_triple:find("linux") ~= nil
end

M.is_darwin = function()
	return wezterm.target_triple:find("darwin") ~= nil
end

M.is_windows = function()
	return wezterm.target_triple:find("windows") ~= nil
end

return M

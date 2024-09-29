local wezterm = require("wezterm")
local Module = {}

Module.get_appearance = function()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

Module.scheme_for_appearance = function(appearance)
	if appearance:find("Dark") then
		return "Tokyo Night"
	else
		return "Tokyo Night Day"
	end
end

Module.is_dark = Module.get_appearance():find("Dark")
Module.theme = Module.scheme_for_appearance(Module.get_appearance())

Module.is_linux = function()
	return wezterm.target_triple:find("linux") ~= nil
end

Module.is_darwin = function()
	return wezterm.target_triple:find("darwin") ~= nil
end

Module.is_windows = function()
	return wezterm.target_triple:find("windows") ~= nil
end

return Module

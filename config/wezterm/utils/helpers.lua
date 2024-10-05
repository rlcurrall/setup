local wezterm = require("wezterm")
local Module = {}

Module.get_appearance = function()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

Module.is_dark = function()
	return Module.get_appearance():find("Dark")
end

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

local wezterm = require("wezterm")
local module = {}

module.get_appearance = function()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

module.scheme_for_appearance = function(appearance)
	if appearance:find("Dark") then
		return "Tokyo Night"
	else
		return "Tokyo Night Day"
	end
end

module.is_dark = module.get_appearance():find("Dark")
module.theme = module.scheme_for_appearance(module.get_appearance())

module.is_linux = function()
	return wezterm.target_triple:find("linux") ~= nil
end

module.is_darwin = function()
	return wezterm.target_triple:find("darwin") ~= nil
end

module.is_windows = function()
	return wezterm.target_triple:find("windows") ~= nil
end

return module

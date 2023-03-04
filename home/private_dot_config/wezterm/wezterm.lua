local wezterm = require("wezterm")
local act = wezterm.action

return {
	-- UI
	color_scheme = "tokyonight-storm",
	hide_tab_bar_if_only_one_tab = true,

	-- font settings
	font_size = 12.0,

	-- keymaps
	leader = { key = "a", mods = "CTRL", timeout_miliseconds = 1000 },
	keys = {
		{
			key = "|",
			mods = "LEADER|SHIFT",
			action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "-",
			mods = "LEADER",
			action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
	},
}

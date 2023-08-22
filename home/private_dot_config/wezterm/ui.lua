local wezterm = require("wezterm")

local regular_font = "JetBrainsMono Nerd Font"
local italic_font = "VictorMono Nerd Font"

local M = {}

M.colorscheme = "nordfox"

---@param cfg table
M.setup = function(cfg)
  -- font setting
  cfg.font = wezterm.font(regular_font)
  cfg.font_size = 14.5
  cfg.font_rules = {
    {
      italic = true,
      intensity = "Normal",
      font = wezterm.font({ family = italic_font, style = "Italic" }),
    },
    {
      italic = true,
      intensity = "Half",
      font = wezterm.font({
        family = italic_font,
        weight = "DemiBold",
        style = "Italic",
      }),
    },
    {
      italic = true,
      intensity = "Bold",
      font = wezterm.font({
        family = italic_font,
        weight = "Bold",
        style = "Italic",
      }),
    },
  }

  -- color scheme
  cfg.color_scheme = M.colorscheme

  -- tab bar config
  -- nordfox : use_fancy_tab_bar: false
  cfg.use_fancy_tab_bar = false
  cfg.tab_max_width = 25

  cfg.enable_scroll_bar = false

  cfg.window_padding = {
    left = "0.5cell",
    right = "0.5cell",
    top = 0,
    bottom = 0,
  }

  cfg.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
  }
end

return M

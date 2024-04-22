local wezterm = require("wezterm")
local platform = require("utils.platform")

local regular_font = "Iosevka NF"
local italic_font = "VictorMono NF"
local frame_font = "Iosevka NF"

local M = {}

---@param cfg table
M.setup = function(cfg)
  -- font setting
  cfg.freetype_load_flags = "NO_HINTING"

  cfg.window_frame = { font = wezterm.font(frame_font) } -- set frame fonts, affect the command palette as well

  cfg.font = wezterm.font({ family = regular_font, weight = "Regular" })
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

  -- font size
  if platform.is_mac then
    cfg.font_size = 15.0
    cfg.command_palette_font_size = 14.0
  elseif platform.is_linux then
    -- for linux mint somehow behaving weirdly, but not going to chase right now.
    cfg.font_size = 14.0
    cfg.command_palette_font_size = 13.0
  else
    cfg.font_size = 13.0
    cfg.command_palette_font_size = 12.5
  end
end

return M

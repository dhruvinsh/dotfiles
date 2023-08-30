local wezterm = require("wezterm")
local platform = require("utils.platform")

local regular_font = "JetBrainsMono Nerd Font"
local italic_font = "VictorMono Nerd Font"
local frame_font = "Iosevka Nerd Font"

local M = {}

local ok
M.colorscheme = "rose-pine"
ok, M.colors =
  pcall(wezterm.color.load_scheme, wezterm.home_dir .. "/.config/wezterm/colors/" .. M.colorscheme .. ".toml")
if not ok then
  wezterm.log_info("external colorscheme not found using built-in colors")
  M.colors = wezterm.get_builtin_color_schemes()[M.colorscheme]
end

---@param cfg table
M.setup = function(cfg)
  -- font setting
  cfg.window_frame = { font = wezterm.font(frame_font) } -- set frame fonts, affect the command palette as well
  cfg.font = wezterm.font(regular_font)
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
  if platform.is_mac or platform.is_linux then
    cfg.font_size = 14.5
    cfg.command_palette_font_size = 14.5
  else
    cfg.font_size = 12
    cfg.command_palette_font_size = 12
  end

  -- color scheme
  cfg.color_scheme = M.colorscheme
  cfg.command_palette_fg_color = M.colors.foreground
  cfg.command_palette_bg_color = M.colors.background

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

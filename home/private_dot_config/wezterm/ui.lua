local wezterm = require("wezterm")
local platform = require("utils.platform")

local M = {}

local ok
M.colorscheme = "hybrid-local"
ok, M.colors =
  pcall(wezterm.color.load_scheme, wezterm.home_dir .. "/.config/wezterm/colors/" .. M.colorscheme .. ".toml")
if not ok then
  wezterm.log_info("external colorscheme not found using built-in colors")
  M.colors = wezterm.get_builtin_color_schemes()[M.colorscheme]
end

---@param cfg table
M.setup = function(cfg)
  cfg.front_end = "WebGpu"
  if platform.is_win then
    cfg.webgpu_power_preference = "HighPerformance"
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

local platform = require("utils.platform")

local M = {}

---@param cfg table
M.setup = function(cfg)
  cfg.force_reverse_video_cursor = true -- alacritty like cursor color

  cfg.front_end = "WebGpu"
  if platform.is_win then
    cfg.webgpu_power_preference = "HighPerformance"
  end

  -- color scheme
  cfg.command_palette_fg_color = cfg.colors.foreground
  cfg.command_palette_bg_color = cfg.colors.background

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

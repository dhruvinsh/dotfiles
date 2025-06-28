local wezterm = require("wezterm")
local M = {}

M.setup = function()
  wezterm.on("update-status", function(window)
    -- Grab the utf8 character for the "powerline" left facing
    -- solid arrow.
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    -- Grab the current window's configuration, and from it the
    -- palette (this is the combination of your chosen colour scheme
    -- including any overrides).
    local color_scheme = window:effective_config().resolved_palette
    local bg = color_scheme.brights[1]
    local fg = color_scheme.foreground

    window:set_right_status(wezterm.format({
      -- First, we draw the arrow...
      { Background = { Color = color_scheme.tab_bar.background } },
      { Foreground = { Color = bg } },
      { Text = SOLID_LEFT_ARROW },
      -- Then we draw our text
      { Background = { Color = bg } },
      { Foreground = { Color = fg } },
      { Text = " " .. wezterm.hostname() .. " " },
    }))
  end)
end

return M

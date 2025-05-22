-- https://github.com/wezterm/wezterm/issues/3299#issuecomment-2145712082
local wezterm = require("wezterm")
local mux = wezterm.mux
local M = {}

M.setup = function()
  wezterm.on("gui-startup", function(cmd)
    -- Pick the active screen to maximize into, there are also other options, see the docs.
    local active = wezterm.gui.screens().active

    -- Set the window coordinates on spawn.
    local _, _, window = mux.spawn_window(cmd or {
      x = active.x,
      y = active.y,
      width = active.width,
      height = active.height,
    })

    -- You probably don't need both, but you can also set the positions after spawn.
    window:gui_window():set_position(active.x, active.y)
    window:gui_window():set_inner_size(active.width, active.height)
  end)
end

return M

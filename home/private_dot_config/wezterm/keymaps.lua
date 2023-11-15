local wezterm = require("wezterm")
local platform = require("utils.platform")

local action = wezterm.action

-- | name            | MacOS     | Windows
-- ---------------------------------------
-- | SUPER, CMD, WIN | Command   | Win
-- | CTRL            | Ctrl      | Ctrl
-- | SHIFT           | Shift     | Shift
-- | ALT, OPT, META  | Option    | Alt
local mod = "SHIFT|SUPER"
local alt = "SUPER"
if platform.is_win or platform.is_linux then
  mod = "SHIFT|ALT"
  alt = "ALT"
end

local M = {}

---@param cfg table
M.setup = function(cfg)
  local toggleBlur = wezterm.action_callback(function(window)
    if window:effective_config().window_background_opacity == 1 then
      window:set_config_overrides({ window_background_opacity = 0.75, win32_system_backdrop = "Acrylic" })
    else
      window:set_config_overrides({ window_background_opacity = 1, win32_system_backdrop = "None" })
    end
  end)

  -- disable all the default mappings
  cfg.disable_default_key_bindings = true

  -- leader key: CTRL + SHIFT + SPACE
  cfg.leader = { key = "Space", mods = "CTRL|SHIFT", timeout_milliseconds = 1000 }

  cfg.keys = {
    -- window management: splits, movement, spawn
    { mods = mod, key = "|", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { mods = mod, key = "-", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },
    { mods = mod, key = "_", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) }, --window

    { mods = alt, key = "UpArrow", action = action.ActivatePaneDirection("Up") },
    { mods = alt, key = "DownArrow", action = action.ActivatePaneDirection("Down") },
    { mods = alt, key = "LeftArrow", action = action.ActivatePaneDirection("Left") },
    { mods = alt, key = "RightArrow", action = action.ActivatePaneDirection("Right") },
    { mods = mod, key = "[", action = action.ActivateTabRelative(-1) },
    { mods = mod, key = "]", action = action.ActivateTabRelative(1) },
    { mods = mod, key = "{", action = action.ActivateTabRelative(-1) }, -- windows
    { mods = mod, key = "}", action = action.ActivateTabRelative(1) }, -- windows

    { mods = mod, key = "d", action = action.SpawnTab("CurrentPaneDomain") },

    -- text management: copy-paste, font size
    { mods = "CTRL|SHIFT", key = "c", action = action.CopyTo("Clipboard") },
    { mods = "CTRL|SHIFT", key = "v", action = action.PasteFrom("Clipboard") },
    { mods = "CTRL|SHIFT", key = "_", action = action.DecreaseFontSize },
    { mods = "CTRL|SHIFT", key = "+", action = action.IncreaseFontSize },
    { mods = "CTRL|SHIFT", key = ")", action = action.ResetFontSize },

    -- command center
    { mods = "CTRL|SHIFT", key = "p", action = action.ActivateCommandPalette },

    -- UI
    { mods = mod, key = "b", action = toggleBlur },
  }

  -- url openr with mouse
  cfg.mouse_bindings = {
    {
      mods = "CTRL",
      event = { Up = { streak = 1, button = "Left" } },
      action = action.OpenLinkAtMouseCursor,
    },
    -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = action.Nop,
    },
  }
end

return M

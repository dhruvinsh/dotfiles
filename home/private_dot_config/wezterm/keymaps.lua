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
  -- disable all the default mappings
  cfg.disable_default_key_bindings = true

  -- leader key: CTRL + SPACE
  cfg.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 }

  cfg.keys = {
    -- window management: splits, movement, spawn
    { mods = mod, key = "|", action = action.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
    { mods = mod, key = "-", action = action.SplitVertical({ domain = "CurrentPaneDomain" }) },

    { mods = alt, key = "UpArrow", action = action.ActivatePaneDirection("Up") },
    { mods = alt, key = "DownArrow", action = action.ActivatePaneDirection("Down") },
    { mods = alt, key = "LeftArrow", action = action.ActivatePaneDirection("Left") },
    { mods = alt, key = "RightArrow", action = action.ActivatePaneDirection("Right") },
    { mods = mod, key = "[", action = action.ActivateTabRelative(-1) },
    { mods = mod, key = "]", action = action.ActivateTabRelative(1) },

    { mods = mod, key = "d", action = action.SpawnTab("CurrentPaneDomain") },

    -- text management: copy-paste
    { mods = "CTRL|SHIFT", key = "c", action = action.CopyTo("Clipboard") },
    { mods = "CTRL|SHIFT", key = "v", action = action.PasteFrom("Clipboard") },

    -- command center
    { mods = "CTRL|SHIFT", key = "p", action = action.ActivateCommandPalette },
  }

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

-- Hyprland configuration (Lua) — translated from hyprlang for Hyprland 0.55.x
-- See https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
  output = "DP-1",
  mode = "2560x1440@143.97",
  position = "0x0",
  scale = 1,
})

--------------------------
---- EXTERNAL CONFIGS ----
--------------------------

-- Each required file has its OWN Lua scope (unlike hyprlang's `source`).
-- Environment variables (chezmoi template -> env.lua)
require("env")

-------------------
---- AUTOSTART ----
-------------------

-- Autostart processes (exec-once equivalents) live in execs.lua
require("execs")

-----------------------
---- LOOK AND FEEL ----
-----------------------

-- https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 20,

    border_size = 2,

    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },

    resize_on_border = false,

    allow_tearing = false,

    layout = "dwindle",
  },

  decoration = {
    rounding = 10,
    rounding_power = 2,

    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = 0xee1a1a1a,
    },

    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },
})

-- Animation curves & animations
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Dwindle layout — https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- NOTE: dwindle:pseudotile was REMOVED in Hyprland 0.55 (it did nothing). Only preserve_split remains.
-- Pseudotiling is still toggled per-window via the `pseudo` dispatcher (SUPER + P, see keybind.lua).
hl.config({
  dwindle = {
    preserve_split = true, -- You probably want this
  },
})

-- Master layout — https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
hl.config({
  master = {
    new_status = "master",
  },
})

----------------
----  MISC  ----
----------------

hl.config({
  misc = {
    force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false, -- If true disables the random hyprland logo / anime girl background.
    middle_click_paste = false, -- Disable middle click paste
  },
})

---------------
---- INPUT ----
---------------

hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "",
    kb_rules = "",

    follow_mouse = 1,

    sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad = {
      natural_scroll = false,
    },
  },
})

-- Example per-device config
-- https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/
hl.device({
  name = "epic-mouse-v1",
  sensitivity = -0.5,
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Brave -> tag as chromium-based-browser
hl.window_rule({
  name = "Brave",
  match = { class = "([bB]rave-browser)" },
  tag = "+chromium-based-browser",
})

-- chromium-based browsers: slight inactive transparency
hl.window_rule({
  name = "chromium",
  match = { tag = "chromium-based-browser" },
  opacity = "1 0.97",
})

-- popout player: full opacity
hl.window_rule({
  name = "popout-player",
  match = { initial_title = [[((?i)(?:[a-z0-9-]+\.)*youtube\.com_/|app\.zoom\.us_/wc/home)]] },
  opacity = "1.0 1.0",
})

-- Firefox Picture-in-Picture: floating, pinned, no max size, full opacity
hl.window_rule({
  name = "popup-player-firefox",
  match = { initial_title = "^(Picture in picture)$" },
  float = true,
  pin = true,
  no_max_size = true,
  opacity = "1.0 1.0",
})

-- Thunar rename dialog -> float
hl.window_rule({
  name = "Thunar",
  match = { class = "thunar", title = "Rename.*" },
  float = true,
})

-- Thunar file-operation dialog -> float
hl.window_rule({
  name = "Thunar-File-Operation",
  match = { class = "thunar", title = [[File\ Operation.*]] },
  float = true,
})

-- xarchiver -> float
hl.window_rule({
  name = "xarchiver",
  match = { class = "xarchiver" },
  float = true,
})

-- Ignore maximize requests from all apps
hl.window_rule({
  name = "ignore-maximize",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name = "fix-xwayland-dragging",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

---------------------
---- KEYBINDINGS ----
---------------------

require("keybind")

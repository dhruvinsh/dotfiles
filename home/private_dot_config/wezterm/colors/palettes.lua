local M = {}

-- schemer-dark color scheme
-- base00 = "#16161D",
-- base01 = "#3e4451",
-- base02 = "#2c313c",
-- base03 = "#565c64",
-- base04 = "#6c7891",
-- base05 = "#abb2bf",
-- base06 = "#9a9bb3",
-- base07 = "#c5c8e6",
-- base08 = "#e06c75",
-- base09 = "#d19a66",
-- base0A = "#e5c07b",
-- base0B = "#98c379",
-- base0C = "#56b6c2",
-- base0D = "#0184bc",
-- base0E = "#c678dd",
-- base0F = "#a06949",

M.onedark = {
  foreground = "#abb2bf", -- base05
  background = "#16161D", -- base00

  cursor_bg = "#abb2bf", -- base05
  cursor_border = "#abb2bf", -- base05
  cursor_fg = "#abb2bf", -- base05

  selection_bg = "#abb2bf", -- base05
  selection_fg = "#16161D", -- base00

  split = "#6b6b6b",
  visual_bell = "#524f67",

  ansi = {
    "#16161D", -- base00
    "#e06c75", -- base08
    "#98c379", -- base0B
    "#e5c07b", -- base0A
    "#0184bc", -- base0D
    "#c678dd", -- base0E
    "#56b6c2", -- base0C
    "#abb2bf", -- base05
  },
  brights = {
    "#565c64", -- base03
    "#e06c75", -- base08
    "#98c379", -- base0B
    "#e5c07b", -- base0A
    "#0184bc", -- base0D
    "#c678dd", -- base0E
    "#56b6c2", -- base0C
    "#c5c8e6", -- base07
  },

  tab_bar = {
    -- The color of the strip that goes along the top of the window
    -- (does not apply when fancy tab bar is in use)
    background = "#181818",

    -- The active tab is the one that has focus in the window
    active_tab = {
      -- The color of the background area for the tab
      bg_color = "#181818",
      -- The color of the text for the tab
      fg_color = "#d8d8d8",

      -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
      -- label shown for this tab.
      -- The default is "Normal"
      intensity = "Normal",

      -- Specify whether you want "None", "Single" or "Double" underline for
      -- label shown for this tab.
      -- The default is "None"
      underline = "None",

      -- Specify whether you want the text to be italic (true) or not (false)
      -- for this tab.  The default is false.
      italic = false,

      -- Specify whether you want the text to be rendered with strikethrough (true)
      -- or not for this tab.  The default is false.
      strikethrough = false,
    },

    -- Inactive tabs are the tabs that do not have focus
    inactive_tab = {
      bg_color = "#181818",
      fg_color = "#6b6b6b",

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over inactive tabs
    inactive_tab_hover = {
      bg_color = "#181818",
      fg_color = "#d8d8d8",
      italic = true,

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `inactive_tab_hover`.
    },

    -- The new tab button that let you create new tabs
    new_tab = {
      bg_color = "#181818",
      fg_color = "#6b6b6b",

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab`.
    },

    -- You can configure some alternate styling when the mouse pointer
    -- moves over the new tab button
    new_tab_hover = {
      bg_color = "#181818",
      fg_color = "#d8d8d8",
      italic = true,

      -- The same options that were listed under the `active_tab` section above
      -- can also be used for `new_tab_hover`.
    },
  },
}

M.tokyonight = {
  foreground = "#c8d3f5",
  background = "#222436",

  cursor_bg = "#c8d3f5",
  cursor_border = "#c8d3f5",
  cursor_fg = "#222436",

  selection_bg = "#2d3f76",
  selection_fg = "#c8d3f5",

  split = "#82aaff",
  compose_cursor = "#ff966c",
  scrollbar_thumb = "#2f334d",

  ansi = { "#1b1d2b", "#ff757f", "#c3e88d", "#ffc777", "#82aaff", "#c099ff", "#86e1fc", "#828bb8" },
  brights = { "#444a73", "#ff757f", "#c3e88d", "#ffc777", "#82aaff", "#c099ff", "#86e1fc", "#c8d3f5" },

  tab_bar = {
    inactive_tab_edge = "#1e2030",
    background = "#222436",

    active_tab = {
      fg_color = "#1e2030",
      bg_color = "#82aaff",
    },
    inactive_tab = {
      fg_color = "#545c7e",
      bg_color = "#2f334d",
    },
    inactive_tab_hover = {
      fg_color = "#82aaff",
      bg_color = "#2f334d",
      italic = true,
    },
    new_tab = {
      fg_color = "#82aaff",
      bg_color = "#222436",
    },
    new_tab_hover = {
      fg_color = "#82aaff",
      bg_color = "#222436",
      intensity = "Bold",
    },
  },
}

M.gruvbox = {
  -- gruvbox color palette
  foreground = "#ebdbb2",
  background = "#282828",

  cursor_bg = "#ebdbb2",
  cursor_border = "#ebdbb2",
  cursor_fg = "#282828",

  selection_bg = "#665c54",
  selection_fg = "#ebdbb2",

  split = "#83a598",
  compose_cursor = "#fe8019",
  scrollbar_thumb = "#928374",

  ansi = { "#282828", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#a89984" },
  brights = { "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#ebdbb2" },

  tab_bar = {
    inactive_tab_edge = "#282828",
    background = "#282828",

    active_tab = {
      fg_color = "#282828",
      bg_color = "#83a598",
    },
    inactive_tab = {
      fg_color = "#928374",
      bg_color = "#3c3836",
    },
    inactive_tab_hover = {
      fg_color = "#83a598",
      bg_color = "#3c3836",
      italic = true,
    },
    new_tab = {
      fg_color = "#83a598",
      bg_color = "#282828",
    },
    new_tab_hover = {
      fg_color = "#83a598",
      bg_color = "#282828",
      intensity = "Bold",
    },
  },
}

return M

--[[/* vim: set filetype=lua: */]]

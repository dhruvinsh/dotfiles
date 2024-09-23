local M = {}
local palette = require("colors.palettes")["gruvbox"]

M.setup = function(cfg)
  cfg.colors = {
    foreground = palette.foreground,
    background = palette.background,

    cursor_bg = palette.cursor_bg,
    cursor_border = palette.cursor_border,
    cursor_fg = palette.cursor_fg,

    selection_fg = palette.selection_fg,
    selection_bg = palette.selection_bg,

    scrollbar_thumb = "#6b6b6b",
    split = "#6b6b6b",
    visual_bell = "#524f67", -- pending

    ansi = palette.ansi,
    brights = palette.brights,

    indexed = { [136] = "#af8700" },

    -- Since: 20220319-142410-0fcdea07
    -- When the IME, a dead key or a leader key are being processed and are effectively
    -- holding input pending the result of input composition, change the cursor
    -- to this color to give a visual cue about the compose state.
    compose_cursor = "#75b5aa",

    -- Colors for copy_mode and quick_select
    -- available since: 20220807-113146-c2fee766
    -- In copy_mode, the color of the active text is:
    -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
    -- 2. selection_* otherwise
    copy_mode_active_highlight_bg = { Color = "#000000" },
    -- use `AnsiColor` to specify one of the ansi color palette values
    -- (index 0-15) using one of the names "Black", "Maroon", "Green",
    --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
    -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
    copy_mode_active_highlight_fg = { AnsiColor = "Black" },
    copy_mode_inactive_highlight_bg = { Color = "#52ad70" },
    copy_mode_inactive_highlight_fg = { AnsiColor = "White" },

    quick_select_label_bg = { Color = "peru" },
    quick_select_label_fg = { Color = "#ffffff" },
    quick_select_match_bg = { AnsiColor = "Navy" },
    quick_select_match_fg = { Color = "#ffffff" },
  }

  local tab_bar
  if palette.tab_bar then
    tab_bar = palette.tab_bar
  else
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
    }
  end

  cfg.colors.tab_bar = tab_bar
end

return M

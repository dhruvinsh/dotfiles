local wezterm = require("wezterm")
local utils = require("utils.path")

local M = {}

-- reference: https://github.com/yutkat/dotfiles/blob/main/.config/wezterm/on.lua
-- selene: allow(unused_variable)
---@diagnostic disable-next-line: unused-local
M.create_tab_title = function(tab, tabs, panes, config, hover, max_width)
  -- take care of user title case
  local user_title = tab.active_pane.user_vars.panetitle
  if user_title ~= nil and #user_title > 0 then
    return tab.tab_index + 1 .. ":" .. user_title
  end

  local title = wezterm.truncate_right(utils.basename(tab.active_pane.foreground_process_name), max_width)
  if title == "" then
    local dir = string.gsub(tab.active_pane.title, "(.*[: ])(.*)]", "%2")
    dir = utils.convert_useful_path(dir)
    title = wezterm.truncate_right(dir, max_width)
  end

  -- add "copy" when copy-mode is activated
  local copy_mode, n = string.gsub(tab.active_pane.title, "(.+) mode: .*", "%1", 1)
  if copy_mode == nil or n == 0 then
    copy_mode = ""
  else
    copy_mode = wezterm.nerdfonts.md_content_copy .. " : "
  end

  return copy_mode .. tab.tab_index + 1 .. ":" .. title
end

M.setup = function(colors)
  wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = M.create_tab_title(tab, tabs, panes, config, hover, max_width)

    local solid_left_arrow = ""
    local solid_right_arrow = ""

    -- https://github.com/wez/wezterm/issues/807
    -- local edge_background = scheme.background
    -- https://github.com/wez/wezterm/blob/61f01f6ed75a04d40af9ea49aa0afe91f08cb6bd/config/src/color.rs#L245
    local edge_background = colors.background
    local background = colors.tab_bar.inactive_tab.bg_color or colors.ansi[1]
    local foreground = colors.tab_bar.inactive_tab.fg_color or colors.ansi[5]

    if tab.is_active then
      background = colors.tab_bar.active_tab.bg_color or colors.brights[1]
      foreground = colors.tab_bar.active_tab.fg_color or colors.brights[8]
    elseif hover then
      background = colors.tab_bar.inactive_tab_hover.bg_color or colors.cursor_bg
      foreground = colors.tab_bar.inactive_tab_hover.fg_color or colors.cursor_fg
    end

    local edge_foreground = background

    return {
      { Attribute = { Intensity = "Bold" } },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = solid_left_arrow },
      { Background = { Color = background } },
      { Foreground = { Color = foreground } },
      { Text = title },
      { Background = { Color = edge_background } },
      { Foreground = { Color = edge_foreground } },
      { Text = solid_right_arrow },
      { Attribute = { Intensity = "Normal" } },
    }
  end)
end

return M

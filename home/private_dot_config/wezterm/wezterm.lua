local wezterm = require("wezterm")
local ui = require("ui")
local fonts = require("fonts")
local program = require("program")
local keymaps = require("keymaps")
local tab_title = require("events.tab_title")
local zen_mode = require("events.zen_mode")
local colors = require("colors")

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- NOTE: first load colors
colors.setup(config)

ui.setup(config)
fonts.setup(config)
program.setup(config)
keymaps.setup(config)
tab_title.setup(config.colors)
zen_mode.setup()

return config

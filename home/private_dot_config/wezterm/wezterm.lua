local wezterm = require("wezterm")
local colors = require("colors")
local domain = require("events.domain")
local fonts = require("fonts")
local full_screen = require("events.full_screen")
local keymaps = require("keymaps")
local platform = require("utils.platform")
local program = require("program")
local tab_title = require("events.tab_title")
local ui = require("ui")
local zen_mode = require("events.zen_mode")

local config = wezterm.config_builder()

-- NOTE: first load colors
colors.setup(config)

fonts.setup(config)
keymaps.setup(config)
program.setup(config)
ui.setup(config)

-- Events
domain.setup()
if platform.is_mac then
  full_screen.setup()
end
tab_title.setup(config.colors)
zen_mode.setup()

return config

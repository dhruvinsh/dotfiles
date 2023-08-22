local wezterm = require("wezterm")
local ui = require("ui")
local program = require("program")
local keymaps = require("keymaps")

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

ui.setup(config)
program.setup(config)
keymaps.setup(config)

return config

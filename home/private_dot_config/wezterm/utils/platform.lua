local wezterm = require("wezterm")

local M = {}

M.is_win = string.find(wezterm.target_triple, "windows")
M.is_linux = string.find(wezterm.target_triple, "linux")
M.is_mac = string.find(wezterm.target_triple, "apple")

return M

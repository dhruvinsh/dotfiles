local platform = require("utils.platform")
local M = {}

---@param cfg table
M.setup = function(cfg)
  if platform.is_win then
    cfg.default_prog = { "wsl" }
    cfg.launch_menu = {
      { label = "WSL", args = { "wsl" } },
      { label = "PowerShell Core", args = { "pwsh" } },
      { label = "PowerShell Desktop", args = { "powershell.exe", "-NoLogo" } },
      { label = "Command Prompt", args = { "cmd" } },
      { label = "Nushell", args = { "nu" } },
    }
  elseif platform.is_mac then
    cfg.default_prog = { "zsh", "-l" }
    cfg.launch_menu = {
      { label = "Zsh", args = { "zsh", "-l" } },
    }
  end
end

return M

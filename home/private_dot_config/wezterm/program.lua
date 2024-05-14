local wezterm = require("wezterm")
local platform = require("utils.platform")
local wsl = require("wsl")
local M = {}

---@param cfg table
M.setup = function(cfg)
  if platform.is_win then
    local ip = wsl.get_ip()
    if not ip then
      wezterm.log_error("Could not able to find WSL IP address")
      cfg.default_domain = "local"
    end

    cfg.ssh_domains = {
      {
        name = "wsl:ssh",
        remote_address = ip,
        username = "ds",
        multiplexing = "None",
        default_prog = { "zsh" },
        assume_shell = "Posix",
      },
    }
    cfg.launch_menu = {
      { label = "PowerShell Core", args = { "pwsh" }, domain = { DomainName = "local" } },
      { label = "Command Prompt", args = { "cmd" }, domain = { DomainName = "local" } },
      { label = "Nushell", args = { "nu" }, domain = { DomainName = "local" } },
    }
    cfg.default_domain = "wsl:ssh"
  elseif platform.is_mac then
    cfg.default_prog = { "zsh", "-l" }
    cfg.launch_menu = {
      { label = "Zsh", args = { "zsh", "-l" } },
    }
  end
end

return M

local wezterm = require("wezterm")

local M = {}

M.file_name = wezterm.home_dir .. "/.wsl_ip"

-- in the case of wsl get the IP from the file if present
function M.get_ip()
  wezterm.log_info("Getting IP from " .. M.file_name)
  local file = io.open(M.file_name, "r")
  if file ~= nil then
    return file:read()
  end

  -- file don't exists we will try to create one
  local success = M.write_ip()
  if not success then
    return success
  end

  return success
end

---@return boolean|string
function M.write_ip()
  local success, stdout, _ = wezterm.run_child_process({ "wsl", "hostname", "-I" })
  if not success then
    return false
  end

  local ip = stdout:gmatch("%d+%.%d+%.%d+%.%d+")()

  -- write the IP address for future use
  local file = io.open(M.file_name, "w+")
  if file ~= nil then
    file:write(ip)
  end
  return ip
end

return M

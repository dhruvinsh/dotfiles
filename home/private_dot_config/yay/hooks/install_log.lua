-- Append every package yay resolved into a successful transaction to
-- <state_dir>/install.log, an audit trail for "when did this AUR package land,
-- and from where". A package whose build failed mid-run may still be listed.
-- Format: <ISO time>\t<source>\t<name>\t<old> -> <new>\t<reason>

local policy = require("policy")

local log_file = policy.state_dir() .. "/install.log"

yay.create_autocmd("PostInstall", {
  desc = "append installs to the audit log",
  callback = function(event)
    local f = io.open(log_file, "a")
    if not f then
      yay.log.warn("cannot write " .. log_file)
      return
    end
    local now = os.date("!%Y-%m-%dT%H:%M:%SZ")
    for _, pkg in ipairs(event.data.packages) do
      local old = pkg.local_version ~= "" and pkg.local_version or "(new)"
      f:write(table.concat({ now, pkg.source, pkg.name, old .. " -> " .. pkg.version, pkg.reason }, "\t") .. "\n")
    end
    f:close()
  end,
})

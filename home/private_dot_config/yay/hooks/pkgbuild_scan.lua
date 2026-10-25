-- Scan the AUR repo files (PKGBUILD, *.install, helper scripts, patches) for
-- red flags before the diff menu.
--
-- This is a tripwire, not a scanner: "block" findings abort the run, "warn"
-- findings are printed so you know where to look in the diff. Commented-out
-- lines are ignored; backslash-continued lines are joined first. Override per
-- package with YAY_TRUST (see policy.lua).

local policy = require("policy")

local SHELLS = { sh = true, bash = true, zsh = true, dash = true, python = true, python3 = true, perl = true }
local WRAPPERS = { sudo = true, doas = true, env = true, command = true, exec = true }

-- Text after any "|" runs a shell, directly or through a sudo/env-style
-- wrapper (whose flags and arguments may come before the shell).
local function pipes_to_shell(line)
  for segment in line:gmatch("|([^|]*)") do
    local first = true
    local wrapped = false
    for word in segment:gmatch("%S+") do
      local cmd = word:match("[^/]+$")
      if SHELLS[cmd] and (first or wrapped) then
        return true
      end
      if first then
        wrapped = WRAPPERS[cmd] or false
        if not wrapped then
          break
        end
        first = false
      end
    end
  end
  return false
end

local function has(line, ...)
  for i = 1, select("#", ...) do
    if line:find(select(i, ...), 1, true) then
      return true
    end
  end
  return false
end

-- Output reaches an interpreter: pipe, process substitution, eval, `sh -c`.
local function executes(l)
  return pipes_to_shell(l) or has(l, "<(", "eval") or l:find("sh%s+%-c") ~= nil
end

local RULES = {
  {
    level = "block",
    desc = "remote script executed",
    test = function(l)
      return has(l, "curl", "wget") and executes(l)
    end,
  },
  {
    level = "block",
    desc = "base64-decoded payload executed",
    test = function(l)
      return has(l, "base64") and has(l, " -d", "--decode") and executes(l)
    end,
  },
  {
    level = "block",
    desc = "raw socket via /dev/tcp or /dev/udp",
    test = function(l)
      return has(l, "/dev/tcp/", "/dev/udp/")
    end,
  },
  {
    level = "block",
    desc = "chat/paste exfil or payload host",
    test = function(l)
      return has(
        l,
        "discord.com/api/webhooks",
        "discordapp.com/api/webhooks",
        "cdn.discordapp.com",
        "api.telegram.org",
        "pastebin.com",
        "transfer.sh",
        "termbin.com"
      )
    end,
  },
  {
    level = "warn",
    desc = "URL with a raw IP address",
    test = function(l)
      return l:find("://%d+%.%d+%.%d+%.%d+") ~= nil
    end,
  },
  {
    level = "warn",
    desc = "plain http:// download",
    test = function(l)
      return has(l, "http://") and not l:match("^%s*url=")
    end,
  },
  {
    level = "warn",
    desc = "URL shortener",
    test = function(l)
      return has(l, "bit.ly/", "tinyurl.com/", "is.gd/")
    end,
  },
}

local function read(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local body = f:read("*a")
  f:close()
  return body
end

-- Files tracked in the AUR git repo; install scripts among them run as root.
local function repo_files(dir)
  local files = {}
  local p = io.popen("git -C " .. policy.shell_quote(dir) .. " ls-files -z 2>/dev/null")
  if p then
    for name in p:read("*a"):gmatch("[^%z]+") do
      if name ~= "PKGBUILD" and name ~= ".SRCINFO" and name ~= ".gitignore" then
        files[#files + 1] = name
      end
    end
    p:close()
  end
  return files
end

local function scan(label, body, findings)
  if body:find("%z") then
    return -- binary
  end
  local n, start, buf = 0, 0, nil
  for line in (body .. "\n"):gmatch("([^\n]*)\n") do
    n = n + 1
    if buf then
      buf = buf .. " " .. line
    else
      buf, start = line, n
    end
    if buf:sub(-1) == "\\" then
      buf = buf:sub(1, -2)
    else
      if not buf:match("^%s*#") then
        for _, rule in ipairs(RULES) do
          if rule.test(buf) then
            table.insert(findings, { level = rule.level, where = label .. ":" .. start, desc = rule.desc })
          end
        end
      end
      buf = nil
    end
  end
end

yay.create_autocmd("AURPreInstall", {
  desc = "scan AUR repo files for red flags",
  callback = function(event)
    local d = event.data
    local findings = {}
    scan("PKGBUILD", d.pkgbuild, findings)
    for _, name in ipairs(repo_files(d.dir)) do
      local body = read(d.dir .. "/" .. name)
      if body then
        scan(name, body, findings)
      end
    end

    local blocked = false
    for _, f in ipairs(findings) do
      yay.log.warn(string.format("%s [%s] %s: %s", d.base, f.level, f.where, f.desc))
      blocked = blocked or f.level == "block"
    end

    if blocked and not policy.is_trusted_base(d) then
      yay.abort(d.base .. ": AUR files tripped a block rule; review them, then rerun with YAY_TRUST=" .. d.base)
    end
  end,
})

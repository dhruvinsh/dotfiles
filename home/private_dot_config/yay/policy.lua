-- Shared AUR trust policy for the hooks in hooks/.
--
-- The hooks hold back or block AUR packages that look risky. YAY_TRUST is the
-- escape hatch for packages you have reviewed by hand (name or pkgbase):
--   YAY_TRUST=foo yay -S foo          trust one package
--   YAY_TRUST="foo,bar" yay -Syu      several, comma or space separated
--   YAY_TRUST='*' yay ...             trust everything (disables the gates)
-- Trusting a package bypasses every gate for it (backoff, maintainer, scan).

local M = {}

-- Hold AUR updates until the PKGBUILD has been public this long, so a
-- malicious push has time to be noticed and reverted.
M.backoff_days = 3

-- Hide AUR packages younger than this from search results (typosquats).
-- YAY_SHOW_NEW=1 shows them without loosening any install gate.
M.new_package_days = 14
M.show_new = os.getenv("YAY_SHOW_NEW") ~= nil

local DAY = 24 * 60 * 60

local trusted = {}
for name in (os.getenv("YAY_TRUST") or ""):gmatch("[^%s,]+") do
  trusted[name] = true
end

function M.is_trusted(...)
  if trusted["*"] then
    return true
  end
  for i = 1, select("#", ...) do
    local name = select(i, ...)
    if name and trusted[name] then
      return true
    end
  end
  return false
end

-- Trust check against an AUR event payload: pkgbase plus every split package.
function M.is_trusted_base(d)
  local names = { d.base }
  for _, pkg in ipairs(d.packages or {}) do
    names[#names + 1] = pkg.name
  end
  return M.is_trusted(unpack(names))
end

-- UpgradeSelect reports VCS upgrades (--devel) as repository "devel".
function M.is_aur(repository)
  return repository == "aur" or repository == "devel"
end

function M.is_recent(ts, days)
  return ts ~= nil and ts > 0 and ts >= os.time() - days * DAY
end

-- Human-readable age, e.g. "5h" or "2d".
function M.age(ts)
  local hours = math.max(0, math.floor((os.time() - ts) / 3600))
  if hours < 48 then
    return hours .. "h"
  end
  return math.floor(hours / 24) .. "d"
end

function M.shell_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Persistent state lives outside build_dir (~/.cache/yay), which yay's clean
-- menu and `yay -Sc` can wipe.
local state_dir
function M.state_dir()
  if not state_dir then
    local base = os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")
    state_dir = base .. "/yay"
    os.execute("mkdir -p " .. M.shell_quote(state_dir))
  end
  return state_dir
end

return M

-- Hold AUR upgrades whose maintainer changed since it was last recorded
-- (possible takeover of an orphaned or compromised package).
--
-- The known maintainer for each package is stored in <state_dir>/maintainer_cache
-- (one "pkgname=maintainer" per line). An unknown package is recorded silently,
-- but only once its PKGBUILD is outside the backoff window, so a fresh
-- takeover push can't seed itself. Afterwards:
--   * same maintainer      → debug "match"
--   * different maintainer → excluded from the upgrade; the cache keeps the old
--                            maintainer until you accept with YAY_TRUST=<pkg>
--   * orphaned (no maintainer) → warning only
--
-- Only -Syu is covered: UpgradeSelect doesn't fire for `yay -S <installed>`, and
-- AURPreInstall has no maintainer field.
--
-- Seed every installed AUR package (run once per machine):
--   yay -Si $(pacman -Qmq) | awk -F' *: ' '/^Name/{n=$2} /^Maintainer/{print n"="$2}' \
--     | grep -v '=None$' >> ~/.local/state/yay/maintainer_cache

local policy = require("policy")

local cache_file = policy.state_dir() .. "/maintainer_cache"
-- Pre-policy.lua location; read once so an existing baseline carries over.
local legacy_file = (os.getenv("XDG_CACHE_HOME") or (os.getenv("HOME") .. "/.cache")) .. "/yay/maintainer_cache"

local function load_cache()
  local cache = {}
  local f = io.open(cache_file, "r") or io.open(legacy_file, "r")
  if not f then
    return cache
  end
  for line in f:lines() do
    local name, maintainer = line:match("^([^=]+)=(.*)$")
    if name then
      cache[name] = maintainer
    end
  end
  f:close()
  return cache
end

-- Write-then-rename so a crash never leaves a truncated baseline behind.
local function save_cache(cache)
  local tmp = cache_file .. ".tmp"
  local f = io.open(tmp, "w")
  if not f then
    yay.log.warn("cannot write " .. tmp)
    return
  end
  for name, maintainer in pairs(cache) do
    f:write(name .. "=" .. maintainer .. "\n")
  end
  f:close()
  os.rename(tmp, cache_file)
end

yay.create_autocmd("UpgradeSelect", {
  desc = "hold AUR upgrades with a new maintainer",
  callback = function(event)
    local cache = load_cache()
    local dirty = false
    local exclude = {}

    for _, pkg in ipairs(event.data.upgrades) do
      if policy.is_aur(pkg.repository) then
        local cached = cache[pkg.name]
        if pkg.maintainer == "" then
          yay.log.warn(pkg.name .. " is orphaned; anyone can adopt it")
        elseif cached == nil then
          if not policy.is_recent(pkg.last_modified, policy.backoff_days) then
            cache[pkg.name] = pkg.maintainer
            dirty = true
          end
        elseif cached == pkg.maintainer then
          yay.log.debug("match: " .. pkg.name .. " " .. pkg.maintainer)
        elseif policy.is_trusted(pkg.name, pkg.base) then
          yay.log.warn(pkg.name .. ": accepted new maintainer " .. pkg.maintainer .. " (was " .. cached .. ")")
          cache[pkg.name] = pkg.maintainer
          dirty = true
        else
          yay.log.error(
            string.format(
              "%s: maintainer changed %s -> %s; holding upgrade. Review the PKGBUILD history, then rerun with YAY_TRUST=%s",
              pkg.name,
              cached,
              pkg.maintainer,
              pkg.base ~= "" and pkg.base or pkg.name
            )
          )
          table.insert(exclude, pkg.name)
        end
      end
    end

    if dirty then
      save_cache(cache)
    end

    return { exclude = exclude, skip_menu = false }
  end,
})

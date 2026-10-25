-- Backoff: hold AUR packages whose PKGBUILD changed within policy.backoff_days.
--
--   * yay -Syu          → recent AUR upgrades are pre-excluded from the run
--   * yay -S / new deps → AURPreInstall aborts before any build work
--
-- An abort cancels the whole run, repo updates included. If a held package
-- blocks -Syu (e.g. a recent new AUR dependency), run `yay -Syu --repo` for
-- the repo side. Override per package with YAY_TRUST (see policy.lua).

local policy = require("policy")

local function held_msg(name, ts)
  return string.format("%s: PKGBUILD changed %s ago (backoff %dd)", name, policy.age(ts), policy.backoff_days)
end

yay.create_autocmd("UpgradeSelect", {
  desc = "hold recently modified AUR upgrades",
  callback = function(event)
    local exclude = {}
    for _, pkg in ipairs(event.data.upgrades) do
      if
        policy.is_aur(pkg.repository)
        and policy.is_recent(pkg.last_modified, policy.backoff_days)
        and not policy.is_trusted(pkg.name, pkg.base)
      then
        yay.log.warn("holding " .. held_msg(pkg.name, pkg.last_modified))
        table.insert(exclude, pkg.name)
      end
    end

    -- Pulled-in deps can't be excluded here; they will abort in AURPreInstall.
    for _, dep in ipairs(event.data.pulled_dependencies) do
      if policy.is_aur(dep.repository) and policy.is_recent(dep.last_modified, policy.backoff_days) then
        yay.log.warn("new dependency " .. held_msg(dep.name, dep.last_modified) .. "; exclude what pulls it in")
      end
    end

    return { exclude = exclude, skip_menu = false }
  end,
})

yay.create_autocmd("AURPreInstall", {
  desc = "block recently modified AUR installs",
  callback = function(event)
    local d = event.data
    if policy.is_recent(d.last_modified, policy.backoff_days) and not policy.is_trusted_base(d) then
      yay.abort(held_msg(d.base, d.last_modified) .. "; review it, then rerun with YAY_TRUST=" .. d.base)
    end
  end,
})

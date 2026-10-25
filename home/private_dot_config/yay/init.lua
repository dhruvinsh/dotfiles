-- yay config (v13+). Overlays config.json; command-line flags still win.
-- Only security-relevant or non-default options are set here. Unknown keys
-- abort startup, so stick to the names in https://jguer.github.io/yay/lua.html.
--
-- Model: hooks automatically hold or block risky AUR packages, and the
-- diff menu stays the human review step for whatever gets through.

-- Review ---------------------------------------------------------------------
yay.opt.diff_menu = true -- show PKGBUILD diffs before every AUR build
yay.opt.answer_diff = "" -- always ask; never pre-answer "None"
yay.opt.edit_menu = false -- diffs are the review; editing is ad hoc
yay.opt.clean_menu = false -- don't ask; build dirs are git-merged, so diffs stay accurate
yay.opt.clean_after = false -- true would `git reset --hard` dirs built with `yay -B`

-- Trust ----------------------------------------------------------------------
yay.opt.aururl = "https://aur.archlinux.org" -- pinned, TLS only
yay.opt.pgp_fetch = true -- prompt to import a PKGBUILD's validpgpkeys
yay.opt.devel = false -- -git packages track upstream HEAD; the backoff can't cover that
yay.opt.use_ask = false -- never auto-confirm package conflicts
yay.opt.double_confirm = true -- confirm again after the diff review
yay.opt.sudo_loop = false -- don't keep sudo hot while untrusted build() code runs
yay.opt.remove_make = "yes" -- remove makedepends after building

-- Hooks ----------------------------------------------------------------------
-- Shared knobs (backoff days, YAY_TRUST override) live in policy.lua.
require("hooks.recently_modified") -- 3-day backoff on AUR upgrades and installs
require("hooks.maintainer_change") -- hold upgrades on maintainer change
require("hooks.pkgbuild_scan") -- block obvious malicious patterns
require("hooks.new_packages") -- hide brand-new AUR packages from search (YAY_SHOW_NEW=1)
require("hooks.install_log") -- audit log in ~/.local/state/yay/install.log

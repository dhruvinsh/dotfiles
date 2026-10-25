-- Hide AUR packages first submitted within policy.new_package_days from
-- `yay -Ss` and the `yay <term>` number menu, so a fresh typosquat can't be
-- picked by accident (installed ones too: the payload has no installed flag).
-- Show them with YAY_SHOW_NEW=1; install gates still apply.

local policy = require("policy")

yay.create_autocmd("SearchFilter", {
  desc = "hide brand-new AUR packages",
  callback = function(event)
    if policy.show_new then
      return nil
    end
    local out, hidden = {}, 0
    for _, r in ipairs(event.data.results) do
      if r.source == "aur" and policy.is_recent(r.first_submitted, policy.new_package_days) then
        hidden = hidden + 1
      else
        out[#out + 1] = { source = r.source, name = r.name }
      end
    end

    if hidden == 0 then
      return nil
    end
    yay.log.warn(
      string.format("hid %d AUR package(s) newer than %dd; YAY_SHOW_NEW=1 to show", hidden, policy.new_package_days)
    )
    return out
  end,
})

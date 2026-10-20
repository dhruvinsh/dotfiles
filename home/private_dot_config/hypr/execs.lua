-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- exec-once equivalents: run once when Hyprland starts.

hl.on("hyprland.start", function()
  -- uwsm does not export UWSM_ACTIVE; detect it via the vars it sets for the compositor.
  local uwsm = os.getenv("UWSM_FINALIZE_VARNAMES") ~= nil or os.getenv("UWSM_ACTIVE") ~= nil

  local function run(cmd)
    if uwsm then
      -- Remove trailing & if present since systemd handles execution context
      local clean = cmd:gsub("%s*&$", "")
      hl.exec_cmd("uwsm app -- " .. clean .. " &")
    else
      hl.exec_cmd(cmd)
    end
  end

  -- NOTE: don't probe with os.execute() here -- Hyprland reaps children itself, so
  -- os.execute always returns (nil, "No child processes"). io.open is safe.
  local function file_exists(path)
    local f = io.open(path, "r")
    if f then
      f:close()
    end
    return f ~= nil
  end

  -- night light
  run("hyprsunset &")

  -- clipboard history
  run("wl-paste --type text --watch cliphist store")
  run("wl-paste --type image --watch cliphist store")

  -- USB automounting (with system tray support)
  run("udiskie &")

  -- appearance: cursor (directly in compositor)
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

  -- GTK4 / libadwaita apps
  hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
  -- GTK3 apps (requires adw-gtk3 theme)
  hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue-Dark"')
  hl.exec_cmd('gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark"')

  -- appearance: top bar, wallpaper
  run("waybar &")

  -- wallpaper-manager.sh persists the current wallpaper as a hyprpaper config, so
  -- hyprpaper paints it on the first frame (no default-wallpaper flash). The
  -- restore call is a fallback for first boot; it retries until hyprpaper answers.
  local wall_conf = os.getenv("HOME") .. "/.cache/wallpapers/hyprpaper.conf"
  if file_exists(wall_conf) then
    run("hyprpaper -c " .. wall_conf .. " &")
  else
    run("hyprpaper &")
  end
  hl.exec_cmd("~/.local/bin/wallpaper-manager.sh restore")

  -- authentication agent (already systemd managed user service)
  hl.exec_cmd("systemctl --user start hyprpolkitagent.service")

  -- swayosd volume/brightness listener daemon
  run("swayosd-server &")

  -- screenshot daemon (flameshot); SUPER+SHIFT+S -> flameshot gui
  run("flameshot &")
end)

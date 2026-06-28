-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
-- exec-once equivalents: run once when Hyprland starts.

hl.on("hyprland.start", function()
  -- night light
  hl.exec_cmd("gammastep &")

  -- clipboard history
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- appearance: cursor
  hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 24")

  -- GTK4 / libadwaita apps
  hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')
  -- GTK3 apps (requires adw-gtk3 theme)
  hl.exec_cmd('gsettings set org.gnome.desktop.interface gtk-theme "Flat-Remix-GTK-Blue-Dark"')
  hl.exec_cmd('gsettings set org.gnome.desktop.interface icon-theme "Flat-Remix-Blue-Dark"')

  -- appearance: top bar, wallpaper
  hl.exec_cmd("waybar &")
  hl.exec_cmd("hyprpaper &")
  hl.exec_cmd("sleep 2 && ~/.local/bin/wallpaper-manager.sh restore")

  -- authentication agent
  hl.exec_cmd("systemctl --user start hyprpolkitagent.service")
end)

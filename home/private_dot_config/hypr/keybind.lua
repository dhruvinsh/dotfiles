---------------------
---- KEYBINDINGS ----
---------------------

-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Programs (defined here because each required file has its own Lua scope)
local terminal = "ghostty"
local fileManager = "thunar"
local menu = "rofi -show drun"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- Session: power menu (wlogout; logout/reboot/shutdown live there) and lock
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("~/.local/bin/__wlogout.sh"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("loginctl lock-session")) -- same as i3
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("sh -c 'cliphist list | rofi -dmenu -p Clipboard | cliphist decode | wl-copy'"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("~/.local/bin/wallpaper-manager.sh select"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo()) -- dwindle
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle (replaces removed togglesplit dispatcher)

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces (1-10) and move active window to workspace with SHIFT
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:magic" }))

-- Screenshots (flameshot daemon is started in execs.lua)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("flameshot gui")) -- region + annotate
hl.bind("Print", hl.dsp.exec_cmd("flameshot screen -c")) -- focused screen -> clipboard
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("flameshot gui"))

-- Handy speech-to-text: its own global shortcuts can't grab keys on Wayland, so drive
-- the running instance (XDG autostart) through its CLI. Toggle: press once to start, again to stop.
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("handy --toggle-transcription"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("handy --toggle-post-process"))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.exec_cmd("handy --cancel"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / mic keys go through swayosd so the on-screen display shows.
-- Mute toggles must not repeat (holding the key would flap mute on/off).
local osd = "swayosd-client"
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd(osd .. " --output-volume raise --max-volume 100"),
  { locked = true, repeating = true }
)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osd .. " --output-volume lower"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osd .. " --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(osd .. " --input-volume mute-toggle"), { locked = true })
-- Keyboards without media keys
hl.bind(mainMod .. " + equal", hl.dsp.exec_cmd(osd .. " --output-volume raise --max-volume 100"), { locked = true, repeating = true })
hl.bind(mainMod .. " + minus", hl.dsp.exec_cmd(osd .. " --output-volume lower"), { locked = true, repeating = true })
hl.bind(mainMod .. " + SHIFT + M", hl.dsp.exec_cmd(osd .. " --input-volume mute-toggle"), { locked = true })
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(osd .. " --output-volume mute-toggle"), { locked = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

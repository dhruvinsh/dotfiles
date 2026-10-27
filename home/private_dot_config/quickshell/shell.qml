import Quickshell
import QtQuick

// Depth-effect wallpaper + picker. Started from hypr/execs.lua when qs is installed
// (hyprpaper otherwise); state comes from wallpaper-manager via state.json.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Wallpaper {}
    }

    Picker {}
}

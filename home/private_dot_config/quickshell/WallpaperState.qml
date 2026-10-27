pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Mirrors ~/.cache/wallpapers/state.json, written by wallpaper-manager.
Singleton {
    id: root

    property string wallpaper
    property string foreground
    property real foregroundRev // changes when the cutout is rebuilt in place
    property var colors: null // {text, accent, background} for the clock
    property real clockX: 0.5
    property real clockY: 0.08

    // emitted once per state.json change, after both properties are set
    signal updated

    function parse() {
        try {
            const state = JSON.parse(file.text());
            // a cutout only counts for the wallpaper it was made from
            root.wallpaper = state.wallpaper || "";
            root.foreground = state.foreground || "";
            root.colors = state.colors || null;
            root.foregroundRev = state.foregroundRev || 0;
            root.clockX = state.clock?.x ?? 0.5;
            root.clockY = state.clock?.y ?? 0.08;
            root.updated();
        } catch (e) {
            // half-written file: the next change notification brings the full one
        }
    }

    FileView {
        id: file

        path: Theme.cacheDir + "/state.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.parse()
    }
}

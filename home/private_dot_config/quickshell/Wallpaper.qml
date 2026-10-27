import Quickshell
import Quickshell.Wayland
import QtQuick

// One per output: wallpaper -> clock -> subject cutout (the depth effect).
// Two slots ping-pong so the old wallpaper stays up until the new one has
// decoded, then a random fade/wipe reveals it (idea from noctalia's wallpaper).
PanelWindow {
    id: win

    required property var modelData

    property int front: 0 // slot currently shown
    property int mode: 0 // transition: 0 fade, 1-4 wipe direction
    property real progress: 1 // reveal of the incoming slot
    property string shownWallpaper
    property bool pending: false

    readonly property int back: 1 - front

    function slotBg(i) {
        return i === 0 ? bgA : bgB;
    }
    function slotFg(i) {
        return i === 0 ? fgA : fgB;
    }

    function apply() {
        const wall = WallpaperState.wallpaper;
        const fg = WallpaperState.foreground;
        const rev = WallpaperState.foregroundRev;
        if (!wall)
            return;
        const busy = transition.running || pending;
        if (busy && wall === slotBg(back).path) {
            // the incoming wallpaper got its cutout mid-transition: swap it in, keep going
            slotFg(back).path = fg;
            slotFg(back).rev = rev;
            return;
        }
        if (busy && wall === shownWallpaper) {
            // switched back before the transition finished: cancel it
            transition.stop();
            pending = false;
            progress = 0;
        }
        if (wall === shownWallpaper) {
            // same wallpaper, the cutout just became available or was refit
            // to a moved clock: fade it in
            if (slotFg(front).path !== fg || slotFg(front).rev !== rev) {
                slotFg(front).path = fg;
                slotFg(front).rev = rev;
                cutoutFade.restart();
            }
            return;
        }
        if (!shownWallpaper) {
            // first frame: no transition
            slotBg(front).path = wall;
            slotFg(front).path = fg;
            slotFg(front).rev = rev;
            shownWallpaper = wall;
            return;
        }
        transition.stop();
        progress = 0;
        mode = Math.floor(Math.random() * 5);
        slotBg(back).path = wall;
        slotFg(back).path = fg;
        slotFg(back).rev = rev;
        pending = true;
        maybeStart();
    }

    function maybeStart() {
        if (!pending)
            return;
        const bg = slotBg(back), fg = slotFg(back);
        if (bg.status === Image.Error) {
            pending = false;
            return;
        }
        const fgReady = !fg.path || fg.status === Image.Ready || fg.status === Image.Error;
        if (bg.status === Image.Ready && fgReady) {
            pending = false;
            transition.start();
        }
    }

    screen: modelData
    color: "black"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "qs-wallpaper"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Component.onCompleted: apply()

    Connections {
        target: WallpaperState
        function onUpdated() {
            win.apply();
        }
    }

    NumberAnimation {
        id: transition

        target: win
        property: "progress"
        from: 0
        to: 1
        duration: 1500
        easing.type: Easing.InOutCubic
        onFinished: {
            win.shownWallpaper = win.slotBg(win.back).path;
            win.front = win.back;
            // free the outgoing slot's decoded images (now hidden behind the new ones)
            win.slotBg(win.back).path = "";
            win.slotFg(win.back).path = "";
        }
    }

    NumberAnimation {
        id: cutoutFade

        target: win.slotFg(win.front)
        property: "opacity"
        from: 0
        to: 1
        duration: 600
    }

    Item {
        id: stage

        anchors.fill: parent

        // backgrounds (incoming slot above the outgoing one)
        RevealImage {
            id: bgA
            z: win.front === 0 ? 0 : 0.5
            reveal: win.front === 0 ? 1 : win.progress
            mode: win.mode
            dpr: win.modelData.devicePixelRatio ?? 1
            onStatusChanged: win.maybeStart()
        }
        RevealImage {
            id: bgB
            z: win.front === 1 ? 0 : 0.5
            reveal: win.front === 1 ? 1 : win.progress
            mode: win.mode
            dpr: win.modelData.devicePixelRatio ?? 1
            onStatusChanged: win.maybeStart()
        }

        Clock {
            z: 1
            area: stage
            colors: WallpaperState.colors
            cx: WallpaperState.clockX
            cy: WallpaperState.clockY
        }

        // cutouts, revealed together with their background
        RevealImage {
            id: fgA
            z: win.front === 0 ? 2 : 2.5
            reveal: win.front === 0 ? 1 : win.progress
            mode: win.mode
            dpr: win.modelData.devicePixelRatio ?? 1
            onStatusChanged: win.maybeStart()
        }
        RevealImage {
            id: fgB
            z: win.front === 1 ? 2 : 2.5
            reveal: win.front === 1 ? 1 : win.progress
            mode: win.mode
            dpr: win.modelData.devicePixelRatio ?? 1
            onStatusChanged: win.maybeStart()
        }
    }
}

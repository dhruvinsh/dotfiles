import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

// Wallpaper picker (SUPER+W -> wallpaper-manager select -> qs ipc call picker toggle <monitor>).
// Drag the clock in the preview to move it for that wallpaper; r resets it to the guess.
// The manager passes the focused monitor: importing Quickshell.Hyprland instead would
// subscribe to every compositor event and keep qs busy while you work.
// Large preview of the highlighted wallpaper with the depth stack, a thumbnail
// carousel below. Left/Right/wheel to browse, Enter/click to apply, Esc to close.
Scope {
    id: root

    property bool open: false
    property var items: []
    property string monitor
    property int keepIndex: -1 // carousel position to restore after a refresh

    function toggle(monitor) {
        if (open) {
            open = false;
        } else {
            root.monitor = monitor;
            lister.running = true; // refresh the list (new files, new cutouts)
        }
    }

    // pos: [x, y] screen fractions (centre x, top y), or null for the automatic guess
    function moveClock(path, pos) {
        const where = pos ? [pos[0].toFixed(4), pos[1].toFixed(4)] : ["reset"];
        mover.command = [Theme.manager, "clock", path].concat(where);
        mover.running = true;
    }

    function applyWallpaper(path) {
        applier.command = [Theme.manager, "set", path];
        applier.running = true;
        open = false;
    }

    IpcHandler {
        target: "picker"

        function toggle(monitor: string): void {
            root.toggle(monitor);
        }
    }

    Process {
        id: lister

        command: [Theme.manager, "list", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.items = JSON.parse(text);
                } catch (e) {
                    root.items = [];
                }
                if (root.keepIndex >= 0) {
                    // refreshed after moving the clock: stay on the same wallpaper
                    carousel.currentIndex = root.keepIndex;
                    root.keepIndex = -1;
                }
                previewStage.dragX = -1;
                root.open = root.items.length > 0;
            }
        }
    }

    Process {
        id: applier
    }

    Process {
        id: mover

        onExited: {
            root.keepIndex = carousel.currentIndex;
            lister.running = true; // pick up the refit cutout and colours
        }
    }

    PanelWindow {
        id: win

        visible: root.open
        screen: Quickshell.screens.find(s => s.name === root.monitor) ?? Quickshell.screens[0]
        color: Qt.alpha(Theme.crust, 0.55)
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-picker"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        onVisibleChanged: {
            if (!visible) {
                root.items = []; // drop thumbnails and preview while closed
            } else {
                const cur = root.items.findIndex(i => i.current);
                carousel.currentIndex = Math.max(cur, 0);
                carousel.positionViewAtIndex(carousel.currentIndex, ListView.Center);
                carousel.forceActiveFocus();
            }
        }

        // click outside the card closes
        MouseArea {
            anchors.fill: parent
            onClicked: root.open = false
        }

        Rectangle {
            id: card

            readonly property var item: root.items[carousel.currentIndex] ?? null

            anchors.centerIn: parent
            width: Math.min(parent.width * 0.78, (parent.height * 0.82 - 260) * 16 / 9 + 48)
            height: content.height + 48
            radius: 20
            color: Qt.alpha(Theme.base, 0.85)
            border.color: Qt.alpha(Theme.accent, 0.35)
            border.width: 1

            MouseArea {
                anchors.fill: parent // swallow clicks so they don't close
            }

            Column {
                id: content

                x: 24
                y: 24
                width: parent.width - 48
                spacing: 18

                // preview: same stack as the desktop, miniature
                Rectangle {
                    id: preview

                    width: parent.width
                    height: width * win.height / Math.max(win.width, 1)
                    radius: 14
                    color: Theme.crust
                    clip: true

                    Item {
                        id: previewStage

                        // while dragging: the clock position in fractions, else -1
                        property real dragX: -1
                        property real dragY: -1

                        anchors.fill: parent

                        Image {
                            anchors.fill: parent
                            source: card.item ? "file://" + card.item.path : ""
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(width, height)
                            asynchronous: true
                        }
                        Clock {
                            id: previewClock

                            area: previewStage
                            colors: card.item?.colors ?? null
                            cx: previewStage.dragX >= 0 ? previewStage.dragX : (card.item?.clock?.x ?? 0.5)
                            cy: previewStage.dragX >= 0 ? previewStage.dragY : (card.item?.clock?.y ?? 0.08)
                            animate: previewStage.dragX < 0
                        }
                        Image {
                            anchors.fill: parent
                            // the query only busts the cache when the cutout is refit in place
                            source: card.item?.foreground ? "file://" + card.item.foreground + "?v=" + card.item.foregroundRev : ""
                            fillMode: Image.PreserveAspectCrop
                            sourceSize: Qt.size(width, height)
                            asynchronous: true
                            cache: false
                        }

                        MouseArea {
                            id: dragArea

                            property bool dragging: false
                            property real offX
                            property real offY

                            function overClock(x, y) {
                                return x >= previewClock.x && x <= previewClock.x + previewClock.width && y >= previewClock.y && y <= previewClock.y + previewClock.height;
                            }

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: dragging ? Qt.ClosedHandCursor : overClock(mouseX, mouseY) ? Qt.OpenHandCursor : Qt.ArrowCursor

                            onPressed: mouse => {
                                if (!card.item || mover.running || !overClock(mouse.x, mouse.y)) {
                                    mouse.accepted = false;
                                    return;
                                }
                                dragging = true;
                                offX = mouse.x - (previewClock.x + previewClock.width / 2);
                                offY = mouse.y - previewClock.y;
                            }
                            onPositionChanged: mouse => {
                                if (!dragging)
                                    return;
                                previewStage.dragX = Math.min(Math.max((mouse.x - offX) / width, 0), 1);
                                previewStage.dragY = Math.min(Math.max((mouse.y - offY) / height, 0), 1);
                            }
                            onReleased: {
                                if (!dragging)
                                    return;
                                dragging = false;
                                if (previewStage.dragX < 0)
                                    return; // a click, not a drag
                                // store where the clock really is (Clock clamps it on screen)
                                root.moveClock(card.item.path, [(previewClock.x + previewClock.width / 2) / width, previewClock.y / height]);
                            }
                        }
                    }

                    // badges
                    Row {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.margins: 14
                        spacing: 8

                        Badge {
                            text: card.item?.name ?? ""
                        }
                        Badge {
                            visible: card.item?.depth === "pending"
                            text: "no depth layer yet — generated on apply"
                            dim: true
                        }
                        Badge {
                            visible: card.item?.depth === "none"
                            text: "no subject found — no depth effect"
                            dim: true
                        }
                        Badge {
                            visible: mover.running
                            text: "fitting the depth layer to the clock…"
                            dim: true
                        }
                        Badge {
                            visible: !!card.item?.clock?.manual && !mover.running
                            text: "clock placed by you — r to reset"
                            dim: true
                        }
                        Badge {
                            visible: !!card.item?.current
                            text: "current"
                            accent: true
                        }
                    }
                }

                ListView {
                    id: carousel

                    width: parent.width
                    height: 150
                    orientation: ListView.Horizontal
                    spacing: 14
                    clip: true
                    model: root.items
                    highlightMoveDuration: 180
                    preferredHighlightBegin: width / 2 - 110
                    preferredHighlightEnd: width / 2 + 110
                    highlightRangeMode: ListView.ApplyRange
                    boundsBehavior: Flickable.StopAtBounds

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                            root.open = false;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (card.item)
                                root.applyWallpaper(card.item.path);
                        } else if (event.key === Qt.Key_R) {
                            if (card.item && card.item.clock?.manual && !mover.running)
                                root.moveClock(card.item.path, null);
                        } else if (event.key === Qt.Key_L) {
                            incrementCurrentIndex();
                        } else if (event.key === Qt.Key_H) {
                            decrementCurrentIndex();
                        } else {
                            return;
                        }
                        event.accepted = true;
                    }

                    WheelHandler {
                        onWheel: event => {
                            if (event.angleDelta.y < 0 || event.angleDelta.x < 0)
                                carousel.incrementCurrentIndex();
                            else
                                carousel.decrementCurrentIndex();
                        }
                    }

                    delegate: Item {
                        id: tile

                        required property var modelData
                        required property int index
                        readonly property bool selected: ListView.isCurrentItem

                        width: 220
                        height: carousel.height

                        Rectangle {
                            anchors.centerIn: parent
                            width: tile.selected ? parent.width : parent.width * 0.88
                            height: tile.selected ? parent.height : parent.height * 0.88
                            radius: 12
                            color: Theme.surface0
                            border.width: tile.selected ? 3 : (tile.modelData.current ? 2 : 0)
                            border.color: tile.selected ? Theme.accent : Theme.overlay1
                            opacity: tile.selected ? 1 : 0.7

                            Behavior on width {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                            Behavior on height {
                                NumberAnimation {
                                    duration: 150
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            Image {
                                anchors.fill: parent
                                anchors.margins: parent.border.width
                                source: "file://" + tile.modelData.thumb
                                fillMode: Image.PreserveAspectCrop
                                sourceSize: Qt.size(220, 150)
                                asynchronous: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (tile.selected)
                                    root.applyWallpaper(tile.modelData.path);
                                else
                                    carousel.currentIndex = tile.index;
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "←/→ browse   drag the clock to move it   r reset clock   ⏎ apply   esc close"
                    color: Theme.subtext0
                    font.family: Theme.font
                    font.pixelSize: 13
                }
            }
        }
    }

    component Badge: Rectangle {
        property alias text: label.text
        property bool dim: false
        property bool accent: false

        visible: label.text !== ""
        width: label.implicitWidth + 20
        height: label.implicitHeight + 10
        radius: height / 2
        color: accent ? Theme.accent : Qt.alpha(Theme.crust, 0.75)

        Text {
            id: label

            anchors.centerIn: parent
            color: parent.accent ? Theme.crust : (parent.dim ? Theme.subtext0 : Theme.text)
            font.family: Theme.font
            font.pixelSize: 13
        }
    }
}

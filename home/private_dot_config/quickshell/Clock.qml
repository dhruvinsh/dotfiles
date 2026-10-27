import Quickshell
import QtQuick

// Big time + date drawn between the wallpaper and its cutout. Sized relative to
// `area` so the picker preview can render a miniature of the same layout.
Item {
    id: root

    required property Item area
    // wallpaper-derived colours (wallpaper-manager), chezmoi palette as fallback
    property var colors: null
    // position in screen fractions: centre x, top y. Guessed per wallpaper by
    // wallpaper-depth, or wherever you dragged it in the picker
    property real cx: 0.5
    property real cy: 0.08
    readonly property color textColor: colors?.text ?? Theme.text
    readonly property color accentColor: colors?.accent ?? Theme.accent

    // minute precision: the background layer redraws once a minute, not every second
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    x: Math.min(Math.max(area.width * cx - width / 2, 0), area.width - width)
    y: Math.min(Math.max(area.height * cy, 0), area.height - height)

    // glide to a new position on wallpaper change (off while dragging)
    property bool animate: true

    Behavior on x {
        enabled: root.animate
        NumberAnimation {
            duration: 1500
            easing.type: Easing.InOutCubic
        }
    }
    Behavior on y {
        enabled: root.animate
        NumberAnimation {
            duration: 1500
            easing.type: Easing.InOutCubic
        }
    }
    width: column.width
    height: column.height

    Column {
        id: column
        spacing: -root.area.height * 0.02

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: root.textColor

            Behavior on color {
                ColorAnimation {
                    duration: 1500
                }
            }
            font.family: Theme.font
            font.pixelSize: root.area.height * 0.26
            font.weight: Font.ExtraBold
            font.letterSpacing: -root.area.height * 0.01
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
            color: root.accentColor

            Behavior on color {
                ColorAnimation {
                    duration: 1500
                }
            }
            font.family: Theme.fontItalic
            font.pixelSize: root.area.height * 0.045
            font.italic: true
        }
    }
}

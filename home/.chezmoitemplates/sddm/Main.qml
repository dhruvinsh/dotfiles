// lumen: minimal SDDM greeter styled after hyprlock.conf
// Colors/fonts come from theme.conf (rendered from .colorScheme by chezmoi).
import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.base

    readonly property real s: Math.max(0.6, Math.min(width / 1920, height / 1080))
    property int sessionIndex: sessionModel.lastIndex >= 0 ? sessionModel.lastIndex : 0
    property int userIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
    // itemAt() isn't reactive; reading count re-evaluates once delegates exist
    readonly property Item currentUser: users.count > 0 ? users.itemAt(userIndex) : null
    readonly property Item currentSession: sessions.count > 0 ? sessions.itemAt(sessionIndex) : null
    readonly property string userName: currentUser ? currentUser.name : userModel.lastUser
    readonly property string displayName: currentUser && currentUser.realName !== "" ? currentUser.realName : userName

    // Expose model rows by index (SDDM models have no JS accessor)
    Repeater {
        id: users
        model: userModel
        delegate: Item {
            required property string name
            required property string realName
        }
    }
    Repeater {
        id: sessions
        model: sessionModel
        delegate: Item {
            required property string name
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            errorText.text = "Wrong password"
            shake.restart()
            password.forceActiveFocus()
        }
        function onLoginSucceeded() {
            errorText.text = ""
        }
    }

    function login() {
        if (password.text === "")
            return
        errorText.text = ""
        sddm.login(userName, password.text, sessionIndex)
    }

    // ---- Background: blurred wallpaper + tint, gradient fallback ----
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: config.mantle }
            GradientStop { position: 1.0; color: config.crust }
        }
    }
    Image {
        id: wallpaper
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
    }
    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        visible: wallpaper.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        brightness: -0.12
        saturation: 0.15
    }
    Rectangle {
        anchors.fill: parent
        color: config.base
        opacity: 0.35
    }

    // ---- Clock / date ----
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: card.top
        anchors.bottomMargin: 48 * root.s
        spacing: 4 * root.s

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.text
            font.family: config.font
            font.pixelSize: 150 * root.s
            font.weight: Font.ExtraBold
        }
        Text {
            id: date
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.subtext1
            font.family: config.font
            font.pixelSize: 28 * root.s
        }
        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                const now = new Date()
                clock.text = Qt.formatTime(now, "HH:mm")
                date.text = Qt.formatDate(now, "dddd, d MMMM yyyy")
            }
        }
    }

    // ---- Login card ----
    Column {
        id: card
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 90 * root.s
        spacing: 18 * root.s

        // Avatar: initial in an accent ring
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 96 * root.s
            height: width
            radius: width / 2
            color: Qt.alpha(config.surface0, 0.85)
            border.color: config.accent
            border.width: 3
            Text {
                anchors.centerIn: parent
                text: root.displayName.charAt(0).toUpperCase()
                color: config.accent
                font.family: config.font
                font.pixelSize: 42 * root.s
                font.weight: Font.Bold
            }
        }

        // User name (click / arrows to cycle when there are several)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12 * root.s
            Text {
                visible: userModel.count > 1
                text: ""
                color: config.overlay1
                font.family: config.font
                font.pixelSize: 18 * root.s
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.userIndex = (root.userIndex - 1 + userModel.count) % userModel.count
                }
            }
            Text {
                text: root.displayName
                color: config.text
                font.family: config.font
                font.pixelSize: 24 * root.s
                font.weight: Font.DemiBold
            }
            Text {
                visible: userModel.count > 1
                text: ""
                color: config.overlay1
                font.family: config.font
                font.pixelSize: 18 * root.s
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.userIndex = (root.userIndex + 1) % userModel.count
                }
            }
        }

        // Password pill
        Item {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            width: 340 * root.s
            height: 56 * root.s

            SequentialAnimation {
                id: shake
                loops: 2
                NumberAnimation { target: pill; property: "x"; to: 12; duration: 50 }
                NumberAnimation { target: pill; property: "x"; to: -12; duration: 80 }
                NumberAnimation { target: pill; property: "x"; to: 0; duration: 50 }
            }

            Rectangle {
                id: pill
                width: parent.width
                height: parent.height
                radius: height / 2
                color: Qt.alpha(config.surface0, 0.85)
                border.width: 3
                border.color: errorText.text !== "" ? config.red
                            : keyboard.capsLock ? config.peach
                            : password.activeFocus ? config.accent : config.surface2
                Behavior on border.color { ColorAnimation { duration: 150 } }

                TextField {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 56 * root.s
                    anchors.rightMargin: 56 * root.s
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    horizontalAlignment: TextInput.AlignHCenter
                    verticalAlignment: TextInput.AlignVCenter
                    color: config.text
                    selectionColor: config.accent
                    selectedTextColor: config.base
                    font.family: config.font
                    font.pixelSize: 18 * root.s
                    background: null
                    focus: true
                    onAccepted: root.login()
                    onTextEdited: errorText.text = ""
                    Keys.onEscapePressed: text = ""
                }
                // Own placeholder: Basic style hides a centered one while focused
                Text {
                    anchors.centerIn: password
                    visible: password.text === ""
                    text: keyboard.capsLock ? "Caps Lock is on" : "Password"
                    color: keyboard.capsLock ? config.peach : config.subtext0
                    font: password.font
                }

                // Submit arrow
                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 8 * root.s
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height - 16 * root.s
                    height: width
                    radius: width / 2
                    color: submit.containsMouse ? config.accent : Qt.alpha(config.accent, 0.8)
                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: config.base
                        font.family: config.font
                        font.pixelSize: 16 * root.s
                    }
                    MouseArea {
                        id: submit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.login()
                    }
                }
            }
        }

        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.red
            font.family: config.font
            font.pixelSize: 15 * root.s
            text: ""
            height: 18 * root.s
        }
    }

    // ---- Bottom bar ----
    component Chip: Rectangle {
        id: chip
        property string icon
        property string label
        property color tint: config.text
        signal clicked
        implicitWidth: chipRow.implicitWidth + 32 * root.s
        implicitHeight: 40 * root.s
        radius: height / 2
        color: area.containsMouse ? Qt.alpha(config.surface1, 0.9) : Qt.alpha(config.surface0, 0.7)
        Behavior on color { ColorAnimation { duration: 120 } }
        Row {
            id: chipRow
            anchors.centerIn: parent
            spacing: chip.label !== "" ? 10 * root.s : 0
            Text {
                text: chip.icon
                color: chip.tint
                font.family: config.font
                font.pixelSize: 17 * root.s
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: chip.label
                color: config.subtext1
                font.family: config.font
                font.pixelSize: 15 * root.s
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }

    Row {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 32 * root.s
        spacing: 12 * root.s

        Chip {
            icon: ""
            tint: config.accent
            label: root.currentSession ? root.currentSession.name : ""
            visible: sessions.count > 0
            onClicked: root.sessionIndex = (root.sessionIndex + 1) % sessions.count
        }
        Chip {
            icon: ""
            tint: config.blue
            label: keyboard.layouts.length > 0 ? keyboard.layouts[keyboard.currentLayout].shortName : ""
            visible: keyboard.layouts.length > 1
            onClicked: keyboard.currentLayout = (keyboard.currentLayout + 1) % keyboard.layouts.length
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 42 * root.s
        text: sddm.hostName
        color: config.overlay1
        font.family: config.font
        font.pixelSize: 15 * root.s
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 32 * root.s
        spacing: 12 * root.s

        Chip {
            icon: ""
            tint: config.blue
            visible: sddm.canSuspend
            onClicked: sddm.suspend()
        }
        Chip {
            icon: ""
            tint: config.yellow
            visible: sddm.canReboot
            onClicked: sddm.reboot()
        }
        Chip {
            icon: ""
            tint: config.red
            visible: sddm.canPowerOff
            onClicked: sddm.powerOff()
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}

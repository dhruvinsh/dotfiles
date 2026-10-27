import QtQuick

// A full-size cropped image revealed by `reveal` (0..1): mode 0 fades, 1-4 wipe
// in from the left/right/top/bottom. The image keeps its position while its clip
// rect grows, so a background and its cutout wiped together stay aligned.
Item {
    id: root

    property string path
    property real rev // bump to reload the same path (the query is ignored for files)
    property real reveal: 1
    property int mode: 0
    property real dpr: 1
    readonly property alias status: img.status

    anchors.fill: parent

    Item {
        id: clipper

        clip: root.mode !== 0
        x: root.mode === 2 ? root.width * (1 - root.reveal) : 0
        y: root.mode === 4 ? root.height * (1 - root.reveal) : 0
        width: root.mode === 1 || root.mode === 2 ? root.width * root.reveal : root.width
        height: root.mode === 3 || root.mode === 4 ? root.height * root.reveal : root.height

        Image {
            id: img

            x: -clipper.x
            y: -clipper.y
            width: root.width
            height: root.height
            opacity: root.mode === 0 ? root.reveal : 1
            source: root.path ? "file://" + root.path + (root.rev ? "?v=" + root.rev : "") : ""
            fillMode: Image.PreserveAspectCrop
            // decode once at output size; background and cutout share it, so they align
            sourceSize: Qt.size(root.width * root.dpr, root.height * root.dpr)
            asynchronous: true
            cache: false
            smooth: true
        }
    }
}

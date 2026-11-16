// Crimson Dusk splash screen (Plasma 6)
// Continues the login screen: same portrait, red embers and a thin red
// progress line that fills as Plasma starts.
import QtQuick

Rectangle {
    id: root
    color: "#050404"

    // Set by Plasma: goes from 1 to 6 while the desktop starts
    property int stage: 0

    readonly property real s: height / 1440
    readonly property color redHot:    "#ed4643"
    readonly property color textWhite: "#f2eeee"
    readonly property color textDim:   "#8f898b"
    property real breath: 0.5

    SequentialAnimation on breath {
        loops: Animation.Infinite
        NumberAnimation { to: 1.0;  duration: 1600; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0.35; duration: 1600; easing.type: Easing.InOutSine }
    }

    FontLoader { id: stm; source: "ShareTechMono.ttf" }
    readonly property string fam: stm.status === FontLoader.Ready ? stm.name : "monospace"

    // Portrait, fading in
    Image {
        id: bg
        anchors.fill: parent
        source: "images/bg.jpg"
        fillMode: Image.PreserveAspectCrop
        opacity: 0
        NumberAnimation on opacity { from: 0; to: 0.85; duration: 1200; easing.type: Easing.OutCubic }
    }

    // Darken the bottom so the text reads cleanly
    Rectangle {
        anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
        height: 420 * root.s
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "#f2000000" }
        }
    }

    // Red embers, rising to neck height
    Repeater {
        model: 12
        delegate: Item {
            id: em
            property real sx:  Math.random() * root.width * 0.9 + root.width * 0.05
            property real dr:  (Math.random() - 0.5) * 60 * root.s
            property real dur: 3500 + Math.random() * 3500
            property real sz:  (3 + Math.random() * 5) * root.s
            property real dl:  Math.random() * 3000
            readonly property color c: Math.random() < 0.6 ? root.redHot : "#b3261e"
            x: sx; y: root.height + 10; width: sz; height: sz; opacity: 0
            Rectangle { anchors.centerIn: parent; width: em.sz * 5; height: width; radius: width / 2; color: em.c; opacity: 0.12 }
            Rectangle { anchors.centerIn: parent; width: em.sz * 2.4; height: width; radius: width / 2; color: em.c; opacity: 0.28 }
            Rectangle { anchors.fill: parent; radius: width; color: em.c }
            SequentialAnimation {
                running: true; loops: Animation.Infinite
                PauseAnimation { duration: em.dl }
                ParallelAnimation {
                    NumberAnimation { target: em; property: "y"; from: root.height + 10; to: root.height * (0.55 + Math.random() * 0.15); duration: em.dur; easing.type: Easing.OutQuad }
                    NumberAnimation { target: em; property: "x"; from: em.sx; to: em.sx + em.dr; duration: em.dur; easing.type: Easing.InOutSine }
                    SequentialAnimation {
                        NumberAnimation { target: em; property: "opacity"; to: 0.8; duration: 600 }
                        PauseAnimation  { duration: em.dur - 1400 }
                        NumberAnimation { target: em; property: "opacity"; to: 0; duration: 800 }
                    }
                }
            }
        }
    }

    // Centre-bottom: diamond, label, progress line
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 150 * root.s
        spacing: 22 * root.s

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16 * root.s
            Rectangle {
                width: 10 * root.s; height: width; rotation: 45
                color: root.redHot
                opacity: 0.3 + 0.7 * root.breath
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: "WELCOME BACK"
                color: root.textWhite
                font.family: root.fam
                font.pixelSize: 26 * root.s
                font.letterSpacing: 10 * root.s
            }
            Rectangle {
                width: 10 * root.s; height: width; rotation: 45
                color: root.redHot
                opacity: 0.3 + 0.7 * root.breath
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 520 * root.s
            height: 3 * root.s
            Rectangle { anchors.fill: parent; color: Qt.rgba(1, 1, 1, 0.10) }
            Rectangle {
                id: bar
                height: parent.height
                width: parent.width * Math.min(1, Math.max(0, root.stage) / 6)
                color: root.redHot
                Behavior on width { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
            }
            // Soft glow under the bar
            Rectangle {
                anchors.verticalCenter: bar.verticalCenter
                width: bar.width; height: 14 * root.s; radius: height / 2
                color: root.redHot
                opacity: 0.10 + 0.15 * root.breath
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDate(new Date(), "ddd, MMM d").toUpperCase()
            color: root.textDim
            font.family: root.fam
            font.pixelSize: 16 * root.s
            font.letterSpacing: 6 * root.s
        }
    }

    // Fade the whole splash out at the end
    onStageChanged: if (stage >= 6) fadeOut.start()
    NumberAnimation { id: fadeOut; target: root; property: "opacity"; to: 0; duration: 500 }
}

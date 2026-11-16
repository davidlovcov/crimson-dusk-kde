// Crimson Dusk clock face: white time with a breathing red glow,
// pulsing red diamond and a dim, spaced-out date.
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: face
    implicitWidth: 480
    implicitHeight: 220

    readonly property color redHot:    "#ed4643"
    readonly property color textWhite: "#f2eeee"
    readonly property color textDim:   "#8f898b"
    // Size scales up with the widget, never below the original size
    readonly property real u: Math.max(1, height / 220)
    property real breath: 0.5

    SequentialAnimation on breath {
        loops: Animation.Infinite
        NumberAnimation { to: 1.0;  duration: 3800; easing.type: Easing.InOutSine }
        NumberAnimation { to: 0.35; duration: 3800; easing.type: Easing.InOutSine }
    }

    FontLoader { id: stm; source: Qt.resolvedUrl("../fonts/ShareTechMono.ttf") }
    readonly property string fam: stm.status === FontLoader.Ready ? stm.name : "monospace"

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6 * face.u

        Item {
            width: timeText.implicitWidth
            height: timeText.implicitHeight
            Text {
                id: timeText
                color: face.textWhite
                font.family: face.fam
                font.pixelSize: 132 * face.u
                font.letterSpacing: 2 * face.u
                text: Qt.formatTime(new Date(), "HH:mm")
            }
            MultiEffect {
                source: timeText
                anchors.fill: timeText
                shadowEnabled: true
                shadowColor: face.redHot
                shadowOpacity: 0.25 + 0.45 * face.breath
                shadowBlur: 1.0
                blurMax: 40
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
            }
        }

        Row {
            spacing: 12 * face.u
            leftPadding: 4 * face.u
            Rectangle {
                width: 8 * face.u; height: width; rotation: 45
                color: face.redHot
                opacity: 0.3 + 0.7 * face.breath
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: dateText
                color: face.textDim
                font.family: face.fam
                font.pixelSize: 20 * face.u
                font.letterSpacing: 6 * face.u
                text: Qt.formatDate(new Date(), "ddd, MMM d").toUpperCase()
            }
        }
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            var d = new Date()
            timeText.text = Qt.formatTime(d, "HH:mm")
            dateText.text = Qt.formatDate(d, "ddd, MMM d").toUpperCase()
        }
    }
}

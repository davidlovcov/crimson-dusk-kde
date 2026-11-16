import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    fullRepresentation: ClockFace {
        Layout.minimumWidth: 240
        Layout.minimumHeight: 110
        Layout.preferredWidth: 480
        Layout.preferredHeight: 220
    }
}

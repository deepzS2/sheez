import QtQuick
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root

    componentName: "AudioSource"
    widgetColor: AudioService.sourceMuted ? Colors.tertiary : Colors.surface
    borderColor: AudioService.sourceMuted ? Colors.tertiary : Colors.outlineVariant
    tooltipText: AudioService.sourceTooltip
    implicitWidth: sourceText.implicitWidth + Styles.widgetPadding * 2

    property real delta: 0

    Text {
        id: sourceText
        anchors.centerIn: parent
        text: AudioService.sourceIcon
        font: Styles.systemFont
        color: AudioService.sourceMuted ? Colors.surface : Colors.conSurface
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                AudioService.toggleSourceMute();
            } else if (mouse.button === Qt.RightButton) {
                AudioService.launchPavucontrol();
            }
        }

        onWheel: wheel => {
            if (wheel.angleDelta.y === 0)
                return;

            root.delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            adjustVolumeTimer.start();
        }
    }

    Timer {
        id: adjustVolumeTimer
        interval: 200
        onTriggered: () => {
            AudioService.adjustSourceVolume(root.delta);
        }
    }
}

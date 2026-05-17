import QtQuick
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root

    componentName: "AudioSink"
    widgetColor: AudioService.sinkMuted ? Colors.tertiary : Colors.surface
    borderColor: AudioService.sinkMuted ? Colors.tertiary : Colors.outlineVariant
    tooltipText: AudioService.sinkTooltip
    implicitWidth: sinkText.implicitWidth + Styles.widgetPadding * 2

    Text {
        id: sinkText
        anchors.centerIn: parent
        text: `${AudioService.sinkIcon}  ${Math.round(AudioService.sinkVolume * 100)}%`
        font: Styles.systemFont
        color: AudioService.sinkMuted ? Colors.surface : Colors.conSurface
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                AudioService.toggleSinkMute();
            } else if (mouse.button === Qt.RightButton) {
                AudioService.launchPavucontrol();
            }
        }

        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            AudioService.adjustSinkVolume(delta);
        }
    }
}

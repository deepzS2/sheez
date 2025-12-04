import QtQuick
import qs.commons
import qs.widgets
import qs.modules.bar.services

Rectangle {
    id: root

    implicitWidth: sinkText.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: AudioService.sinkMuted ? Colors.tertiary : Colors.surface
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
        color: AudioService.sinkMuted ? Colors.tertiary : Colors.outlineVariant
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: root
    }

    Text {
        id: sinkText
        anchors.centerIn: parent
        text: `${AudioService.sinkIcon}  ${Math.round(AudioService.sinkVolume * 100)}%`
        font: Styles.systemFont
        color: AudioService.sinkMuted ? Colors.surface : Colors.conSurface
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: TooltipService.show(AudioService.sinkTooltip, root)
        onExited: TooltipService.hide()

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

    // Initialize
    Component.onCompleted: {
        Logger.info("AudioSink", "Audio sink widget initialized");
    }
}

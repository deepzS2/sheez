import QtQuick
import qs.commons
import qs.widgets
import qs.modules.bar.services

Rectangle {
    id: root

    implicitWidth: sourceText.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: AudioService.sourceMuted ? Colors.tertiary : Colors.surface
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
        color: AudioService.sourceMuted ? Colors.tertiary : Colors.outlineVariant
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: root
    }

    Text {
        id: sourceText
        anchors.centerIn: parent
        text: AudioService.sourceIcon
        font: Styles.systemFont
        color: AudioService.sourceMuted ? Colors.surface : Colors.conSurface
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: TooltipService.show(AudioService.sourceTooltip, root)
        onExited: TooltipService.hide()

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                AudioService.toggleSourceMute();
            } else if (mouse.button === Qt.RightButton) {
                AudioService.launchPavucontrol();
            }
        }

        onWheel: wheel => {
            const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            AudioService.adjustSourceVolume(delta);
        }
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("AudioSource", "Audio source widget initialized");
    }
}

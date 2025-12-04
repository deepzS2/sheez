import QtQuick
import qs.commons
import qs.widgets
import qs.modules.bar.services

Rectangle {
    id: root

    implicitWidth: speedText.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: NetworkingService.isConnected ? Colors.surface : Colors.tertiary
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
        color: NetworkingService.isConnected ? Colors.outlineVariant : Colors.tertiary
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: root
    }

    Text {
        id: speedText
        anchors.centerIn: parent
        text: `${NetworkingService.bandwidthDownBits}  | ${NetworkingService.bandwidthUpBits} `
        font: Styles.systemFont
        color: NetworkingService.isConnected ? Colors.conSurface : Colors.surface
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onEntered: {
            const tooltip = !NetworkingService.isConnected
                ? "Not Connected to any type of Network"
                : NetworkingService.connectionType === "wifi"
                ? `${NetworkingService.essid} (${NetworkingService.signalStrength}%)   \n${NetworkingService.ipAddress}`
                : NetworkingService.connectionType === "ethernet"
                ? `${NetworkingService.interfaceName} 󰈀 \n${NetworkingService.ipAddress}`
                : NetworkingService.ipAddress;
            TooltipService.show(tooltip, root);
        }
        onExited: TooltipService.hide()
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("NetworkSpeed", "Network speed widget initialized");
    }
}
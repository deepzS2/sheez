import QtQuick
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root

    componentName: "NetworkSpeed"
    widgetColor: NetworkingService.isConnected ? Colors.surface : Colors.tertiary
    borderColor: NetworkingService.isConnected ? Colors.outlineVariant : Colors.tertiary
    implicitWidth: speedText.implicitWidth + Styles.widgetPadding * 2

    tooltipText: {
        if (!NetworkingService.isConnected)
            return "Not Connected";
        if (NetworkingService.connectionType === "wifi")
            return `${NetworkingService.essid} (${NetworkingService.signalStrength}%) \n${NetworkingService.ipAddress}`;
        if (NetworkingService.connectionType === "ethernet")
            return `${NetworkingService.interfaceName} 󰈀\n${NetworkingService.ipAddress}`;
        return NetworkingService.ipAddress;
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
    }
}

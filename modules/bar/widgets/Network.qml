import QtQuick
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root

    componentName: "Network"
    widgetColor: NetworkingService.isConnected ? Colors.surface : Colors.tertiary
    borderColor: NetworkingService.isConnected ? Colors.outlineVariant : Colors.tertiary
    implicitWidth: networkText.implicitWidth + Styles.widgetPadding * 2

    tooltipText: {
        if (!NetworkingService.isConnected)
            return "Disconnected";
        if (NetworkingService.connectionType === "wifi")
            return `${NetworkingService.essid} (${NetworkingService.signalStrength}%) \n${NetworkingService.ipAddress}`;
        if (NetworkingService.connectionType === "ethernet")
            return `${NetworkingService.interfaceName} 🖧\n${NetworkingService.ipAddress}`;
        return NetworkingService.ipAddress;
    }

    Text {
        id: networkText
        anchors.centerIn: parent
        text: NetworkingService.isConnected ? `${NetworkingService.networkIcon}  ${NetworkingService.bandwidthTotalBytes}/s` : "󱐅  Disc"
        font: Styles.systemFont
        color: NetworkingService.isConnected ? Colors.conSurface : Colors.surface
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                NetworkingService.launchWifiMenu();
            } else if (mouse.button === Qt.RightButton) {
                NetworkingService.launchNetworkManager();
            }
        }
    }
}

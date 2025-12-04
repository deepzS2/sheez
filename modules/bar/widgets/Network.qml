import QtQuick
import qs.commons
import qs.widgets
import qs.modules.bar.services

Rectangle {
    id: root

    implicitWidth: networkText.implicitWidth + Styles.widgetPadding * 2
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
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onEntered: {
            const tooltip = !NetworkingService.isConnected ? "Disconnected" : NetworkingService.connectionType === "wifi" ? `${NetworkingService.essid} (${NetworkingService.signalStrength}%)  \n${NetworkingService.ipAddress}` : NetworkingService.connectionType === "ethernet" ? `${NetworkingService.interfaceName} 🖧\n${NetworkingService.ipAddress}` : NetworkingService.ipAddress;
            TooltipService.show(tooltip, root);
        }
        onExited: TooltipService.hide()

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                NetworkingService.launchWifiMenu();
            } else if (mouse.button === Qt.RightButton) {
                NetworkingService.launchNetworkManager();
            }
        }
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("Network", "Network widget initialized");
    }
}

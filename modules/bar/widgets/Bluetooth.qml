import QtQuick
import qs.commons
import qs.widgets
import qs.modules.bar.services

Rectangle {
    id: root

    implicitWidth: bluetoothText.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: Colors.surface
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
        color: Colors.outlineVariant
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: root
    }

    Text {
        id: bluetoothText
        anchors.centerIn: parent
        text: BluetoothService.icon
        font: Styles.systemFont
        color: Colors.conSurface
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onEntered: TooltipService.show(BluetoothService.tooltip, root)
        onExited: TooltipService.hide()

        onClicked: BluetoothService.launchBluemanManager()
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("Bluetooth", "Bluetooth widget initialized");
    }
}

import QtQuick
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root

    componentName: "Bluetooth"
    tooltipText: BluetoothService.tooltip
    implicitWidth: bluetoothText.implicitWidth + Styles.widgetPadding * 2

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
        onClicked: BluetoothService.launchBluemanManager()
    }
}

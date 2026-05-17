import QtQuick
import qs.shared
import qs.modules.logoutmenu.services

Rectangle {
    id: root

    color: Qt.alpha(Colors.surfaceContainerLowest, 0.8)
    implicitWidth: uptimeText.implicitWidth + 120 * 2
    implicitHeight: uptimeText.implicitHeight + 15 * 2

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: 48

    Text {
        id: uptimeText

        anchors.centerIn: parent

        text: `Uptime: ${UptimeService.uptimeText}`
        color: Colors.conSurface

        font {
            family: Styles.systemFont.family
            pointSize: 24
            bold: true
        }
    }
}

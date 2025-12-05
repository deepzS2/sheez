import QtQuick
import qs.commons
import qs.modules.logoutmenu.services

Rectangle {
    id: root

    color: Qt.alpha(Colors.surfaceContainerLowest, 0.8)
    radius: 16

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
            family: "JetBrainsMono Nerd Font"
            pointSize: 24
            bold: true
        }
    }
}

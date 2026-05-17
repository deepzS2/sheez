import QtQuick
import qs.shared
import qs.modules.logoutmenu.services

Item {
    id: root

    implicitWidth: text.implicitWidth
    implicitHeight: text.implicitHeight
    anchors.horizontalCenter: parent.horizontalCenter

    Text {
        id: text
        text: `Goodbye ${UserService.username}`
        color: Colors.conSurface

        font {
            family: Styles.systemFont.family
            pointSize: 72
            bold: true
        }
    }
}

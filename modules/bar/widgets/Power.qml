import QtQuick
import qs.shared
import qs.components

BarWidget {
    id: root

    componentName: "Power"
    widgetColor: Colors.error
    borderColor: Colors.error
    implicitWidth: powerText.implicitWidth + Styles.widgetPadding * 2

    Text {
        id: powerText
        anchors.centerIn: parent
        text: "⏻"
        font {
            family: Styles.systemFont.family
            pixelSize: Styles.systemFont.pixelSize
            bold: false
        }
        color: Colors.conError
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            PanelService.toggleLogoutMenu();
        }
    }
}

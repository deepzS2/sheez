import QtQuick
import Quickshell
import qs.shared
import qs.components

BarWidget {
    id: root

    componentName: "Distro"
    implicitWidth: distroText.implicitWidth + Styles.widgetPadding * 2

    Text {
        id: distroText
        anchors.centerIn: parent
        text: ""
        font: Styles.systemFontBig
        color: Colors.primary
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["rofi", "-show", "drun", "-theme", "~/.config/rofi/launcher.rasi"]);
        }
    }
}

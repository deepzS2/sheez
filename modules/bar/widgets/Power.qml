import QtQuick
import Quickshell
import qs.commons
import qs.widgets

Rectangle {
    id: powerWidget

    implicitWidth: powerText.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
        color: Colors.error
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
    color: Colors.error
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: powerWidget
    }

    Text {
        id: powerText
        anchors.centerIn: parent
        text: ""
        font: Styles.systemFont
        color: Colors.conError
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached(["powermenu"]);
        }
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("Power", "Power widget initialized");
    }
}

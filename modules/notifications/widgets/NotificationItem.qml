pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import qs.shared

Rectangle {
    id: root

    required property var modelData

    opacity: 0
    Layout.fillWidth: true
    Layout.preferredHeight: layout.implicitHeight + 20
    color: Colors.background

    border {
        width: 2
        color: root.modelData.urgency === NotificationUrgency.Critical ? Colors.error : Colors.primary
    }

    NumberAnimation {
        id: fadeIn
        target: root
        property: "opacity"
        from: 0
        to: 1
        duration: 200
        running: true
        easing.type: Easing.OutCubic
    }

    function animateDismiss() {
        Logger.debug("NotificationItem", "Dismissing notification");
        fadeOut.start();
    }

    NumberAnimation {
        id: fadeOut
        target: root
        property: "opacity"
        from: 1
        to: 0
        duration: 200
        easing.type: Easing.InCubic
        onFinished: root.modelData.dismiss()
    }

    Timer {
        id: timer
        running: root.modelData.urgency !== NotificationUrgency.Critical
        interval: 5000
        onTriggered: root.animateDismiss()
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.animateDismiss()
        onEntered: timer.stop()
        onExited: timer.start()

        hoverEnabled: true
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Image {
            Layout.preferredHeight: 36
            Layout.preferredWidth: 36
            Layout.alignment: Qt.AlignTop
            fillMode: Image.PreserveAspectFit
            visible: source.toString() !== ""
            source: root.modelData.image || root.modelData.appIcon || ""
        }

        ColumnLayout {
            id: cardLayout
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.modelData.summary
                color: Colors.primary
                elide: Text.ElideRight

                font {
                    family: Styles.systemFont.family
                    pixelSize: 16
                    bold: true
                }
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.modelData.body
                color: Colors.conBackground
                wrapMode: Text.WordWrap

                font {
                    family: Styles.systemFont.family
                    pixelSize: 14
                }
            }
        }
    }
}

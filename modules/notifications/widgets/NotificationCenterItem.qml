pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import qs.shared

Rectangle {
    id: root

    required property var modelData
    required property int index
    signal removed(index: int)

    Layout.fillWidth: true
    Layout.alignment: Qt.AlignTop
    Layout.preferredHeight: cardLayout.implicitHeight + 20
    color: Colors.background

    border {
        width: 2
        color: root.modelData.urgency === NotificationUrgency.Critical ? Colors.error : Colors.outline
    }

    function animateRemove() {
        Logger.debugf("NotificationCenterItem", "Removing item at index {0}", root.index);
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
        onFinished: root.removed(root.index)
    }

    ColumnLayout {
        id: cardLayout
        Layout.fillWidth: true
        anchors.fill: parent
        anchors.margins: 10
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Text {
                Layout.fillWidth: true
                text: root.modelData.summary
                color: Colors.conBackground
                elide: Text.ElideRight

                font {
                    family: Styles.systemFont.family
                    pixelSize: 14
                    bold: true
                }
            }

            Text {
                text: root.modelData.time
                color: Colors.outline

                font {
                    family: Styles.systemFont.family
                    pixelSize: 12
                }
            }

            Text {
                text: ""
                color: Colors.outline

                font {
                    family: Styles.systemFont.family
                    pixelSize: 16
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.animateRemove()
                }
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

        Text {
            visible: root.modelData.appName !== ""
            text: root.modelData.appName
            color: Colors.outline

            font {
                family: Styles.systemFont.family
                pixelSize: 12
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.shared

PanelWindow {
    id: root

    required property var history
    signal clearHistory
    signal removeItem(index: int)

    anchors {
        top: true
        right: true
    }

    margins {
        top: Styles.barHeight + 8
        right: 12
    }

    visible: false
    implicitWidth: Styles.notificationCenterWidth
    implicitHeight: centerCol.implicitHeight + 24
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore

    Rectangle {
        color: Colors.background
        anchors.fill: parent

        border {
            width: 2
            color: Colors.primary
        }

        ColumnLayout {
            id: centerCol
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    font: Styles.systemFontBig
                    color: Colors.conBackground
                }

                Text {
                    text: "Clear all"
                    visible: root.history.length > 0
                    color: Colors.error

                    font {
                        family: Styles.systemFont.family
                        pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clearHistory()
                    }
                }
            }

            Rectangle {
                id: containerItems
                Layout.fillWidth: true
                color: Colors.surfaceDim
                implicitHeight: Styles.notificationCenterHeight

                border {
                    width: 2
                    color: Colors.outlineVariant
                }

                ScrollView {
                    implicitHeight: containerItems.implicitHeight

                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    anchors {
                        fill: parent
                        margins: 8
                    }

                    ColumnLayout {
                        visible: root.history.length > 0
                        spacing: 10

                        anchors {
                            left: parent.left
                            right: parent.right
                        }

                        Repeater {
                            model: root.history
                            delegate: NotificationCenterItem {
                                onRemoved: index => root.removeItem(index)
                            }
                        }
                    }
                }

                Text {
                    visible: root.history.length === 0
                    anchors.fill: parent

                    font: Styles.systemFont
                    color: Colors.conSurface
                    opacity: 0.7
                    text: "No notifications yet."

                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }

    Component.onCompleted: {
        Logger.debug("NotificationCenterPanel", "Panel initialized");
        PanelService.notificationPanelEl = this;
    }
}

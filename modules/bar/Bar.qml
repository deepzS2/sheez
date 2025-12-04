pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.commons
import qs.widgets
import "widgets"

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        // qmllint disable uncreatable-type
        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            color: "transparent"
            implicitHeight: Styles.barHeight

            anchors {
                top: true
                left: true
                right: true
            }

            Item {
                anchors.fill: parent
                clip: true

                // Left Section
                RowLayout {
                    id: leftSection
                    objectName: "leftSection"
                    anchors.left: parent.left
                    anchors.leftMargin: Styles.marginSize
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Styles.marginSize

                    Distro {}
                    Workspaces {}
                    Window {}
                }

                RowLayout {
                    id: rightSection
                    objectName: "rightSection"
                    anchors.right: parent.right
                    anchors.rightMargin: Styles.marginSize
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Styles.marginSize

                    Clock {}

                    SystemMonitor {}

                    Brightness {}

                    Drawer {
                        direction: Qt.RightToLeft

                        AudioSink {}
                        AudioSource {}
                        Bluetooth {}
                    }

                    Drawer {
                        direction: Qt.RightToLeft

                        Network {}
                        NetworkSpeed {}
                    }

                    Battery {}

                    Power {}
                }
            }
        }
    }
}

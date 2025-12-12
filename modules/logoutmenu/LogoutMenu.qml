pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.commons
import "widgets"

Variants {
    id: root

    property bool isVisible: false
    property color backgroundColor: Qt.alpha(Colors.background, 0.75)
    property color buttonColor: Qt.alpha(Colors.surfaceContainer, 0.8)
    property color buttonHoverColor: Colors.primaryFixed
    property color buttonTextColor: Colors.conSurface
    property color buttonHoverTextColor: Colors.conPrimaryFixed
    property var buttons: [
        {
            icon: "󰐥",
            text: "Shutdown",
            key: Qt.Key_P,
            command: "systemctl poweroff"
        },
        {
            icon: "",
            text: "Reboot",
            key: Qt.Key_R,
            command: "systemctl reboot"
        },
        {
            icon: "󰌾",
            text: "Lock",
            key: Qt.Key_L,
            command: "hyprlock"
        },
        {
            icon: "󰤄",
            text: "Suspend",
            key: Qt.Key_S,
            command: "systemctl suspend"
        },
        {
            icon: "󰍃",
            text: "Logout",
            key: Qt.Key_Q,
            command: "loginctl terminate-user $USER"
        }
    ]

    signal keyPressed(int key)

    Component.onCompleted: {
        PanelService.logoutMenuEl = this;
    }

    model: Quickshell.screens

    delegate: Loader {
        id: loader

        active: root.isVisible
        property var modelData

        // qmllint disable uncreatable-type
        sourceComponent: PanelWindow {
            id: logoutPanel

            visible: root.isVisible

            screen: loader.modelData

            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            color: "transparent"

            contentItem {
                focus: true
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Escape) {
                        root.isVisible = false;
                        return;
                    }

                    root.keyPressed(event.key);
                }
            }

            anchors {
                top: true
                left: true
                bottom: true
                right: true
            }

            Rectangle {
                color: root.backgroundColor
                anchors.fill: parent

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.isVisible = false

                    UpperText {
                        anchors.bottom: buttonsLayout.top
                    }

                    RowLayout {
                        id: buttonsLayout
                        anchors.centerIn: parent

                        width: parent.width * 0.75
                        height: parent.height * 0.25
                        spacing: 24

                        Repeater {
                            model: root.buttons

                            LogoutButton {
                                id: button

                                required property var modelData

                                Connections {
                                    target: root

                                    function onKeyPressed(key) {
                                        if (key == button.modelData.key) {
                                            button.exec();
                                        }
                                    }
                                }

                                command: modelData.command
                                textColor: ma.containsMouse ? root.buttonHoverTextColor : root.buttonTextColor
                                color: ma.containsMouse ? root.buttonHoverColor : root.buttonColor
                                text: modelData.text
                                icon: modelData.icon

                                MouseArea {
                                    id: ma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: button.exec()
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                    }

                    BottomText {
                        anchors.top: buttonsLayout.bottom
                    }
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.commons

Scope {
    id: root
    property bool failed
    property string errorString
    property bool isDebug: Boolean(Quickshell.env("SHEEZ_DEBUG"))

    Connections {
        target: Quickshell

        function onReloadCompleted() {
            Quickshell.inhibitReloadPopup();

            if (root.isDebug) {
                root.failed = false;
                popupLoader.loading = true;
            }
        }

        function onReloadFailed(error: string) {
            Quickshell.inhibitReloadPopup();

            if (root.isDebug) {
                // Close any existing popup before making a new one.
                popupLoader.active = false;

                root.failed = true;
                root.errorString = error;
                popupLoader.loading = true;
            }
        }
    }

    LazyLoader {
        id: popupLoader

        // qmllint disable uncreatable-type
        PanelWindow {
            id: popup

            anchors {
                top: true
                left: true
            }

            // qmllint disable unresolved-type unqualified missing-property
            margins {
                top: 25
                left: 25
            }

            width: rect.width
            height: rect.height

            // color blending is a bit odd as detailed in the type reference.
            color: "transparent"

            Rectangle {
                id: rect
                color: Qt.alpha(root.failed ? Colors.error : Colors.secondary, 0.4)

                implicitHeight: layout.implicitHeight + 50
                implicitWidth: layout.implicitWidth + 30

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    onClicked: popupLoader.active = false

                    hoverEnabled: true
                }

                ColumnLayout {
                    id: layout
                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: root.failed ? "Reload failed." : "Reloaded completed!"
                        color: root.failed ? Colors.conError : Colors.conSurfaceVariant
                    }

                    Text {
                        text: root.errorString
                        color: root.failed ? Colors.conError : Colors.conSurfaceVariant
                        // When visible is false, it also takes up no space.
                        visible: root.errorString != ""
                    }
                }

                Rectangle {
                    id: bar
                    color: Colors.primary
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    height: 20

                    PropertyAnimation {
                        id: anim
                        target: bar
                        property: "width"
                        from: rect.width
                        to: 0
                        duration: root.failed ? 10000 : 800
                        onFinished: popupLoader.active = false

                        // Pause the animation when the mouse is hovering over the popup,
                        // so it stays onscreen while reading. This updates reactively
                        // when the mouse moves on and off the popup.
                        paused: mouseArea.containsMouse
                    }
                }

                // We could set `running: true` inside the animation, but the width of the
                // rectangle might not be calculated yet, due to the layout.
                // In the `Component.onCompleted` event handler, all of the component's
                // properties and children have been initialized.
                Component.onCompleted: anim.start()
            }
        }
    }
}

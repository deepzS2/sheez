pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.commons
import qs.widgets
import qs.modules.bar.services

Rectangle {
    id: root

    // Layout properties
    implicitWidth: workspacesRow.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: Colors.surface
    opacity: Styles.widgetOpacity

    // Border styling
    border {
        width: Styles.widgetBorderWidth
        color: Colors.outlineVariant
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: root
    }

    Connections {
        target: CompositorService

        function onWorkspacesUpdated(workspaces) {
            root.updateWorkspacesModel(workspaces);
        }

        function onError(message, error) {
            Logger.errorf("Workspaces", `Compositor error: {0}\n{1}`, message, error);
        }
    }

    // Workspace data model
    property ListModel workspaces: ListModel {}
    property var workspaceIcons: ({
            "code": "",
            "browser": "",
            "chat": "",
            "default": ""
        })

    RowLayout {
        id: workspacesRow
        anchors.centerIn: parent
        spacing: Styles.widgetSpacing

        Repeater {
            model: root.workspaces

            Rectangle {
                id: workspaceButton
                required property var modelData
                property bool isActive: modelData.isActive

                width: workspaceText.implicitWidth + 4
                height: Styles.widgetHeight
                radius: 4
                color: "transparent"

                // Smooth transition
                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }
                }

                Text {
                    id: workspaceText
                    anchors.centerIn: parent
                    text: root.workspaceIcons[parent.modelData.name] || root.workspaceIcons["default"]
                    font: Styles.systemFont
                    color: workspaceButton.isActive ? Colors.conSurfaceVariant : Qt.rgba(Colors.conSurface.r, Colors.conSurface.g, Colors.conSurface.b, 0.3)

                    // Smooth transition
                    Behavior on color {
                        ColorAnimation {
                            duration: 300
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        if (!workspaceButton.isActive) {
                            workspaceText.color = Colors.conSurfaceVariant;
                        }
                    }
                    onExited: {
                        if (!workspaceButton.isActive) {
                            workspaceText.color = Qt.rgba(Colors.conSurface.r, Colors.conSurface.g, Colors.conSurface.b, 0.3);
                        }
                    }
                    onClicked: {
                        Logger.infof("Workspaces", `Switching to workspace {0}`, workspaceButton.modelData.id);
                        CompositorService.switchToWorkspace(workspaceButton.modelData.id);
                    }
                }
            }
        }
    }

    // Component lifecycle
    Component.onCompleted: {
        Logger.info("Workspaces", "Initializing workspace widget");
        CompositorService.activate();
    }

    // Update workspaces model from service data
    function updateWorkspacesModel(serviceWorkspaces) {
        try {
            workspaces.clear();

            for (let i = 0; i < serviceWorkspaces.count; i++) {
                const item = serviceWorkspaces.get(i);
                workspaces.append(item);
            }
        } catch (e) {
            Logger.errorf("Workspaces", `Failed to update workspace model: {0}`, e);
        }
    }
}

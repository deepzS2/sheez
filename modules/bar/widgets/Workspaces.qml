pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root

    componentName: "Workspaces"
    widgetColor: Colors.surfaceContainerLow
    // borderColor: Colors.outline
    implicitWidth: workspacesRow.implicitWidth + Styles.widgetPadding * 2

    // Workspace data model
    property ListModel workspaces: ListModel {}
    property var workspaceIcons: ({
            "code": "",
            "browser": "",
            "chat": "",
            "stash": "",
            "scratchpad": "",
            "default": ""
        })

    Connections {
        target: CompositorService

        function onWorkspacesUpdated(workspaces) {
            root.updateWorkspacesModel(workspaces);
        }

        function onError(message, error) {
            Logger.errorf("Workspaces", `Compositor error: {0}\n{1}`, message, error);
        }
    }

    RowLayout {
        id: workspacesRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.workspaces

            Rectangle {
                id: workspaceButton
                required property var modelData
                property bool isActive: modelData.isActive

                width: workspaceText.implicitWidth + 4
                height: Styles.widgetHeight
                color: "transparent"

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
                        CompositorService.switchToWorkspace(workspaceButton.modelData.id);
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        CompositorService.activate();
    }

    function updateWorkspacesModel(serviceWorkspaces) {
        try {
            workspaces.clear();
            for (let i = 0; i < serviceWorkspaces.count; i++) {
                workspaces.append(serviceWorkspaces.get(i));
            }
        } catch (e) {
            Logger.errorf("Workspaces", `Failed to update workspace model: {0}`, e);
        }
    }
}

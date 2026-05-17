pragma ComponentBehavior: Bound
import QtQuick
import qs.shared

// Base widget component for bar items.
// Provides styled Rectangle, border, opacity, capsule height,
// optional lifecycle logging, and optional inline tooltip.
Rectangle {
    id: root

    // Use data instead of children to accept non-Item types (Connections, Timer, etc.)
    default property alias content: contentItem.data
    property string componentName: ""
    property string tooltipText: ""
    property color widgetColor: Colors.surface
    property color borderColor: Colors.outlineVariant

    implicitHeight: Styles.capsuleHeight
    color: root.widgetColor
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
        color: root.borderColor
    }

    // Container for default content. Anchors fill the full rectangle.
    Item {
        id: contentItem
        anchors.fill: parent
    }

    // Tooltip — created via Loader when tooltipText is set
    Loader {
        id: tooltipLoader
        active: root.tooltipText !== ""
        asynchronous: true

        sourceComponent: Tooltip {
            id: tooltipInstance
            target: root
            text: root.tooltipText
            position: "bottom-center"
        }
    }

    // Manage tooltip show/hide on hover
    // Uses HoverHandler instead of MouseArea to avoid conflicts with child MouseAreas
    HoverHandler {
        onHoveredChanged: {
            if (!root.tooltipText || !tooltipLoader.item)
                return;

            if (hovered)
                tooltipLoader.item.show();
            else
                tooltipLoader.item.hide();
        }
    }

    // Lifecycle logging
    Component.onCompleted: {
        if (root.componentName) {
            Logger.info(root.componentName, `${root.componentName} ready`);
        }
    }
}

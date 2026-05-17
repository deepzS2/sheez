pragma ComponentBehavior: Bound
import QtQuick
import qs.shared

Rectangle {
    id: root

    default property alias content: contentItem.data
    property string componentName: ""
    property string tooltipText: ""
    property color widgetColor: Colors.surfaceContainerLow
    property color borderColor: Colors.outlineVariant

    implicitHeight: Styles.capsuleHeight
    color: root.widgetColor
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
        color: root.borderColor
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }

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

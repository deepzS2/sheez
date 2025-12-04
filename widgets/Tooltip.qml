pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import qs.commons

PopupWindow {
    id: root

    property string text: ""
    property var targetItem: null
    property real maxWidth: 1000
    property real offsetX: 0
    property real offsetY: 0
    property string alignment: "center"
    property string vertical: "auto"
    property real customMaxWidth: 300
    property real additionalOffsetX: 0
    property real additionalOffsetY: 0
    property bool forcePosition: false
    visible: false
    color: "transparent"

    anchor {
        item: targetItem
        rect.x: root.offsetX
        rect.y: root.offsetY
    }

    Item {
        id: tooltipContainer
        anchors.fill: parent

        // Animation properties
        opacity: 1.0
        scale: 1.0
        transformOrigin: Item.Center

        Rectangle {
            id: tooltipRect
            color: Colors.surface
            border.color: Colors.outlineVariant
            border.width: Styles.widgetBorderWidth
            radius: Styles.widgetRadius
            anchors.fill: parent
            opacity: 0.0
            scale: 0.8
            transformOrigin: Item.Center

            visible: root.text !== ""

            Text {
                id: tooltipText
                anchors.centerIn: parent
                text: root.text
                font: Styles.systemFont
                color: Colors.conSurface
                wrapMode: Text.Wrap
                horizontalAlignment: root.alignment === "left" ? Text.AlignLeft : root.alignment === "right" ? Text.AlignRight : Text.AlignHCenter
                verticalAlignment: root.vertical === "top" ? Text.AlignTop : root.vertical === "bottom" ? Text.AlignBottom : Text.AlignVCenter
            }
        }
    }

    ParallelAnimation {
        id: showAnimation

        NumberAnimation {
            target: tooltipRect
            property: "opacity"
            to: Styles.widgetOpacity
            duration: 200
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: tooltipRect
            property: "scale"
            to: 1.0
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    ParallelAnimation {
        id: hideAnimation
        onFinished: root.visible = false

        NumberAnimation {
            target: tooltipRect
            property: "opacity"
            to: 0.0
            duration: 200
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: tooltipRect
            property: "scale"
            to: 0.8
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    function showTooltip(text, targetItem) {
        Logger.debugf("Tooltip", "Showing tooltip for \"{0}\"", targetItem);
        root.text = text;
        root.targetItem = targetItem;
        root.visible = true;
        calculatePosition();
        hideAnimation.stop();
        showAnimation.start();
    }

    function hideTooltip() {
        Logger.debugf("Tooltip", "Hiding tooltip for \"{0}\"", targetItem);
        showAnimation.stop();
        hideAnimation.start();
    }

    function calculatePosition() {
        if (!targetItem) {
            Logger.warn("Tooltip", "No target item for tooltip positioning");
            return;
        }

        // Calculate tooltip dimensions based on current text
        const textWidth = tooltipText.implicitWidth;
        const textHeight = tooltipText.implicitHeight;
        const tipWidth = Math.min(textWidth + Styles.widgetPadding * 2, root.customMaxWidth);
        const tipHeight = textHeight + Styles.widgetPadding * 2;

        // Set root dimensions
        root.implicitWidth = tipWidth;
        root.implicitHeight = tipHeight;

        // Set text width for wrapping
        tooltipText.width = tipWidth - Styles.widgetPadding * 2;

        const targetWidth = targetItem.width;
        const targetHeight = targetItem.height;
        const tooltipWidth = tipWidth;
        const tooltipHeight = tipHeight;

        // Get target global position
        const globalPos = targetItem.mapToGlobal(0, 0);

        // Find the screen containing the target
        const targetScreen = Quickshell.screens.find(screen => globalPos.x >= screen.x && globalPos.x < screen.x + screen.width && globalPos.y >= screen.y && globalPos.y < screen.y + screen.height) || Quickshell.screens[0]; // Fallback to primary screen

        if (!targetScreen) {
            Logger.errorf("Tooltip", "No screen found for tooltip positioning for item \"{0}\"", targetItem);
            return;
        }

        Logger.debugf("Tooltip", "Positioning tooltip on screen {0}", targetScreen.name || "Unknown");

        // Prefer above target, centered
        let offsetX = (targetWidth - tooltipWidth) / 2;
        let offsetY = -tooltipHeight - Styles.marginSize;

        // Check if fits above (relative to screen)
        if (globalPos.y + offsetY < targetScreen.y) {
            // Try below
            offsetY = targetHeight + Styles.marginSize;
            if (globalPos.y + targetHeight + offsetY + tooltipHeight > targetScreen.y + targetScreen.height) {
                // Try left
                offsetY = (targetHeight - tooltipHeight) / 2;
                offsetX = -tooltipWidth - Styles.marginSize;
                if (globalPos.x + offsetX < targetScreen.x) {
                    // Try right
                    offsetX = targetWidth + Styles.marginSize;
                }
            }
        }

        // Apply additional offsets
        offsetX += root.additionalOffsetX;
        offsetY += root.additionalOffsetY;

        // Apply screen boundary adjustments (unless forced)
        if (!root.forcePosition) {
            const absX = globalPos.x + offsetX;
            const absY = globalPos.y + offsetY;

            const screenLeft = targetScreen.x;
            const screenTop = targetScreen.y;
            const screenRight = targetScreen.x + targetScreen.width;
            const screenBottom = targetScreen.y + targetScreen.height;

            offsetX += Math.max(0, screenLeft - absX) + Math.min(0, screenRight - (absX + tooltipWidth));
            offsetY += Math.max(0, screenTop - absY) + Math.min(0, screenBottom - (absY + tooltipHeight));
        }

        root.offsetX = offsetX;
        root.offsetY = offsetY;

        Logger.debugf("Tooltip", "Tooltip positioned at offset ({0}, {1})", offsetX, offsetY);
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import qs.shared

PopupWindow {
    id: root

    enum TooltipPosition {
        TopLeft,
        TopCenter,
        TopRight,
        BottomLeft,
        BottomCenter,
        BottomRight
    }

    property string text: ""
    property var target: null
    property real maxWidth: 300
    property real padding: 8
    required property string position // <top | bottom>-<left | center | right>

    visible: false
    color: "transparent"

    anchor {
        item: root.target

        edges: {
            const [vertical, horizontal] = root.position.split("-");

            const verticalEdge = vertical === "bottom" ? Edges.Bottom : Edges.Top;
            const horizontalEdge = horizontal === "right" ? Edges.Right : Edges.Left;

            return verticalEdge | horizontalEdge;
        }

        // Calculate size and adjust rect before anchoring.
        // Centered horizontally over target with 6px gap above.
        onAnchoring: {
            if (!root.target)
                return;

            const textW = label.implicitWidth;
            const textH = label.implicitHeight;
            const tipW = Math.min(textW + root.padding * 2, root.maxWidth);
            const tipH = textH + root.padding * 2;

            root.implicitWidth = tipW;
            root.implicitHeight = tipH;
            label.width = tipW - root.padding * 2;

            const GAP = 6;

            const [vertical, horizontal] = root.position.split("-");

            if (vertical === "top")
                anchor.margins.top = -(tipH + GAP);
            else
                anchor.margins.top = root.target.height + GAP;

            if (horizontal === "center")
                anchor.margins.left = Math.round((root.target.width - tipW) / 2);
        }
    }

    // Background pill
    Rectangle {
        id: bg
        anchors.fill: parent
        color: Colors.surfaceContainerHigh
        border {
            color: Colors.outlineVariant
            width: Styles.widgetBorderWidth
        }
        opacity: 0.0

        Text {
            id: label
            anchors {
                margins: root.padding
                centerIn: parent
            }
            text: root.text
            font: Styles.systemFont
            color: Colors.conSurface
            wrapMode: Text.Wrap
            width: Math.min(implicitWidth, root.maxWidth - root.padding * 2)
        }
    }

    NumberAnimation {
        id: fadeIn
        target: bg
        property: "opacity"
        from: 0.0
        to: 1.0
        duration: 150
        easing.type: Easing.OutCubic
    }

    NumberAnimation {
        id: fadeOut
        target: bg
        property: "opacity"
        from: 1.0
        to: 0.0
        duration: 150
        easing.type: Easing.OutCubic
        onFinished: root.visible = false
    }

    function show() {
        if (!root.target)
            return;

        root.visible = true;
        fadeIn.start();
    }

    function hide() {
        fadeOut.start();
    }
}

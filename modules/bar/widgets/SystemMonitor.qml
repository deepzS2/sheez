import QtQuick
import qs.commons
import qs.widgets
import qs.modules.bar.services

Rectangle {
    id: root

    implicitWidth: systemText.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: Colors.surface
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
        color: Colors.outlineVariant
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: root
    }

    // System data properties bound to service
    readonly property real cpuUsage: SystemMonitorService.cpuUsage
    readonly property real memoryUsage: SystemMonitorService.memoryUsage
    property string tooltipText: ""
    property string popupText: ""

    // Color properties based on usage (computed)
    readonly property color cpuColor: {
        if (cpuUsage >= 90)
            return Colors.error;
        if (cpuUsage >= 80)
            return Colors.tertiary;
        return Colors.conSurface;
    }

    readonly property color memoryColor: {
        if (memoryUsage >= 90)
            return Colors.error;
        if (memoryUsage >= 80)
            return Colors.tertiary;
        return Colors.conSurface;
    }

    Text {
        id: systemText
        anchors.centerIn: parent
        text: root.formatDisplayText()
        font: Styles.systemFont
        color: Colors.conSurface
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            root.updateTooltipText();
            TooltipService.show(root.tooltipText, root);
        }
        onExited: TooltipService.hide()
    }

    // TODO: Use better formatting later
    function formatDisplayText() {
        const cpuText = `<font color="${cpuColor}"> ${cpuUsage.toFixed(0)}%</font>`;
        const memoryText = `<font color="${memoryColor}"> ${memoryUsage.toFixed(0)}%</font>`;

        return `${cpuText} ${memoryText}`;
    }

    function updateTooltipText() {
        tooltipText = `CPU: ${cpuUsage.toFixed(1)}% | Memory: ${memoryUsage.toFixed(1)}%`;
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("SystemMonitor", "System monitor widget initialized");
    }
}

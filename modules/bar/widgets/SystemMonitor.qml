import QtQuick
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root

    componentName: "SystemMonitor"
    implicitWidth: systemText.implicitWidth + Styles.widgetPadding * 2

    // System data properties bound to service
    readonly property real cpuUsage: SystemMonitorService.cpuUsage
    readonly property real memoryUsage: SystemMonitorService.memoryUsage

    // Tooltip updates reactively
    tooltipText: `CPU: ${root.cpuUsage.toFixed(1)}% | Memory: ${root.memoryUsage.toFixed(1)}%`

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

    // TODO: Use better formatting later
    function formatDisplayText() {
        const cpuT = root.cpuUsage.toFixed(0);
        const memT = root.memoryUsage.toFixed(0);
        return `<font color="${cpuColor}"> ${cpuT}%</font> | <font color="${memoryColor}"> ${memT}%</font>`;
    }
}

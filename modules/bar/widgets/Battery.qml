import QtQuick
import Quickshell.Services.UPower
import qs.shared
import qs.components

BarWidget {
    id: root

    componentName: "Battery"

    // Conditional colors
    widgetColor: root.isCharging ? Colors.secondary : Colors.surfaceContainerLow
    borderColor: root.isCharging ? Colors.secondary : Colors.outlineVariant
    implicitWidth: batteryText.implicitWidth + Styles.widgetPadding * 2

    // Battery device
    readonly property var battery: UPower.displayDevice
    readonly property var percentage: Math.round(battery.percentage * 100)
    readonly property var isCharging: battery.state === UPowerDeviceState.Charging
    readonly property bool isCritical: percentage <= 20 && battery.state === UPowerDeviceState.Discharging

    // Icon array for battery levels (0-10%, 10-20%, ..., 90-100%)
    readonly property var batteryIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    // Computed properties
    readonly property string icon: {
        if (isCharging)
            return "󰂅";
        if (battery.state === UPowerDeviceState.FullyCharged)
            return "";
        return batteryIcons[Math.min(10, Math.floor(percentage / 10))];
    }

    readonly property color textColor: {
        if (isCharging)
            return Colors.conSecondary;
        if (percentage > 30)
            return Colors.conSurface;
        return percentage <= 20 ? Colors.error : Colors.tertiary;
    }

    // Tooltip text
    tooltipText: {
        if (battery.state === UPowerDeviceState.FullyCharged)
            return "Fully charged";
        if (isCharging) {
            const h = Math.floor(battery.timeToFull / 3600);
            const m = Math.floor((battery.timeToFull % 3600) / 60);
            return `Charging: ${h}h ${m}m remaining`;
        }
        const h = Math.floor(battery.timeToEmpty / 3600);
        const m = Math.floor((battery.timeToEmpty % 3600) / 60);
        return `Discharging: ${h}h ${m}m remaining`;
    }

    Text {
        id: batteryText
        anchors.centerIn: parent
        text: `${root.icon} ${root.percentage}%`
        font: Styles.systemFont
        color: root.textColor
    }

    // Blinking animation for critical battery
    SequentialAnimation {
        id: blinkAnimation
        running: root.isCritical
        loops: Animation.Infinite
        NumberAnimation {
            target: batteryText
            property: "opacity"
            from: 1.0
            to: 0.3
            duration: 500
        }
        NumberAnimation {
            target: batteryText
            property: "opacity"
            from: 0.3
            to: 1.0
            duration: 500
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
    }
}

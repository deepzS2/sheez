import QtQuick
import Quickshell.Services.UPower
import qs.commons
import qs.widgets

Rectangle {
    id: root

    implicitWidth: batteryText.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: isCharging ? Colors.secondary : Colors.surface
    opacity: Styles.widgetOpacity

    border {
        width: Styles.widgetBorderWidth
        color: isCharging ? Colors.secondary : Colors.outlineVariant
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: root
    }

    // Battery device
    readonly property var battery: UPower.displayDevice
    readonly property var percentage: Math.round(battery.percentage * 100)
    readonly property var isCharging: battery.state === UPowerDeviceState.Charging
    readonly property bool isCritical: percentage <= 20 && battery.state === UPowerDeviceState.Discharging

    // Icon array for battery levels (0-10%, 10-20%, ..., 90-100%)
    readonly property var batteryIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    // Computed properties
    readonly property string icon: {
        if (isCharging) {
            return "󰂅";
        } else if (battery.state === UPowerDeviceState.FullyCharged) {
            return "";
        } else {
            const index = Math.min(10, Math.floor(percentage / 10));
            return batteryIcons[index];
        }
    }

    readonly property color textColor: {
        if (isCharging)
            return Colors.conSecondary;

        // Normal
        if (percentage > 30)
            return Colors.conSurface;

        // Error and Warning
        return percentage <= 20 ? Colors.error : Colors.tertiary;
    }

    // Tooltip text
    readonly property string tooltipText: {
        if (battery.state === UPowerDeviceState.FullyCharged) {
            return "Fully charged";
        } else if (isCharging) {
            const hours = Math.floor(battery.timeToFull / 3600);
            const minutes = Math.floor((battery.timeToFull % 3600) / 60);
            return `Charging: ${hours}h ${minutes}m remaining`;
        } else {
            const hours = Math.floor(battery.timeToEmpty / 3600);
            const minutes = Math.floor((battery.timeToEmpty % 3600) / 60);
            return `Discharging: ${hours}h ${minutes}m remaining`;
        }
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
        hoverEnabled: true
        onEntered: TooltipService.show(root.tooltipText, root)
        onExited: TooltipService.hide()
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("Battery", "Battery widget initialized");
    }
}

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    // Font settings
    readonly property font systemFont: ({
            family: "JetBrainsMono Nerd Font",
            pixelSize: 14,
            bold: true
        })
    readonly property font systemFontBig: ({
            family: "JetBrainsMono Nerd Font",
            pixelSize: 19,
            bold: true
        })

    // Layout constants
    readonly property int barHeight: 50
    readonly property real capsuleHeight: Math.round(barHeight * 0.82)
    readonly property int widgetHeight: 32
    readonly property int widgetRadius: 8
    readonly property int widgetSpacing: 4
    readonly property int widgetPadding: 12
    readonly property int marginSize: 8

    // Update intervals (milliseconds)
    readonly property int clockInterval: 1000
    readonly property int systemInterval: 30000
    readonly property int networkInterval: 5000
    readonly property int batteryInterval: 1000

    // Widget styling
    readonly property real widgetOpacity: 0.95
    readonly property int widgetBorderWidth: 1
    readonly property int widgetShadowOffset: 1
    readonly property real widgetShadowOpacity: 0.185
}

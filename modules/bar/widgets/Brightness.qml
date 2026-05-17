import QtQuick
import Quickshell
import Quickshell.Io
import qs.shared
import qs.components

BarWidget {
    id: root

    componentName: "Brightness"
    tooltipText: root.tooltipText
    implicitWidth: brightnessText.implicitWidth + Styles.widgetPadding * 2

    // Brightness properties
    property int currentBrightness: 0
    property int maxBrightness: 100
    property int targetBrightness: 0
    property string displayText: ""
    property string tipText: ""
    readonly property var icons: ["󱃓", "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥", "󰖨"]

    property string backlightDevice: ""
    readonly property string brightnessFilePath: backlightDevice ? `/sys/class/backlight/${backlightDevice}/brightness` : ""
    readonly property string maxBrightnessFilePath: backlightDevice ? `/sys/class/backlight/${backlightDevice}/max_brightness` : ""

    Text {
        id: brightnessText
        anchors.centerIn: parent
        text: root.displayText
        font: Styles.systemFont
        color: Colors.conSurface
    }

    Timer {
        id: applyBrightnessTimer
        interval: 100
        onTriggered: () => root.applyBrightnessChange()
    }

    // Device detection
    Process {
        id: detectDeviceProcess
        command: ["ls", "/sys/class/backlight/"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const devices = this.text.trim().split('\n').filter(d => d.length > 0);
                if (devices.length > 0) {
                    root.backlightDevice = devices[0];
                }
            }
        }
    }

    // Max brightness file monitor
    FileView {
        id: maxBrightnessFile
        path: root.maxBrightnessFilePath
        watchChanges: path.length > 0
        preload: true
        blockLoading: true
    }

    // Current brightness file monitor
    FileView {
        id: brightnessFile
        path: root.brightnessFilePath
        watchChanges: path.length > 0
        onLoaded: () => root.updateBrightness()
        onFileChanged: () => root.updateBrightness()
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onWheel: wheel => root.handleWheelEvent(wheel)
    }

    function updateBrightness() {
        brightnessFile.reload();

        root.currentBrightness = parseInt(brightnessFile.text().trim()) || 0;
        root.maxBrightness = parseInt(maxBrightnessFile.text().trim()) || 100;
        updateDisplay(root.currentBrightness, root.maxBrightness);
    }

    function updateDisplay(current, max) {
        const percentage = Math.round((current / max) * 100);
        const iconIndex = Math.min(9, Math.floor(percentage / 10));
        root.displayText = `${root.icons[iconIndex]} ${percentage}%`;
        root.tipText = `Brightness: ${current}/${max} (${percentage}%)`;
    }

    function handleWheelEvent(wheel) {
        if (wheel.angleDelta.y === 0)
            return;

        const percentage = 0.02;
        const delta = wheel.angleDelta.y > 0 ? percentage : -percentage;
        root.targetBrightness = root.currentBrightness + root.maxBrightness * delta;
        applyBrightnessTimer.start();
    }

    function applyBrightnessChange() {
        const clamped = Math.max(0, Math.min(root.maxBrightness, root.targetBrightness));
        root.targetBrightness = clamped;
        Quickshell.execDetached(["brightnessctl", "set", clamped.toString()]);
    }
}

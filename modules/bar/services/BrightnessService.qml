pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int currentBrightness: 0
    property int maxBrightness: 100

    property string backlightDevice: ""
    readonly property string brightnessFilePath: backlightDevice ? `/sys/class/backlight/${backlightDevice}/brightness` : ""
    readonly property string maxBrightnessFilePath: backlightDevice ? `/sys/class/backlight/${backlightDevice}/max_brightness` : ""

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

    FileView {
        id: maxBrightnessFile
        path: root.maxBrightnessFilePath
        watchChanges: path.length > 0
        preload: true
        blockLoading: true
    }

    FileView {
        id: brightnessFile
        path: root.brightnessFilePath
        watchChanges: path.length > 0
        onLoaded: () => root.updateBrightness()
        onFileChanged: () => root.updateBrightness()
    }

    function updateBrightness() {
        brightnessFile.reload();

        root.currentBrightness = parseInt(brightnessFile.text().trim()) || 0;
        root.maxBrightness = parseInt(maxBrightnessFile.text().trim()) || 100;
    }

    function adjustBrightness(percentage: real) {
        const targetBrightness = root.currentBrightness + root.maxBrightness * percentage;

        const clamped = Math.max(0, Math.min(root.maxBrightness, targetBrightness));
        Quickshell.execDetached(["brightnessctl", "set", clamped.toString()]);
    }
}

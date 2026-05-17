import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.bar.services
import qs.shared
import qs.components

BarWidget {
    id: root

    componentName: "Brightness"
    implicitWidth: brightnessText.implicitWidth + Styles.widgetPadding * 2

    // Brightness properties
    property real delta: 0
    readonly property var icons: ["󱃓", "󰪞", "󰪟", "󰪠", "󰪡", "󰪢", "󰪣", "󰪤", "󰪥", "󰖨"]

    Text {
        id: brightnessText
        anchors.centerIn: parent
        font: Styles.systemFont
        color: Colors.conSurface

        text: {
            const percentage = Math.round((BrightnessService.currentBrightness / BrightnessService.maxBrightness) * 100);
            const iconIndex = Math.min(9, Math.floor(percentage / 10));

            return `${root.icons[iconIndex]} ${percentage}%`;
        }
    }

    Timer {
        id: adjustBrightnessTimer
        interval: 100
        onTriggered: () => BrightnessService.adjustBrightness(root.delta)
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onWheel: wheel => {
            if (wheel.angleDelta.y === 0)
                return;

            const percentage = 0.02;
            root.delta = wheel.angleDelta.y > 0 ? percentage : -percentage;

            adjustBrightnessTimer.start();
        }
    }
}

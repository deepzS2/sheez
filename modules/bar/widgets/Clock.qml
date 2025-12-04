import QtQuick
import Quickshell
import Quickshell.Io
import qs.commons
import qs.widgets

Rectangle {
    id: clockWidget

    implicitWidth: clockText.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: Colors.surface
    opacity: Styles.widgetOpacity
    property string tooltipText: ""

    border {
        width: Styles.widgetBorderWidth
        color: Colors.outlineVariant
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: clockWidget
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: " " + Qt.formatTime(clock.date, "HH:mm")

        font: Styles.systemFont
        color: Colors.conSurface
    }

    Process {
        id: calProcess
        running: true
        command: ["sh", "-c", "cal"]
        stdout: StdioCollector {
            onStreamFinished: clockWidget.tooltipText = this.text
        }
    }

    // signal showTooltip(string text, int x, int y)
    // signal hideTooltip

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
            TooltipService.show(clockWidget.tooltipText, clockWidget, {
                alignment: "left"
            });
        }
        onExited: {
            TooltipService.hide();
        }
        onClicked: {
            // Show calendar tooltip or toggle format
            if (clockText.text.includes(":")) {
                clockText.text = " " + Qt.formatDate(new Date(), "dddd, MMMM d");
            } else {
                clockText.text = " " + Qt.formatTime(new Date(), "HH:mm");
            }
        }
    }
}

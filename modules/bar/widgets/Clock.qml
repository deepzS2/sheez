import QtQuick
import Quickshell
import Quickshell.Io
import qs.shared
import qs.components

BarWidget {
    id: root

    componentName: "Clock"
    tooltipText: root.calText
    implicitWidth: clockText.implicitWidth + Styles.widgetPadding * 2

    property string calText: ""

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
            onStreamFinished: root.calText = this.text
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (clockText.text.includes(":")) {
                clockText.text = " " + Qt.formatDate(new Date(), "dddd, MMMM d");
            } else {
                clockText.text = " " + Qt.formatTime(new Date(), "HH:mm");
            }
        }
    }
}

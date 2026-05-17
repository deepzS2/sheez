import QtQuick
import Quickshell
import Quickshell.Io
import qs.shared
import qs.components

BarWidget {
    id: root

    componentName: "Clock"
    tooltipText: {
        const today = Qt.formatDateTime(clock.date, "ddd dd/MM/yy HH:mm");

        return today + "\n\n" + root.calText;
    }
    implicitWidth: clockText.implicitWidth + Styles.widgetPadding * 2

    property string calText: ""
    property bool showDate: false

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: showDate ? " " + Qt.formatDate(clock.date, "dddd, MMMM d") : " " + Qt.formatTime(clock.date, "HH:mm:ss")
        font: Styles.systemFont
        color: Colors.conSurface
    }

    Process {
        id: calProcess
        running: true
        command: ["sh", "-c", "cal"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.calText = this.text;
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.showDate = !root.showDate;
        }
    }
}

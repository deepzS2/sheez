import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import qs.commons

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true

    property color textColor: "white"
    required property string text
    required property string icon
    required property string command

    readonly property var process: Process {
        command: ["sh", "-c", root.command]

        // qmllint disable signal-handler-parameters
        onExited: exitCode => {
            if (exitCode !== 0)
                Logger.error("LogoutButton", `Command failed: ${root.command}`);
        }
        // qmllint enable signal-handler-parameters
    }

    function exec() {
        process.startDetached();
    }

    Text {
        id: textIcon
        anchors.centerIn: parent
        color: root.textColor
        text: root.icon

        font {
            family: "feather"
            pointSize: 64
        }
    }

    Text {
        text: root.text
        color: root.textColor

        anchors {
            top: textIcon.bottom
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }

        font {
            family: "JetBrainsMono Nerd Font"
            pointSize: 20
        }
    }
}

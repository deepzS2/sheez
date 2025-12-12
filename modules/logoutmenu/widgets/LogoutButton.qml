import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import qs.commons

Rectangle {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 32

    property color textColor: "white"
    required property string text
    required property string icon
    property var command

    readonly property string commandString: {
        if (typeof command === 'string')
            return command;

        return '';
    }

    readonly property var process: Process {
        command: ["sh", "-c", root.commandString]

        // qmllint disable signal-handler-parameters
        onExited: exitCode => {
            if (exitCode !== 0)
                Logger.error("LogoutButton", `Command failed: ${root.commandString}`);

            PanelService.toggleLogoutMenu();
        }
        // qmllint enable signal-handler-parameters
    }

    function exec() {
        if (commandString) {
            process.startDetached();
        } else if (typeof root.command === 'function') {
            // qmllint disable use-proper-function
            root.command();
            // qmllint enable use-proper-function
            PanelService.toggleLogoutMenu();
        }
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

pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell
import qs.commons

Singleton {
    property string username: ""

    Process {
        running: true
        command: ["whoami"]
        stdout: StdioCollector {
            onStreamFinished: UserService.username = this.text.trim() || "user"
        }

        // qmllint disable signal-handler-parameters
        onExited: exitCode => {
            if (exitCode !== 0)
                Logger.warn("UserService", "Failed to get username");
        }
        // qmllint enable signal-handler-parameters
    }
}

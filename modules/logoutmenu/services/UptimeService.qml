pragma Singleton

import QtQuick
import Quickshell.Io
import Quickshell
import qs.commons

Singleton {
    id: root

    property real uptimeInSeconds: 0
    readonly property string uptimeText: {
        if (!root.uptimeInSeconds)
            return "00:00:00";

        return new Date(root.uptimeInSeconds * 1000).toISOString().substring(11, 19).replace("-", ":");
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: () => uptimeProcFile.reload()
    }

    FileView {
        id: uptimeProcFile
        path: "/proc/uptime"

        preload: true
        watchChanges: true
        blockLoading: true

        onFileChanged: this.reload()
        onLoaded: {
            if (!this.text())
                return;

            const uptimeSeconds = this.text().split(" ")[0];

            Logger.debugf("UptimeService", "/proc/uptime file: {0}", uptimeSeconds);

            if (!uptimeSeconds || isNaN(Number(uptimeSeconds))) {
                Logger.warn("UptimeService", "Invalid uptime data");
                return;
            }

            root.uptimeInSeconds = Number(uptimeSeconds);
        }
    }
}

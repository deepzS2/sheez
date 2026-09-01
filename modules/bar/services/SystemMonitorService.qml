pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "systemmonitor.js" as SystemMonitorParser
import qs.shared

Singleton {
    id: root

    // System monitoring properties
    property real cpuUsage: 0
    property real memoryUsage: 0

    // Signals for updates
    signal cpuUsageUpdated(real usage)
    signal memoryUsageUpdated(real usage)
    signal systemInfoUpdated(real cpu, real memory)

    // CPU calculation state
    property var previousCpuStats: null

    // Timer for periodic updates
    Timer {
        id: updateTimer
        interval: 3000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            cpuStatsView.reload();
            memoryInfoView.reload();
        }
    }

    // CPU stats file reader
    FileView {
        id: cpuStatsView
        path: "/proc/stat"
        blockWrites: true
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: root.parseCpuStats(text())
    }

    // Memory info file reader
    FileView {
        id: memoryInfoView
        path: "/proc/meminfo"
        blockWrites: true
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: root.parseMemoryInfo(text())
    }

    function parseCpuStats(text) {
        try {
            const stats = SystemMonitorParser.parseCpuTotals(text);

            if (!stats) {
                Logger.warn("SystemMonitorService", "CPU line not found in /proc/stat");
                return;
            }

            if (root.previousCpuStats) {
                const percentage = SystemMonitorParser.cpuUsage(stats, root.previousCpuStats);

                // We update if difference is bigger than 1%
                if (Math.abs(percentage - root.cpuUsage) > 1) {
                    root.cpuUsage = percentage;
                    root.cpuUsageUpdated(root.cpuUsage);
                    Logger.debugf("SystemMonitorService", "CPU usage updated: {0}%", root.cpuUsage.toFixed(1));
                }
            }

            root.previousCpuStats = stats;
        } catch (e) {
            Logger.errorf("SystemMonitorService", "Failed to parse CPU stats: {0}", e);
        }
    }

    function parseMemoryInfo(text) {
        try {
            const percentage = SystemMonitorParser.memoryUsage(text);

            if (percentage === null)
                return Logger.warn("SystemMonitorService", "Invalid memory values in /proc/meminfo");

            // We update if difference is bigger than 1%
            if (Math.abs(percentage - root.memoryUsage) > 1) {
                root.memoryUsage = percentage;
                root.memoryUsageUpdated(root.memoryUsage);

                Logger.debugf("SystemMonitorService", "Memory usage updated: {0}%", root.memoryUsage.toFixed(1));
            }
        } catch (e) {
            Logger.errorf("SystemMonitorService", "Failed to parse memory info: {0}", e);
        }
    }
}

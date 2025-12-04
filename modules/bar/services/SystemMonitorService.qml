pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.commons

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
            const lines = text.split('\n');
            const cpuLine = lines.find(line => line.startsWith('cpu '));

            if (!cpuLine) {
                Logger.warn("SystemMonitorService", "CPU line not found in /proc/stat");
                return;
            }

            const parts = cpuLine.trim().split(/\s+/);
            const user = parseInt(parts[1]);
            const nice = parseInt(parts[2]);
            const system = parseInt(parts[3]);
            const idle = parseInt(parts[4]);
            const iowait = parseInt(parts[5]);
            const irq = parseInt(parts[6]);
            const softirq = parseInt(parts[7]);

            const total = user + nice + system + idle + iowait + irq + softirq;
            const idleTotal = idle + iowait;

            if (root.previousCpuStats) {
                const prevTotal = root.previousCpuStats.total;
                const prevIdle = root.previousCpuStats.idle;

                const totalDiff = total - prevTotal;
                const idleDiff = idleTotal - prevIdle;

                const usage = ((totalDiff - idleDiff) / totalDiff) * 100;
                const percentage = Math.max(0, Math.min(100, usage));

                // We update if difference is bigger than 1%
                if (Math.abs(percentage - root.cpuUsage) > 1) {
                    root.cpuUsage = percentage;
                    root.cpuUsageUpdated(root.cpuUsage);
                    Logger.debugf("SystemMonitorService", "CPU usage updated: {0}%", root.cpuUsage.toFixed(1));
                }
            }

            root.previousCpuStats = {
                total,
                idle: idleTotal
            };
        } catch (e) {
            Logger.errorf("SystemMonitorService", "Failed to parse CPU stats: {0}", e);
        }
    }

    function parseMemoryInfo(text) {
        try {
            const lines = text.split('\n');

            const {
                memTotal,
                memAvailable
            } = lines.reduce((acc, line) => {
                const isMemTotal = line.startsWith('MemTotal');
                const isMemAvailable = line.startsWith('MemAvailable');

                if (!isMemTotal && !isMemAvailable)
                    return acc;

                const value = Number.parseInt(line.split(/\s+/)[1]);

                return {
                    memTotal: isMemTotal ? acc.memTotal + value : acc.memTotal,
                    memAvailable: isMemAvailable ? acc.memAvailable + value : acc.memAvailable
                };
            }, {
                memTotal: 0,
                memAvailable: 0
            });

            if (!memTotal || !memAvailable)
                return Logger.warn("SystemMonitorService", "Invalid memory values in /proc/meminfo");

            const usage = ((memTotal - memAvailable) / memTotal) * 100;
            const percentage = Math.max(0, Math.min(100, usage));

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

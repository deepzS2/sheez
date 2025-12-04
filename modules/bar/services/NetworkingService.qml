pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.commons

Singleton {
    id: root

    // Network properties
    readonly property string connectionType: networkInfo.connectionType
    readonly property string interfaceName: networkInfo.interfaceName
    readonly property string ipAddress: networkInfo.ipAddress
    readonly property string essid: networkInfo.essid
    readonly property int signalStrength: networkInfo.signalStrength
    readonly property string bandwidthTotalBytes: formatBandwidth(bandwidthStats.downSpeed + bandwidthStats.upSpeed)
    readonly property string bandwidthDownBits: formatBandwidthBits(bandwidthStats.downSpeed * 8)
    readonly property string bandwidthUpBits: formatBandwidthBits(bandwidthStats.upSpeed * 8)
    readonly property bool isConnected: networkInfo.isConnected

    // Icons based on connection type
    readonly property string networkIcon: {
        if (!isConnected)
            return "󱐅";

        const connectionTypeIcons = {
            wifi: "",
            ethernet: "󰈀"
        };

        return connectionTypeIcons[connectionType] ?? "󱐅";
    }

    // Internal network info object
    property var networkInfo: ({
            connectionType: "",
            interfaceName: "",
            ipAddress: "",
            essid: "",
            signalStrength: 0,
            isConnected: false
        })

    // Internal bandwidth stats object
    property var bandwidthStats: ({
            downSpeed: 0,
            upSpeed: 0
        })

    // Previous bandwidth stats for rate calculation
    property var previousStats: null
    property real lastUpdateTime: 0

    // Current connection being processed
    property var currentConnection: null

    // Timer for periodic updates
    Timer {
        id: updateTimer
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            networkProcess.running = true;
            bandwidthView.reload();
        }
    }

    // Network info process (nmcli)
    Process {
        id: networkProcess
        running: false
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION,DEVICE", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const bestConnection = root.parseNetworkInfo(this.text);
                if (bestConnection) {
                    root.currentConnection = bestConnection;
                    root.startNetworkDetailUpdate();
                } else {
                    root.updateNetworkDisconnected();
                }
            }
        }
    }

    // Device details process (nmcli device show)
    Process {
        id: deviceDetailsProcess
        running: false
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                const details = root.parseDeviceDetails(this.text);
                root.updateNetworkDetails(details);
            }
        }
    }

    // WiFi list process (nmcli device wifi list)
    Process {
        id: wifiListProcess
        running: false
        command: []
        stdout: StdioCollector {
            onStreamFinished: {
                const signalStrength = root.parseWiFiList(this.text);
                root.updateSignalStrength(signalStrength);
            }
        }
    }

    // Bandwidth file view
    FileView {
        id: bandwidthView
        path: "/proc/net/dev"
        blockWrites: true
        onLoaded: {
            const stats = root.parseBandwidth(text());
            if (stats) {
                root.updateBandwidth(stats);
            }
        }
    }

    function parseNetworkInfo(output) {
        const lines = output.trim().split('\n').filter(line => line.trim());
        let bestConnection = null;

        lines.forEach(line => {
            const parts = line.split(':');
            if (parts.length < 4)
                return;

            const [typeRaw, state, connection, device] = parts;
            const type = typeRaw.toLowerCase();

            if (state !== "connected")
                return;

            // Prefer ethernet over wifi
            if (type === "ethernet" || (type === "wifi" && !bestConnection)) {
                bestConnection = {
                    type,
                    connection,
                    device
                };
            }
        });

        return bestConnection;
    }

    function updateNetworkDisconnected() {
        root.networkInfo = {
            connectionType: "",
            interfaceName: "",
            ipAddress: "",
            essid: "",
            signalStrength: 0,
            isConnected: false
        };
    }

    function updateNetworkDetails(details) {
        root.networkInfo = {
            connectionType: root.currentConnection.type,
            interfaceName: root.currentConnection.device,
            ipAddress: details.ipAddress,
            essid: details.essid,
            signalStrength: 0,
            isConnected: true
        };

        if (root.currentConnection.type === "wifi") {
            wifiListProcess.command = ["nmcli", "-t", "-f", "SSID,SIGNAL", "device", "wifi", "list", "ifname", root.currentConnection.device];
            wifiListProcess.running = true;
        } else {
            Logger.debugf("NetworkingService", "Network updated: {0} on {1}", root.currentConnection.type, root.currentConnection.device);
        }
    }

    function updateSignalStrength(signalStrength) {
        root.networkInfo = Object.assign({}, root.networkInfo, {
            signalStrength
        });

        Logger.debugf("NetworkingService", "Network updated: {0} on {1}", root.currentConnection.type, root.currentConnection.device);
    }

    function updateBandwidth(currentStats) {
        const currentTime = Date.now() / 1000;
        const timeDiff = currentTime - root.lastUpdateTime;

        if (root.previousStats && timeDiff > 0) {
            const rxDiff = currentStats.rxBytes - root.previousStats.rxBytes;
            const txDiff = currentStats.txBytes - root.previousStats.txBytes;

            root.bandwidthStats = {
                downSpeed: rxDiff / timeDiff,
                upSpeed: txDiff / timeDiff
            };
        }

        root.previousStats = currentStats;
        root.lastUpdateTime = currentTime;
    }

    function startNetworkDetailUpdate() {
        if (!root.currentConnection)
            return;

        deviceDetailsProcess.command = ["nmcli", "-t", "-f", "all", "device", "show", root.currentConnection.device];
        deviceDetailsProcess.running = true;
    }

    function parseDeviceDetails(output) {
        const lines = output.trim().split('\n');
        let ipAddress = "";
        let essid = "";

        lines.forEach(line => {
            const parts = line.split(':');
            if (parts.length < 2)
                return;

            const key = parts[0];
            const value = parts.slice(1).join(':');

            if (key === 'IP4.ADDRESS[1]') {
                ipAddress = value.split('/')[0];
            } else if (key === 'GENERAL.CONNECTION' && root.currentConnection.type === "wifi") {
                essid = value;
            }
        });

        return {
            ipAddress,
            essid
        };
    }

    function parseWiFiList(output) {
        const lines = output.trim().split('\n');
        const targetEssid = root.networkInfo.essid;

        const signalStrength = lines.reduce((found, line) => {
            if (found > 0)
                return found;

            const parts = line.split(':');
            if (parts.length >= 2) {
                const [ssid, signalStr] = parts;
                const signal = parseInt(signalStr);

                if (ssid === targetEssid && !isNaN(signal)) {
                    return signal;
                }
            }
            return found;
        }, 0);

        return signalStrength;
    }

    function parseBandwidth(text) {
        const lines = text.split('\n');
        const interfaceName = root.interfaceName;
        const interfaceLine = lines.find(line => line.trim().startsWith(interfaceName + ':'));

        if (!interfaceLine)
            return null;

        const parts = interfaceLine.trim().split(/\s+/);
        if (parts.length < 10)
            return null;

        const rxBytes = parseInt(parts[1]);
        const txBytes = parseInt(parts[9]);

        return {
            rxBytes,
            txBytes
        };
    }

    function formatBandwidth(bytesPerSecond) {
        if (bytesPerSecond === 0)
            return "0B";

        const units = ['B', 'K', 'M', 'G'];
        const k = 1024;
        const i = Math.floor(Math.log(bytesPerSecond) / Math.log(k));

        return `${(bytesPerSecond / Math.pow(k, i)).toFixed(1)}${units[i]}`;
    }

    function formatBandwidthBits(bitsPerSecond) {
        if (bitsPerSecond === 0)
            return "0b";

        const units = ['b', 'K', 'M', 'G'];
        const k = 1000;
        const i = Math.floor(Math.log(bitsPerSecond) / Math.log(k));

        return `${(bitsPerSecond / Math.pow(k, i)).toFixed(1)}${units[i]}`;
    }

    function launchWifiMenu() {
        Quickshell.execDetached(["wifimenu"]);
        Logger.info("NetworkingService", "Launched wifimenu");
    }

    function launchNetworkManager() {
        Quickshell.execDetached(["nm-connection-editor"]);
        Logger.info("NetworkingService", "Launched nm-connection-editor");
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("NetworkingService", "Network service initialized");
    }
}

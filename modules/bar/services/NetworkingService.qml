pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "networking.js" as NetworkParser
import qs.shared

Singleton {
    id: root

    // Network properties
    readonly property string connectionType: networkInfo.connectionType
    readonly property string interfaceName: networkInfo.interfaceName
    readonly property string ipAddress: networkInfo.ipAddress
    readonly property string essid: networkInfo.essid
    readonly property int signalStrength: networkInfo.signalStrength
    readonly property string bandwidthTotalBytes: NetworkParser.formatBandwidth(bandwidthStats.downSpeed + bandwidthStats.upSpeed)
    readonly property string bandwidthDownBits: NetworkParser.formatBandwidthBits(bandwidthStats.downSpeed * 8)
    readonly property string bandwidthUpBits: NetworkParser.formatBandwidthBits(bandwidthStats.upSpeed * 8)
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
                const bestConnection = NetworkParser.parseNetworkInfo(this.text);
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
                const details = NetworkParser.parseDeviceDetails(this.text, root.currentConnection.type);
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
                const signalStrength = NetworkParser.parseWiFiList(this.text, root.networkInfo.essid);
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
            const stats = NetworkParser.parseBandwidth(text(), root.interfaceName);
            if (stats) {
                root.updateBandwidth(stats);
            }
        }
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

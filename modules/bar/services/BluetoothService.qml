pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.commons

Singleton {
    id: root

    // Bluetooth adapter properties
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.powered || false
    readonly property bool discovering: adapter?.discovering || false

    // Connected devices
    readonly property var connectedDevices: {
        if (!adapter)
            return [];

        return Bluetooth.devices?.filter(device => device.connected) ?? [];
    }

    readonly property int connectedCount: connectedDevices.length

    // Icon based on state
    readonly property string icon: {
        if (!powered)
            return "󰂲";
        if (connectedCount > 0)
            return "󰂴";
        return "󰂰";
    }

    // Detailed tooltip
    readonly property string tooltip: {
        let text = `Bluetooth: ${powered ? "On" : "Off"}`;
        if (powered) {
            text += `\nDiscovering: ${discovering ? "Yes" : "No"}`;
            text += `\nConnected devices: ${connectedCount}`;
            if (connectedCount > 0) {
                connectedDevices.forEach(device => {
                    const battery = device.battery ? ` (${device.battery}%)` : "";
                    text += `\n• ${device.name || device.address}${battery}`;
                });
            }
        }
        return text;
    }

    // Methods
    function togglePower() {
        if (!adapter) {
            Logger.warn("BluetoothService", "No adapter available to toggle power");
            return;
        }
        adapter.powered = !adapter.powered;
        Logger.debugf("BluetoothService", "Bluetooth power toggled to: {0}", adapter.powered);
    }

    function startDiscovery() {
        if (!adapter) {
            Logger.warn("BluetoothService", "No adapter available to start discovery");
            return;
        }

        adapter.startDiscovery();
        Logger.debug("BluetoothService", "Started Bluetooth discovery");
    }

    function stopDiscovery() {
        if (!adapter) {
            Logger.warn("BluetoothService", "No adapter available to stop discovery");
            return;
        }

        adapter.stopDiscovery();
        Logger.debug("BluetoothService", "Stopped Bluetooth discovery");
    }

    function launchBluemanManager() {
        Quickshell.execDetached(["blueman-manager"]);
        Logger.info("BluetoothService", "Launched blueman-manager");
    }

    // Initialize
    Component.onCompleted: {
        Logger.info("BluetoothService", "Bluetooth service initialized");
        Logger.debugf("BluetoothService", "Adapter available: {0}", !!adapter);
        Logger.debugf("BluetoothService", "Powered: {0}", powered);
    }
}

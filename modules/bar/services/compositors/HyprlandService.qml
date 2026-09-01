pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "dedupe.js" as Dedupe
import "hyprland.js" as HyprlandParser
import qs.shared

Item {
    id: root

    // Signals for workspace updates
    signal workspacesUpdated(var workspaces)
    signal windowUpdated(var windowInfo)
    signal error(string message)

    // Properties
    property bool active: false
    property string hyprlandSocket: getHyprlandSocket()
    property var _lastWorkspaceState: null
    property var _lastWindowState: null

    // Hyprland IPC socket watcher
    Process {
        id: hyprlandEventProcess
        running: root.active && root.hyprlandSocket !== ""
        command: ["socat", "-", `UNIX-CONNECT:${root.hyprlandSocket}`]
        onRunningChanged: if (!running && root.active && root.hyprlandSocket !== "")
            running = true
        stdout: SplitParser {
            onRead: data => {
                root.parseHyprlandEvents(data);
            }
        }
    }

    // Workspace query process
    Process {
        id: hyprlandWorkspacesProcess
        running: false
        command: ["hyprctl", "workspaces", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseWorkspaces(this.text);
            }
        }
    }

    // Active workspace query process
    Process {
        id: hyprlandActiveWorkspaceProcess
        running: false
        command: ["hyprctl", "activeworkspace", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseActiveWorkspace(this.text);
            }
        }
    }

    // Clients (windows) query process
    Process {
        id: hyprlandClientsProcess
        running: false
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseClients(this.text);
            }
        }
    }

    // Periodic refresh timer
    Timer {
        id: refreshTimer
        interval: 2000
        running: root.active
        repeat: true
        onTriggered: {
            root.refreshWorkspaces();
        }
    }

    function activate() {
        Logger.info("HyprlandService", "Activating Hyprland service");
        active = true;
        refreshWorkspaces();
        refreshClients();
    }

    function deactivate() {
        Logger.info("HyprlandService", "Deactivating Hyprland service");
        active = false;
    }

    function switchToWorkspace(workspaceId) {
        Logger.infof("HyprlandService", "Switching to workspace {0}", workspaceId);
        Quickshell.execDetached(["hyprctl", "dispatch", "workspace", workspaceId.toString()]);
    }

    function refreshWorkspaces() {
        if (active) {
            hyprlandWorkspacesProcess.running = true;
            hyprlandActiveWorkspaceProcess.running = true;
        }
    }

    function refreshClients() {
        if (active) {
            hyprlandClientsProcess.running = true;
        }
    }

    function getHyprlandSocket() {
        // Try to get the Hyprland socket path from environment
        const instanceSignature = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE");
        if (instanceSignature) {
            return `/tmp/hypr/${instanceSignature}/.socket2.sock`;
        }

        // Fallback to common socket path
        const socketPath = `/tmp/hypr/${Quickshell.env("USER")}/.socket2.sock`;
        return socketPath;
    }

    function parseWorkspaces(output) {
        try {
            const workspaces = HyprlandParser.parseWorkspaces(output);

            if (!Dedupe.workspacesEqual(workspaces, _lastWorkspaceState)) {
                Logger.debugf("HyprlandService", "Workspaces updated ({0} workspaces)", workspaces.length);
                _lastWorkspaceState = workspaces;
                workspacesUpdated(workspaces);
            }
        } catch (e) {
            error(`Failed to parse workspace data: ${e}`);
        }
    }

    function parseClients(output) {
        try {
            const windowInfo = HyprlandParser.parseFocusedWindow(output);

            if (!Dedupe.windowsEqual(windowInfo, _lastWindowState)) {
                Logger.debugf("HyprlandService", "Window updated: {0} ({1})", windowInfo.title, windowInfo.appId);
                _lastWindowState = windowInfo;
                windowUpdated(windowInfo);
            }
        } catch (e) {
            error(`Failed to parse client data: ${e}`);
        }
    }

    function parseActiveWorkspace(output) {
        try {
            const activeId = HyprlandParser.parseActiveWorkspaceId(output);

            // Active-workspace events can arrive before the first workspaces query
            if (_lastWorkspaceState) {
                const workspaces = HyprlandParser.markActiveWorkspace(_lastWorkspaceState, activeId);
                if (!Dedupe.workspacesEqual(workspaces, _lastWorkspaceState)) {
                    _lastWorkspaceState = workspaces;
                    workspacesUpdated(workspaces);
                }
            }

            Logger.debugf("HyprlandService", "Active workspace updated: {0}", activeId);
        } catch (e) {
            error(`Failed to parse active workspace data: ${e}`);
        }
    }

    function parseHyprlandEvents(output) {
        try {
            const targets = HyprlandParser.parseEventTargets(output);
            if (targets.workspaces)
                refreshWorkspaces();
            if (targets.windows)
                refreshClients();
        } catch (e) {
            error(`Error parsing event: ${e}`);
        }
    }

    function detect() {
        // Check for Hyprland-specific environment variables
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE")) {
            Logger.debug("HyprlandService", "Detected Hyprland via HYPRLAND_INSTANCE_SIGNATURE environment variable");
            return true;
        }

        // Check Wayland display for Hyprland
        const waylandDisplay = Quickshell.env("WAYLAND_DISPLAY");
        if (waylandDisplay?.includes("hyprland")) {
            Logger.debug("HyprlandService", "Detected Hyprland via WAYLAND_DISPLAY environment variable");
            return true;
        }

        // Check for Hyprland desktop environment
        if (Quickshell.env("XDG_CURRENT_DESKTOP") === "Hyprland") {
            Logger.debug("HyprlandService", "Detected Hyprland via XDG_CURRENT_DESKTOP environment variable");
            return true;
        }

        Logger.debug("HyprlandService", "Hyprland not detected");
        return false;
    }
}

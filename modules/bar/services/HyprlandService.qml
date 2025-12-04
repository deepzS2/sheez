pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.commons

Item {
    id: root

    // Signals for workspace updates
    signal workspacesUpdated(var workspaces)
    signal workspaceActivated(var workspace)
    signal windowUpdated(var windowInfo)
    signal error(string message, var error)

    // Properties
    property bool active: false
    property ListModel workspaces: ListModel {}
    property string hyprlandSocket: getHyprlandSocket()
    property var _lastWorkspaceState: null
    property var currentWindow: null
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
            const data = JSON.parse(output);
            if (!Array.isArray(data))
                throw new Error("Invalid Hyprland Workspaces Output");

            const processedItems = processWorkspaceData(data);
            updateWorkspacesModel(processedItems);

            const currentState = processedItems.map(ws => ({
                        id: ws.id,
                        name: ws.name,
                        isActive: ws.isActive,
                        isOccupied: ws.isOccupied
                    }));

            if (!isWorkspacesEqual(currentState, _lastWorkspaceState)) {
                Logger.debugf("HyprlandService", "Workspaces updated ({0} workspaces)", workspaces.count);
                Logger.table(processedItems);
                _lastWorkspaceState = currentState;
                workspacesUpdated(workspaces);
            }
        } catch (e) {
            error(`Failed to parse workspace data`, e);
        }
    }

    function processWorkspaceData(data) {
        return data.sort((a, b) => a.id - b.id).map(item => ({
                    id: item.id,
                    // Hyprland uses id as index
                    idx: item.id,
                    name: item.name || "",
                    output: item.monitor || "",
                    // Will be updated by active workspace query
                    isFocused: false,
                    // Will be updated by active workspace query
                    isActive: false,
                    isUrgent: item.urgent || false,
                    isOccupied: item.windows > 0
                }));
    }

    function updateWorkspacesModel(processedItems) {
        workspaces.clear();
        processedItems.forEach(item => workspaces.append(item));
    }

    function isWorkspacesEqual(workspacesA, workspacesB) {
        if (!workspacesA || !workspacesB || workspacesA.length !== workspacesB.length)
            return false;

        return workspacesA.every((ws1, index) => {
            const ws2 = workspacesB[index];
            return ws1.id === ws2.id && ws1.name === ws2.name && ws1.isActive === ws2.isActive && ws1.isOccupied === ws2.isOccupied;
        });
    }

    function parseClients(output) {
        try {
            const data = JSON.parse(output);
            if (!Array.isArray(data))
                throw new Error("Invalid Hyprland Clients Output");

            const windowInfo = processClientData(data);

            if (!isWindowsEqual(windowInfo, _lastWindowState)) {
                Logger.debugf("HyprlandService", "Window updated: {0} ({1})", windowInfo.title, windowInfo.appId);
                _lastWindowState = windowInfo;
                currentWindow = windowInfo;
                windowUpdated(windowInfo);
            }
        } catch (e) {
            error(`Failed to parse client data`, e);
        }
    }

    function processClientData(data) {
        const focusedWindow = data.find(client => client.focused === true);

        return focusedWindow ? {
            title: focusedWindow.title || "",
            // Hyprland uses 'class' instead of 'app_id'
            appId: focusedWindow.class || "",
            isFocused: true
        } : {
            title: "",
            appId: "",
            isFocused: false
        };
    }

    function isWindowsEqual(windowA, windowB) {
        if (!windowA && !windowB)
            return true;
        if (!windowA || !windowB)
            return false;

        return windowA.title === windowB.title && windowA.appId === windowB.appId && windowA.isFocused === windowB.isFocused;
    }

    function parseActiveWorkspace(output) {
        try {
            const data = JSON.parse(output);

            if (!data || typeof data.id === 'undefined')
                throw new Error("Invalid Hyprland Active Workspace Output");

            updateWorkspaceActiveStatus(data.id);
            Logger.debugf("HyprlandService", "Active workspace updated: {0}", data.id);
        } catch (e) {
            error(`Failed to parse active workspace data`, e);
        }
    }

    function updateWorkspaceActiveStatus(activeId) {
        for (let i = 0; i < workspaces.count; i++) {
            const workspace = workspaces.get(i);
            const isActive = workspace.id === activeId;
            const isFocused = workspace.id === activeId;

            workspaces.set(i, {
                id: workspace.id,
                idx: workspace.idx,
                name: workspace.name,
                output: workspace.output,
                isFocused: isFocused,
                isActive: isActive,
                isUrgent: workspace.isUrgent,
                isOccupied: workspace.isOccupied
            });
        }
    }

    function parseHyprlandEvents(output) {
        try {
            const lines = output.split('\n').filter(line => line.trim());
            processEvents(lines);
        } catch (e) {
            error(`Error parsing event`, e);
        }
    }

    function processEvents(lines) {
        const workspaceEvents = ['workspace', 'focusedmon', 'createworkspace', 'destroyworkspace'];
        const windowEvents = ['activewindow', 'closewindow', 'openwindow', 'movewindow'];

        for (const line of lines) {
            if (!line.includes('>>'))
                continue;

            const [eventType, eventData] = line.split('>>', 2);
            Logger.debugf("HyprlandService", `Event received: {0}`, eventType);

            if (workspaceEvents.includes(eventType)) {
                refreshWorkspaces();
            } else if (windowEvents.includes(eventType)) {
                refreshClients();
            }
        }
    }

    function detect() {
        // Check for Hyprland-specific environment variables
        if (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== undefined) {
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

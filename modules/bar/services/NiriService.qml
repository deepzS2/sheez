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
    signal error(string message)

    // Properties
    property bool active: false
    property ListModel workspaces: ListModel {}
    property var _lastWorkspaceState: null
    property var currentWindow: null
    property var _lastWindowState: null

    // Niri IPC socket watcher
    Process {
        id: niriEventProcess
        running: root.active
        command: ["niri", "msg", "-j", "event-stream"]
        onRunningChanged: if (!running && root.active)
            running = true
        stdout: SplitParser {
            onRead: data => {
                root.parseNiriEvents(data);
            }
        }
    }

    // Initial workspace query
    Process {
        id: niriWorkspacesProcess
        running: false
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseWorkspaces(this.text);
            }
        }
    }

    // Initial window query
    Process {
        id: niriWindowsProcess
        running: false
        command: ["niri", "msg", "-j", "windows"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.parseWindows(this.text);
            }
        }
    }

    // Periodic refresh timer (fallback if event stream doesn't work)
    Timer {
        id: refreshTimer
        interval: 2000
        running: root.active
        repeat: true
        onTriggered: {
            niriWorkspacesProcess.running = true;
        }
    }

    function activate() {
        Logger.info("NiriService", "Activating Niri service");
        active = true;
        niriWorkspacesProcess.running = true;
        niriWindowsProcess.running = true;
    }

    function deactivate() {
        Logger.info("NiriService", "Deactivating Niri service");
        active = false;
    }

    function switchToWorkspace(workspaceId) {
        Logger.infof("NiriService", "Switching to workspace {0}", workspaceId);

        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", workspaceId]);
    }

    function refreshWorkspaces() {
        if (active) {
            niriWorkspacesProcess.running = true;
        }
    }

    // Internal functions
    function parseWorkspaces(output) {
        try {
            const data = JSON.parse(output);
            if (!Array.isArray(data))
                throw new Error("Invalid Niri Workspaces Output");

            const processedItems = processWorkspaceData(data);
            updateWorkspacesModel(processedItems);

            if (!isWorkspacesEqual(processedItems, _lastWorkspaceState)) {
                Logger.debugf("NiriService", "Workspaces updated ({0} workspaces)", workspaces.count);
                Logger.table(processedItems);
                _lastWorkspaceState = processedItems;
                workspacesUpdated(workspaces);
            }
        } catch (e) {
            error(`Failed to parse workspace data`, e);
        }
    }

    function processWorkspaceData(data) {
        return data.sort((a, b) => a.idx - b.idx).map(item => ({
                    id: item.id,
                    idx: item.idx,
                    name: item.name ?? "",
                    output: item.output ?? "",
                    isFocused: item.is_focused ?? false,
                    isActive: item.is_active ?? false,
                    isUrgent: item.is_urgent ?? false,
                    isOccupied: !Number.isNaN(item.is_occupied)
                }));
    }

    function updateWorkspacesModel(processedItems) {
        workspaces.clear();
        processedItems.forEach(item => workspaces.append(item));
    }

    function parseWindows(output) {
        try {
            const data = JSON.parse(output);

            if (!Array.isArray(data))
                throw new Error("Invalid Niri Windows Output");

            const windowInfo = processWindowData(data);

            if (!isWindowsEqual(windowInfo, _lastWindowState)) {
                Logger.debugf("NiriService", "Window updated: {0} ({1})", windowInfo.title, windowInfo.appId);
                _lastWindowState = windowInfo;
                currentWindow = windowInfo;
                windowUpdated(windowInfo);
            }
        } catch (e) {
            error(`Failed to parse window data`, e);
        }
    }

    function processWindowData(data) {
        const focusedWindow = data.find(window => window.is_focused);

        return {
            title: focusedWindow?.title || "",
            appId: focusedWindow?.app_id || "",
            isFocused: !!focusedWindow
        };
    }

    function isWindowsEqual(windowA, windowB) {
        if (!windowA && !windowB)
            return true;
        if (!windowA || !windowB)
            return false;

        return windowA.title === windowB.title && windowA.appId === windowB.appId && windowA.isFocused === windowB.isFocused;
    }

    function isWorkspacesEqual(workspacesA, workspacesB) {
        if (!workspacesA || !workspacesB || workspacesA.length !== workspacesB.length)
            return false;

        return workspacesA.every((ws1, index) => {
            const ws2 = workspacesB[index];
            return ws1.id === ws2.id && ws1.name === ws2.name && ws1.isActive === ws2.isActive && ws1.isOccupied === ws2.isOccupied;
        });
    }

    function parseNiriEvents(output) {
        try {
            if (!output)
                return;

            const data = JSON.parse(output);
            const eventName = Object.keys(data)?.[0];
            Logger.debugf("NiriService", "Event received: {0}", eventName);

            processEvent(eventName);
        } catch (e) {
            error(`Error parsing event`, e);
        }
    }

    function processEvent(eventName) {
        const workspaceEvents = ["WorkspacesChanged", "WorkspaceActivated"];
        const windowEvents = ["WindowOpenedOrChanged", "WindowClosed", "WindowFocusChanged"];

        if (workspaceEvents.includes(eventName)) {
            niriWorkspacesProcess.running = true;
        } else if (windowEvents.includes(eventName)) {
            niriWindowsProcess.running = true;
        }
    }

    function detect() {
        // Check for Niri-specific environment variables
        if (Quickshell.env("NIRI_SOCKET") !== undefined) {
            Logger.debug("NiriService", "Detected Niri via NIRI_SOCKET environment variable");
            return true;
        }

        // Check for Niri desktop environment
        if (Quickshell.env("XDG_CURRENT_DESKTOP") === "Niri") {
            Logger.debug("NiriService", "Detected Niri via XDG_CURRENT_DESKTOP environment variable");
            return true;
        }

        Logger.debug("NiriService", "Niri not detected");
        return false;
    }
}

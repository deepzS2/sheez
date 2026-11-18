pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "dedupe.js" as Dedupe
import "niri.js" as NiriParser
import qs.shared

Item {
    id: root

    // Signals for workspace updates
    signal workspacesUpdated(var workspaces)
    signal error(string message)

    // Properties
    property bool active: false
    property var _lastWorkspaceState: null
    property var _lastWindows: null
    property var _lastJoinedState: null

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

    // Joins each active workspace with the window focused on it
    function emitJoinedWorkspaces() {
        if (_lastWorkspaceState === null)
            return;

        const windows = _lastWindows || [];
        const joined = _lastWorkspaceState.map((workspace) => {
            if (!workspace.isActive)
                return workspace;

            const active = windows.find(window => window.id === workspace.activeWindowId);
            return Object.assign({}, workspace, {
                activeWindow: active ? { title: active.title, appId: active.appId } : null
            });
        });

        if (!Dedupe.workspacesEqual(joined, _lastJoinedState)) {
            _lastJoinedState = joined;
            workspacesUpdated(joined);
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
            const workspaces = NiriParser.parseWorkspaces(output);

            if (!Dedupe.workspacesEqual(workspaces, _lastWorkspaceState)) {
                Logger.debugf("NiriService", "Workspaces updated ({0} workspaces)", workspaces.length);
                _lastWorkspaceState = workspaces;
                emitJoinedWorkspaces();
            }
        } catch (e) {
            error(`Failed to parse workspace data: ${e}`);
        }
    }

    function parseWindows(output) {
        try {
            const windows = NiriParser.parseWindows(output);

            if (!Dedupe.windowsEqual(windows, _lastWindows)) {
                _lastWindows = windows;
                emitJoinedWorkspaces();
            }
        } catch (e) {
            error(`Failed to parse window data: ${e}`);
        }
    }

    function parseNiriEvents(output) {
        try {
            if (!output)
                return;

            const eventName = NiriParser.parseEventName(output);
            Logger.debugf("NiriService", "Event received: {0}", eventName);

            const targets = NiriParser.eventTargets(eventName);
            if (targets.workspaces)
                niriWorkspacesProcess.running = true;
            if (targets.windows)
                niriWindowsProcess.running = true;
        } catch (e) {
            error(`Error parsing event: ${e}`);
        }
    }

    function detect() {
        // Check for Niri-specific environment variables
        if (Quickshell.env("NIRI_SOCKET")) {
            Logger.debugf("NiriService", "Detected Niri via NIRI_SOCKET environment variable");
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

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "dedupe.js" as Dedupe
import "mango.js" as MangoParser
import qs.shared

Item {
    id: root

    // Signals for workspace updates
    signal workspacesUpdated(var workspaces)
    signal error(string message)

    // Properties
    property bool active: false
    property var _lastWorkspaceState: null
    property var _lastMonitors: null
    property var _lastJoinedState: null

    // Per-monitor active clients (focused window on each output)
    Process {
        id: mangoMonitorsProcess
        running: root.active
        command: ["mmsg", "watch", "all-monitors"]
        onRunningChanged: if (!running && root.active)
            running = true
        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                root.parseMangoMonitors(data);
            }
        }
    }

    // Mango IPC tags
    Process {
        id: mangoTagsProcess
        running: root.active
        command: ["mmsg", "watch", "all-tags"]
        onRunningChanged: if (!running && root.active)
            running = true
        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                root.parseMangoTags(data);
            }
        }
    }

    function activate() {
        Logger.info("MangoService", "Activating Mango service");
        active = true;
    }

    function deactivate() {
        Logger.info("MangoService", "Deactivating Mango service");
        active = false;
    }

    // workspaceId is the composite "<monitor>:<tagIndex>"
    function switchToWorkspace(workspaceId) {
        const separator = workspaceId.lastIndexOf(":");
        const monitor = workspaceId.substring(0, separator);
        const tag = workspaceId.substring(separator + 1);
        Logger.infof("MangoService", "Switching to workspace {0} on {1}", tag, monitor);

        // Plain `view,<n>` acts on the focused monitor only; this targets the
        // monitor whose bar was clicked
        Quickshell.execDetached(["mmsg", "dispatch", `viewcrossmon,${tag},${monitor}`]);
    }

    function refreshWorkspaces() {
    }

    function parseMangoTags(output) {
        try {
            if (!output)
                return;

            const workspaces = MangoParser.parseWorkspaces(output);

            if (!Dedupe.workspacesEqual(workspaces, _lastWorkspaceState)) {
                Logger.debugf("MangoService", "Workspaces updated ({0} workspaces)", workspaces.length);
                _lastWorkspaceState = workspaces;
                emitJoinedWorkspaces();
            }
        } catch (e) {
            error(`Error parsing tags: ${e}`);
        }
    }

    function parseMangoMonitors(output) {
        try {
            if (!output)
                return;

            const monitors = MangoParser.parseMonitors(output);

            if (!Dedupe.monitorsEqual(monitors, _lastMonitors)) {
                _lastMonitors = monitors;
                emitJoinedWorkspaces();
            }
        } catch (e) {
            error(`Error parsing monitors: ${e}`);
        }
    }

    // Joins the active tag of each monitor with that monitor's active client
    function emitJoinedWorkspaces() {
        if (_lastWorkspaceState === null || _lastMonitors === null)
            return;

        const monitorsByName = {};
        _lastMonitors.forEach(monitor => monitorsByName[monitor.name] = monitor);

        const joined = _lastWorkspaceState.map((workspace) => {
            const monitor = monitorsByName[workspace.output];
            return Object.assign({}, workspace, {
                activeWindow: workspace.isActive && monitor ? monitor.activeClient : null
            });
        });

        if (!Dedupe.workspacesEqual(joined, _lastJoinedState)) {
            _lastJoinedState = joined;
            workspacesUpdated(joined);
        }
    }

    function detect() {
        // Check for Mango desktop environment
        if (Quickshell.env("XDG_CURRENT_DESKTOP") === "mango") {
            Logger.debug("MangoService", "Detected Mango via XDG_CURRENT_DESKTOP environment variable");
            return true;
        }

        Logger.debug("MangoService", "Mango not detected");
        return false;
    }
}

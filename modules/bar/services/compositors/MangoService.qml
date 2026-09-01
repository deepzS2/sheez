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
    signal windowUpdated(var windowInfo)
    signal error(string message)

    // Properties
    property bool active: false
    property var _lastWorkspaceState: null
    property var _lastWindowState: null

    // Mango IPC focused client
    Process {
        id: mangoFocusedClientProcess
        running: root.active
        command: ["mmsg", "watch", "focusing-client"]
        onRunningChanged: if (!running && root.active)
            running = true
        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                root.parseMangoFocusedClient(data);
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

    function switchToWorkspace(workspaceId) {
        Logger.infof("MangoService", "Switching to workspace {0}", workspaceId);

        Quickshell.execDetached(["mmsg", "-t", workspaceId]);
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
                workspacesUpdated(workspaces);
            }
        } catch (e) {
            error(`Error parsing tags: ${e}`);
        }
    }

    function parseMangoFocusedClient(output) {
        try {
            if (!output)
                return;

            const windowInfo = MangoParser.parseFocusedWindow(output);

            if (!Dedupe.windowsEqual(windowInfo, _lastWindowState)) {
                Logger.debugf("MangoService", "Window updated: {0} ({1})", windowInfo.title, windowInfo.appId);
                _lastWindowState = windowInfo;
                windowUpdated(windowInfo);
            }
        } catch (e) {
            error(`Error parsing focused client: ${e}`);
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

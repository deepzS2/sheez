pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.shared

Item {
    id: root

    // Signals for workspace updates
    signal workspacesUpdated(var workspaces)
    signal windowUpdated(var windowInfo)
    signal error(string message)

    // Properties
    property bool active: false
    property var _lastTagsState: null
    property var _lastClientState: null

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

            const {
                all_tags: allTags
            } = JSON.parse(output);

            // no flatmap?
            const tags = allTags.reduce((tags, monitorTags) => tags.concat(monitorTags.tags), []).map(tag => ({
                        id: tag.index,
                        isActive: tag["is_active"],
                        isUrgent: tag["is_urgent"]
                    }));

            if (!isTagsEqual(tags, _lastTagsState)) {
                Logger.debugf("MangoService", "Workspaces updated ({0} workspaces)", _lastTagsState?.length);
                Logger.table(tags);
                _lastTagsState = tags;
                workspacesUpdated(tags);
            }
        } catch (e) {
            error(`Error parsing tags`, e);
        }
    }

    function parseMangoFocusedClient(output) {
        try {
            if (!output)
                return;

            const data = JSON.parse(output);

            const activeClient = {
                appId: data.appid,
                title: data.title
            };

            if (!isClientsEqual(activeClient, _lastClientState)) {
                Logger.debugf("MangoService", "Client updated: {0} ({1})", activeClient.title, activeClient.appId);
                _lastClientState = activeClient;
                windowUpdated(activeClient);
            }
        } catch (e) {
            error(`Error parsing focused client`, e);
        }
    }

    function isClientsEqual(clientA, clientB) {
        if (!clientA || !clientB)
            return !clientA && !clientB;

        return clientA.appId === clientB.appId && clientA.title === clientB.title;
    }

    function isTagsEqual(tagsA, tagsB) {
        if (!tagsA || !tagsB || tagsA.length !== tagsB.length)
            return false;

        return tagsA.every((tagA, index) => {
            const tagB = tagsB[index];
            return tagA.id === tagB.id && tagA.isActive === tagB.isActive && tagA.isUrgent === tagB.isUrgent;
        });
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

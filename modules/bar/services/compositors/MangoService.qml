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

    // Mango IPC socket watcher
    Process {
        id: mangoValuesProcess
        running: root.active
        command: ["mmsg", "-w", "-t", "-c"] // Tags and focused client
        onRunningChanged: if (!running && root.active)
            running = true
        stdout: SplitParser {
            splitMarker: ""

            onRead: data => {
                root.parseMangoValues(data);
            }
        }
    }

    function activate() {
        Logger.info("MangoService", "Activating Mango service");
        active = true;
        mangoValuesProcess.running = true;
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

    function parseMangoValues(output) {
        try {
            if (!output)
                return;

            const lines = output.split("\n");
            const activeClient = lines.filter(line => line.includes("appid") || line.includes("title")).reduce((acc, line) => {
                const [_, key, ...value] = line.split(" ");

                const normalizedKey = key === 'appid' ? 'appId' : key;

                return Object.assign({
                    [normalizedKey]: value.join(" ")
                }, acc);
            }, {});

            const tags = lines.filter(line => line.search(/tag\s/) !== -1).reduce((acc, line) => {
                const [, , tagId, state] = line.split(" ");

                if (acc.find(tag => tag.id === tagId)) {
                    return acc;
                }

                return acc.concat([
                    {
                        id: tagId,
                        isActive: state === "1",
                        isUrgent: state === "2"
                    }
                ]);
            }, []);

            if (!isClientsEqual(activeClient, _lastClientState)) {
                Logger.debugf("MangoService", "Client updated: {0} ({1})", activeClient.title, activeClient.appId);
                _lastClientState = activeClient;
                windowUpdated(activeClient);
            }

            if (!isTagsEqual(tags, _lastTagsState)) {
                Logger.debugf("MangoService", "Workspaces updated ({0} workspaces)", _lastTagsState?.length);
                Logger.table(tags);
                _lastTagsState = tags;
                workspacesUpdated(tags);
            }
        } catch (e) {
            error(`Error parsing values`, e);
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

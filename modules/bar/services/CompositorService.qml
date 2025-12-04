pragma Singleton

import QtQuick
import Quickshell
import qs.commons

Singleton {
    id: root

    signal workspacesUpdated(var workspaces)
    signal workspaceActivated(var workspace)
    signal windowUpdated(var windowInfo)
    signal error(string message, var error)

    property string detectedCompositor: ""
    property var activeService: null
    property bool active: false

    property var niriService: NiriService {
        onWorkspacesUpdated: workspaces => root.workspacesUpdated(workspaces)
        onWorkspaceActivated: workspace => root.workspaceActivated(workspace)
        onWindowUpdated: windowInfo => root.windowUpdated(windowInfo)
        onError: message => root.error(`NiriService: ${message}`)
    }

    property var hyprlandService: HyprlandService {
        onWorkspacesUpdated: workspaces => root.workspacesUpdated(workspaces)
        onWorkspaceActivated: workspace => root.workspaceActivated(workspace)
        onWindowUpdated: windowInfo => root.windowUpdated(windowInfo)
        onError: (message, error) => root.error(`HyprlandService: ${message}`, error)
    }

    function activate() {
        if (active)
            return;

        const compositor = detectCompositor();
        detectedCompositor = compositor;

        switch (compositor) {
        case "niri":
            Logger.info("CompositorService", "Using Niri service");
            activeService = niriService;
            break;
        case "hyprland":
            Logger.info("CompositorService", "Using Hyprland service");
            activeService = hyprlandService;
            break;
        default:
            error(`Unsupported compositor: ${compositor}`);
            return;
        }

        if (activeService) {
            activeService.activate();
            active = true;
        }
    }

    function deactivate() {
        Logger.info("CompositorService", "Deactivating compositor service");

        if (!active)
            return;

        if (activeService) {
            activeService.deactivate();
            activeService = null;
        }

        active = false;
        detectedCompositor = "";
    }

    function switchToWorkspace(workspaceId) {
        if (activeService) {
            activeService.switchToWorkspace(workspaceId);
        } else {
            error("No active compositor service");
        }
    }

    function refreshWorkspaces() {
        if (activeService) {
            activeService.refreshWorkspaces();
        }
    }

    function getWorkspaces() {
        return activeService ? activeService.workspaces : null;
    }

    function detectCompositor() {
        Logger.info("CompositorService", "Detecting compositor...");

        const services = [
            {
                name: "niri",
                service: niriService
            },
            {
                name: "hyprland",
                service: hyprlandService
            }
        ];

        for (const {
            name,
            service
        } of services) {
            if (service.detect()) {
                Logger.info("CompositorService", `Detected {0} compositor`, name);
                return name;
            }
        }

        Logger.warn("CompositorService", "Could not detect compositor, fallbacking to niri");
        return "niri";
    }
}

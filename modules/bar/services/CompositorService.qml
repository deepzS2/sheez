pragma Singleton

import QtQuick
import Quickshell
import qs.shared
import "compositors"

Singleton {
    id: root

    signal workspacesUpdated(var workspaces)
    signal windowUpdated(var windowInfo)
    signal error(string message)

    property string detectedCompositor: ""
    property var activeService: null

    property var niriService: NiriService {
        onWorkspacesUpdated: workspaces => root.workspacesUpdated(workspaces)
        onWindowUpdated: windowInfo => root.windowUpdated(windowInfo)
        onError: message => root.error(`NiriService: ${message}`)
    }

    property var mangoService: MangoService {
        onWorkspacesUpdated: workspaces => root.workspacesUpdated(workspaces)
        onWindowUpdated: windowInfo => root.windowUpdated(windowInfo)
        onError: message => root.error(`MangoService: ${message}`)
    }

    property var hyprlandService: HyprlandService {
        onWorkspacesUpdated: workspaces => root.workspacesUpdated(workspaces)
        onWindowUpdated: windowInfo => root.windowUpdated(windowInfo)
        onError: message => root.error(`HyprlandService: ${message}`)
    }

    Component.onCompleted: activate()

    function activate() {
        const compositor = detectCompositor();
        detectedCompositor = compositor;

        const services = {
            "niri": niriService,
            "hyprland": hyprlandService,
            "mango": mangoService
        };

        activeService = services[compositor];

        if (!activeService) {
            error(`No supported compositor detected (tried: ${Object.keys(services).join(", ")})`);
            return;
        }

        Logger.info("CompositorService", `Using {0} service`, compositor);
        activeService.activate();
    }

    function switchToWorkspace(workspaceId) {
        if (activeService) {
            activeService.switchToWorkspace(workspaceId);
        } else {
            error("No active compositor service");
        }
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
            },
            {
                name: "mango",
                service: mangoService
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

        Logger.error("CompositorService", "Could not detect any compositor");
        return "";
    }
}

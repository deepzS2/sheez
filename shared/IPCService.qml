import QtQuick
import Quickshell.Io
import qs.shared

Item {
    id: root

    IpcHandler {
        target: "logout"

        function toggle() {
            Logger.debug("IPCService", "IPC Handler logout toggle");

            PanelService.toggleLogoutMenu();
        }
    }

    IpcHandler {
        target: "lockScreen"

        function toggle() {
            Logger.debug("IPCService", "IPC Handler lockScreen toggle");

            PanelService.toggleLockScreen();
        }
    }

    IpcHandler {
        target: "notifications"

        function toggle(): void {
            Logger.debug("IPCService", "IPC Handler notifications toggle");

            PanelService.toggleNotificationPanel();
        }
    }
}

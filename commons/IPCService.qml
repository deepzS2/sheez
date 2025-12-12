import QtQuick
import Quickshell.Io
import qs.commons

Item {
    id: root

    IpcHandler {
        target: "logout"

        function toggle() {
            Logger.debug("IPCService", "IPC Handler logout toggle");

            PanelService.toggleLogoutMenu();
        }
    }
}

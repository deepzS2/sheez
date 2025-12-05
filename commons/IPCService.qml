import QtQuick
import Quickshell.Io
import qs.commons
import qs.modules.logoutmenu.services

Item {
    id: root

    IpcHandler {
        target: "logout"

        function toggle() {
            Logger.debug("IPCService", "IPC Handler logout toggle");

            if (LogoutMenuService.logoutMenuEl) {
                LogoutMenuService.logoutMenuEl.isVisible = !LogoutMenuService.logoutMenuEl.isVisible;
            }
        }
    }
}

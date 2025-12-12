pragma Singleton

import Quickshell

Singleton {
    id: root

    property var logoutMenuEl: null

    function toggleLogoutMenu() {
        root.logoutMenuEl.isVisible = !root.logoutMenuEl.isVisible;
    }
}

pragma Singleton

import Quickshell

Singleton {
    id: root

    property var logoutMenuEl: null
    property var lockScreenEl: null

    function toggleLogoutMenu() {
        root.logoutMenuEl.isVisible = !root.logoutMenuEl.isVisible;
    }

    function toggleLockScreen() {
        root.lockScreenEl.active = !root.lockScreenEl.active;
    }
}

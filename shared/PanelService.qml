pragma Singleton

import Quickshell

Singleton {
    id: root

    property var logoutMenuEl: null
    property var lockScreenEl: null
    property var notificationPanelEl: null

    function toggleLogoutMenu() {
        root.logoutMenuEl.isVisible = !root.logoutMenuEl.isVisible;
    }

    function toggleLockScreen() {
        root.lockScreenEl.active = !root.lockScreenEl.active;
    }

    function toggleNotificationPanel() {
        root.notificationPanelEl.visible = !root.notificationPanelEl.visible;
    }
}

pragma Singleton

import Quickshell

Singleton {
    id: root

    property bool logoutOpen: false
    property bool lockOpen: false
    property bool notificationsOpen: false

    function toggleLogoutMenu(): void {
        root.logoutOpen = !root.logoutOpen;
    }

    function toggleLockScreen(): void {
        root.lockOpen = !root.lockOpen;
    }

    function toggleNotificationPanel(): void {
        root.notificationsOpen = !root.notificationsOpen;
    }
}

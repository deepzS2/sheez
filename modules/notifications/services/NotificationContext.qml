pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import qs.shared

Singleton {
    id: root

    property list<var> history: []
    property alias trackedNotifications: server.trackedNotifications

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;

            root.history.push({
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            });

            Logger.infof("NotificationContext", "Notification received from {0}: {1}", n.appName || "unknown", n.summary || "(no summary)");
        }
    }

    function clearHistory(): void {
        Logger.info("NotificationContext", "Clearing notification history");
        history = [];
        PanelService.toggleNotificationPanel();
    }

    function removeFromHistory(index: int): void {
        Logger.debugf("NotificationContext", "Removing notification at index {0}", index);
        history.splice(index, 1);
    }
}

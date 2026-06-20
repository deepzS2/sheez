pragma ComponentBehavior: Bound

import Quickshell
import "widgets"
import "services"

Scope {
    id: root

    NotificationPanel {
        trackedNotifications: NotificationContext.trackedNotifications
    }

    NotificationCenterPanel {
        history: NotificationContext.history
        onClearHistory: NotificationContext.clearHistory()
        onRemoveItem: index => {
            NotificationContext.removeFromHistory(index);
        }
    }
}

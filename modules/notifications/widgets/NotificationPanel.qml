pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.shared

PanelWindow {
    id: root

    required property var trackedNotifications

    anchors {
        top: true
        right: true
    }

    margins {
        top: Styles.barHeight + 8
        right: 12
    }

    implicitWidth: Styles.notificationCenterWidth
    implicitHeight: Math.min(Styles.notificationCenterHeight, Math.max(1, column.implicitHeight))
    color: "transparent"

    exclusionMode: ExclusionMode.Ignore

    ColumnLayout {
        id: column
        width: parent.width
        spacing: 10

        Repeater {
            model: root.trackedNotifications
            delegate: NotificationItem {}
        }
    }

    Component.onCompleted: {
        Logger.debug("NotificationPanel", "Panel initialized");
    }
}

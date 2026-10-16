pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.shared
import qs.modules.lockscreen.services
import qs.modules.lockscreen.widgets

Scope {
    id: root

    LockContext {
        id: lockContext

        onUnlocked: {
            PanelService.lockOpen = false;
        }
    }

    WlSessionLock {
        id: lock

        locked: PanelService.lockOpen

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }
}

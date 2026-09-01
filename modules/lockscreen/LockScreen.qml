pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland
import qs.shared
import qs.modules.lockscreen.services
import qs.modules.lockscreen.widgets

Loader {
    id: root
    active: PanelService.lockOpen

    sourceComponent: Item {
        LockContext {
            id: lockContext

            onUnlocked: {
                lock.locked = false;
                PanelService.lockOpen = false;
            }
        }

        WlSessionLock {
            id: lock

            locked: true

            WlSessionLockSurface {
                LockSurface {
                    anchors.fill: parent
                    context: lockContext
                }
            }
        }
    }
}

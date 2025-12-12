pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Wayland
import qs.commons
import qs.modules.lockscreen.services
import qs.modules.lockscreen.widgets

Loader {
    id: root
    active: false

    Component.onCompleted: {
        PanelService.lockScreenEl = this;
    }

    sourceComponent: Item {
        // This stores all the information shared between the lock surfaces on each screen.
        LockContext {
            id: lockContext

            onUnlocked: {
                // Unlock the screen before exiting, or the compositor will display a
                // fallback lock you can't interact with.
                lock.locked = false;
                root.active = false;
            }
        }

        WlSessionLock {
            id: lock

            // Lock the session immediately when quickshell starts.
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

import Quickshell
import "modules/bar"
import "modules/logoutmenu"
import "modules/lockscreen"
import "modules/reload-popup"
import "modules/notifications"
import "shared"

ShellRoot {
    settings.watchFiles: true

    ReloadPopup {}

    Bar {}

    LogoutMenu {}

    LockScreen {}

    IPCService {}

    NotificationCenter {}
}

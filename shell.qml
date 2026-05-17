import Quickshell
import "modules/bar"
import "modules/logoutmenu"
import "modules/lockscreen"
import "modules/reload-popup"
import "shared"

Scope {
    ReloadPopup {}

    Bar {}

    LogoutMenu {}

    LockScreen {}

    IPCService {}
}

import Quickshell
import qs.commons
import "modules"
import "modules/bar"
import "modules/logoutmenu"
import "modules/lockscreen"

Scope {
    ReloadPopup {}

    Bar {}

    LogoutMenu {}

    LockScreen {}

    IPCService {}
}

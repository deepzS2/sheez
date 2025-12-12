import QtQuick
import Quickshell
import Quickshell.Services.Pam
import qs.commons

Scope {
    id: root
    signal unlocked
    signal failed

    // These properties are in the context and not individual lock surfaces
    // so all surfaces can share the same state.
    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false
    property bool showRateLimit: false
    property int failedAttempts: 0
    property bool rateLimited: false

    // Clear the failure text once the user starts typing.
    onCurrentTextChanged: {
        showFailure = false;
        showRateLimit = false;
    }

    Timer {
        id: cooldownTimer
        interval: 30000  // 30 seconds
        onTriggered: {
            root.failedAttempts = 0;
            root.rateLimited = false;
        }
    }

    function tryUnlock() {
        if (currentText === "" || rateLimited)
            return;

        root.unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam

        // Its best to have a custom pam config for quickshell, as the system one
        // might not be what your interface expects, and break in some way.
        // This particular example only supports passwords.
        configDirectory: Quickshell.shellPath("assets")
        config: "password.conf"

        // pam_unix will ask for a response for the password prompt
        onPamMessage: {
            if (this.responseRequired) {
                this.respond(root.currentText);
            }
        }

        // pam_unix won't send any important messages so all we need is the completion status.
        onCompleted: result => {
            if (result == PamResult.Success) {
                root.unlockInProgress = false;
                return root.unlocked();
            }

            root.currentText = "";
            root.failedAttempts++;

            if (root.failedAttempts >= 5) {
                root.rateLimited = true;
                root.showRateLimit = true;
                cooldownTimer.start();
            } else {
                root.showFailure = true;
            }

            Logger.error("LockContext", "PAM authentication failed");

            root.unlockInProgress = false;
        }
    }
}

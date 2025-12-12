import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import QtQuick.Effects
import qs.commons
import qs.modules.lockscreen.services

Item {
    id: root

    required property LockContext context

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Image {
        id: lockBgImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        source: Colors.imagePath
        cache: true
        smooth: true
        mipmap: false
        antialiasing: true
    }

    MultiEffect {
        source: lockBgImage
        anchors.fill: lockBgImage
        autoPaddingEnabled: false
        brightness: -0.183
        contrast: -0.108
        blurEnabled: true
        blurMax: 64
        blur: 1.0
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16

        Text {
            Layout.alignment: Qt.AlignCenter
            Layout.maximumHeight: lineHeight - lineHeight * 0.1
            renderType: Text.NativeRendering
            text: clock.hours >= 10 ? clock.hours : clock.hours.toString().padStart(2, '0')
            color: Colors.primary
            lineHeight: 260
            lineHeightMode: Text.FixedHeight

            font {
                pixelSize: 300
                family: "AlfaSlabOne"
                weight: Font.ExtraBold
            }
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            Layout.maximumHeight: lineHeight - lineHeight * 0.1
            Layout.bottomMargin: 80
            renderType: Text.NativeRendering
            text: clock.minutes >= 10 ? clock.minutes : clock.minutes.toString().padStart(2, '0')
            color: Colors.conSurface
            lineHeight: 260
            lineHeightMode: Text.FixedHeight

            font {
                pixelSize: 300
                family: "AlfaSlabOne"
                weight: Font.ExtraBold
                bold: true
            }
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            renderType: Text.NativeRendering
            textFormat: Text.RichText
            text: {
                const weekDay = Qt.formatDate(clock.date, "dddd");
                const currentDate = Qt.formatDate(clock.date, "d MMMM");

                return `<span style="color: '${Colors.conSurface}'; font-weight: 700">${weekDay},</span> <span style="color: '${Colors.primary}'; font-weight: 700">${currentDate}</span>`;
            }

            font {
                pointSize: 23
                family: "Atkinson Hyperlegible Next"
            }
        }

        Text {
            Layout.alignment: Qt.AlignCenter
            color: Colors.conSurface
            renderType: Text.NativeRendering
            text: ""

            font {
                pointSize: 75
                family: "JetBrainsMono Nerd Font"
                weight: Font.Bold
            }
        }

        TextField {
            id: passwordBox
            Layout.alignment: Qt.AlignCenter
            implicitWidth: 250
            implicitHeight: 60
            placeholderText: "Hi, " + Quickshell.env("USER")
            placeholderTextColor: Qt.alpha(Colors.conSurface, 0.6)
            focus: true
            enabled: !root.context.unlockInProgress
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData
            color: Colors.conSurface
            padding: 16

            font {
                family: "Atkinson Hyperlegible Next"
                pointSize: 12
                weight: Font.Bold
            }

            background: Rectangle {
                color: Qt.alpha(Colors.surfaceContainer, 0.5)
                radius: 50
                border.color: "transparent"
                border.width: 2
            }

            // Update the text in the context when the text in the box changes.
            onTextChanged: root.context.currentText = this.text

            // Try to unlock when enter is pressed.
            onAccepted: root.context.tryUnlock()

            // Update the text in the box to match the text in the context.
            // This makes sure multiple monitors have the same text.
            Connections {
                target: root.context

                function onCurrentTextChanged() {
                    passwordBox.text = root.context.currentText;
                }
            }
        }

        Label {
            Layout.alignment: Qt.AlignCenter
            visible: root.context.showFailure || root.context.showRateLimit
            text: root.context.showRateLimit ? "Too many failed attempts. Try again in 30 seconds." : "Incorrect password"
            color: Colors.error
            font {
                family: "Atkinson Hyperlegible Next"
                pointSize: 12
            }
        }
    }
}

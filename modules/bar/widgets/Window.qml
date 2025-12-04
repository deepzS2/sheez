pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.commons
import qs.widgets
import qs.modules.bar.services

Rectangle {
    id: root

    // Layout properties
    implicitWidth: windowLayout.implicitWidth + Styles.widgetPadding * 2
    implicitHeight: Styles.capsuleHeight
    radius: Styles.widgetRadius
    color: Colors.surface
    opacity: Styles.widgetOpacity

    // Border styling
    border {
        width: Styles.widgetBorderWidth
        color: Colors.outlineVariant
    }

    // Shadow effect
    DropShadow {
        anchors.fill: parent
        source: root
    }

    // Current window info
    property var currentWindow: null
    property string displayText: ""
    property string fullTitle: ""
    property color textColor: Colors.conSurface
    property string iconSource: ""
    property bool hasSystemIcon: false

    Connections {
        target: CompositorService

        function onWindowUpdated(windowInfo) {
            root.updateWindow(windowInfo);
        }

        function onError(message, error) {
            Logger.errorf("Window", `CompositorService error: {0}\n{1}`, message, error);
        }
    }

    RowLayout {
        id: windowLayout
        anchors.centerIn: parent
        spacing: 8

        IconImage {
            id: windowIcon
            source: root.iconSource
            implicitWidth: 18
            implicitHeight: 18
            visible: root.hasSystemIcon

            Layout.alignment: Qt.AlignTop
        }

        Text {
            id: windowText
            text: root.displayText
            font: Styles.systemFont
            color: root.textColor
            elide: Text.ElideRight
            maximumLineCount: 1

            Layout.alignment: Qt.AlignBottom
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            TooltipService.show(root.fullTitle, root, {
                alignment: "center"
            });
        }
        onExited: {
            TooltipService.hide();
        }
    }

    // Component lifecycle
    Component.onCompleted: {
        Logger.info("Window", "Initializing window widget");
        CompositorService.activate();
    }

    Component.onDestruction: {
        Logger.info("Window", "Cleaning up window widget");
        CompositorService.deactivate();
    }

    function updateWindow(windowInfo) {
        root.currentWindow = windowInfo;

        const hasWindow = windowInfo && windowInfo.title;
        const rawTitle = hasWindow ? windowInfo.title : "";
        const appId = hasWindow ? windowInfo.appId : "";

        // Process title and icon using functional helpers
        const processedTitle = processTitle(rawTitle);
        const iconResult = resolveIcon(appId, rawTitle);

        // Update properties based on window state
        if (hasWindow) {
            root.fullTitle = rawTitle;
            root.iconSource = iconResult.iconSource;
            root.hasSystemIcon = iconResult.hasSystemIcon;
            root.displayText = iconResult.hasSystemIcon ? processedTitle : `${iconResult.iconChar} ${processedTitle}`;
        } else {
            // No active window fallback
            root.fullTitle = "";
            root.iconSource = "";
            root.hasSystemIcon = false;
            root.displayText = "";
        }
    }

    function processTitle(rawTitle) {
        if (!rawTitle)
        return "";

        const len = rawTitle.length;
        if (len > 40)
        return rawTitle.substring(0, 37) + "...";
        if (len < 5)
        return rawTitle.padEnd(5, " ");
        return rawTitle;
    }

    function resolveIcon(appId, rawTitle) {
        // Try system icon first
        const entry = DesktopEntries.byId(appId) || DesktopEntries.heuristicLookup(appId);

        if (entry && entry.icon) {
            const iconPath = Quickshell.iconPath(entry.icon);
            if (iconPath) {
                return {
                    iconSource: iconPath,
                    hasSystemIcon: true,
                    iconChar: ""
                };
            }
        }

        // Fallback to text icon
        return {
            iconSource: "",
            hasSystemIcon: false,
            iconChar: getFallbackIcon(appId, rawTitle)
        };
    }

    function getFallbackIcon() {
        return "";
    }
}

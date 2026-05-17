pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root

    componentName: "Window"
    tooltipText: root.fullTitle
    implicitWidth: windowLayout.implicitWidth + Styles.widgetPadding * 2

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

    Component.onCompleted: {
        CompositorService.activate();
    }

    Component.onDestruction: {
        CompositorService.deactivate();
    }

    function updateWindow(windowInfo) {
        root.currentWindow = windowInfo;

        const hasWindow = windowInfo && windowInfo.title;
        const rawTitle = hasWindow ? windowInfo.title : "";
        const appId = hasWindow ? windowInfo.appId : "";

        const processedTitle = processTitle(rawTitle);
        const iconResult = resolveIcon(appId, rawTitle);

        if (hasWindow) {
            root.fullTitle = rawTitle;
            root.iconSource = iconResult.iconSource;
            root.hasSystemIcon = iconResult.hasSystemIcon;
            root.displayText = iconResult.hasSystemIcon ? processedTitle : `${iconResult.iconChar} ${processedTitle}`;
        } else {
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
        return {
            iconSource: "",
            hasSystemIcon: false,
            iconChar: ""
        };
    }
}

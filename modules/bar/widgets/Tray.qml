pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.shared
import qs.components
import qs.modules.bar.services

BarWidget {
    id: root
    componentName: "Tray"

    readonly property list<SystemTrayItem> trayItems: SystemTray.items.values
    implicitWidth: trayRow.implicitWidth + Styles.widgetPadding * 2
    visible: trayItems.length > 0

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: Styles.widgetSpacing * 1.5

        Repeater {
            model: root.trayItems

            delegate: Item {
                id: trayEntry

                required property SystemTrayItem modelData
                readonly property string tooltipText: {
                    const description = modelData.tooltipDescription;
                    return modelData.tooltipTitle + (description ? `\n${description}` : "");
                }

                width: trayIcon.width
                height: trayIcon.height

                IconImage {
                    id: trayIcon
                    source: trayEntry.modelData.icon
                    implicitWidth: 16
                    implicitHeight: 16
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton)
                            trayEntry.modelData.activate();
                        else if (mouse.button === Qt.MiddleButton)
                            trayEntry.modelData.secondaryActivate();
                        else if (mouse.button === Qt.RightButton) {
                            const pos = trayEntry.mapToItem(null, mouse.x, mouse.y);
                            trayEntry.modelData.display(QsWindow.window, pos.x, pos.y);
                        }
                    }
                }

                WheelHandler {
                    onWheel: wheel => trayEntry.modelData.scroll(wheel.angleDelta.y / 120, false)
                }

                HoverHandler {
                    id: hoverHandler

                    onHoveredChanged: {
                        if (!trayEntry.tooltipText || !tooltipLoader.item)
                            return;

                        if (hovered)
                            tooltipLoader.item.show();
                        else
                            tooltipLoader.item.hide();
                    }
                }

                Loader {
                    id: tooltipLoader
                    active: trayEntry.tooltipText !== ""
                    asynchronous: true

                    sourceComponent: Tooltip {
                        target: trayEntry
                        text: trayEntry.tooltipText
                        position: "bottom-center"
                    }
                }
            }
        }
    }
}

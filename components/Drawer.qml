pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.shared

Item {
    id: root

    default property alias children: content.children
    property int direction: Qt.LeftToRight
    property bool expanded: false
    property int animationDuration: 500

    implicitWidth: content.children.length > 0 ? content.children[0].implicitWidth : 0
    implicitHeight: Styles.capsuleHeight
    clip: true

    RowLayout {
        id: content
        layoutDirection: root.direction
        anchors.fill: parent
        spacing: Styles.widgetSpacing
    }

    states: [
        State {
            name: "expanded"
            when: root.expanded
            PropertyChanges {
                root.implicitWidth: content.implicitWidth
            }
        }
    ]

    transitions: [
        Transition {
            from: ""
            to: "expanded"
            reversible: true
            NumberAnimation {
                property: "implicitWidth"
                duration: root.animationDuration
                easing.type: Easing.InOutQuad
            }
        }
    ]

    HoverHandler {
        onHoveredChanged: root.expanded = hovered
    }

    Component.onCompleted: {
        Logger.info("Drawer", "Drawer component initialized");
    }
}

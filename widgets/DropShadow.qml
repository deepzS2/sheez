pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import qs.commons

// Unified shadow system
Item {
    id: root

    required property var source

    property bool autoPaddingEnabled: false

    layer.effect: MultiEffect {
        source: root.source
        shadowEnabled: true
        // blurMax: Styles.shadowBlurMax
        // shadowBlur: Style.shadowBlur
        shadowOpacity: Styles.widgetShadowOpacity
        shadowColor: "black"
        shadowHorizontalOffset: Styles.widgetShadowOffset
        shadowVerticalOffset: Styles.widgetShadowOffset
        autoPaddingEnabled: root.autoPaddingEnabled
    }
}

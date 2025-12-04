pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    readonly property int transitionDuration: 300

    FileView {
        id: colorFile
        // For compatibility with other quickshell paths
        path: `${Quickshell.env("HOME")}/.config/sheez/colors.json`
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        // qmllint disable unresolved-type
        JsonAdapter {
            // Default colors (fallback if JSON file doesn't exist)
            property string primary: "#9dcbfc"
            property string conPrimary: "#003355"
            property string primaryContainer: "#134a74"
            property string conPrimaryContainer: "#cfe4ff"
            property string inversePrimary: "#32628d"
            property string primaryFixed: "#cfe4ff"
            property string primaryFixedDim: "#9dcbfc"
            property string conPrimaryFixed: "#001d34"
            property string conPrimaryFixedVariant: "#134a74"
            property string secondary: "#bac8da"
            property string conSecondary: "#243240"
            property string secondaryContainer: "#3a4857"
            property string conSecondaryContainer: "#d6e4f7"
            property string secondaryFixed: "#d6e4f7"
            property string secondaryFixedDim: "#bac8da"
            property string conSecondaryFixed: "#0f1d2a"
            property string conSecondaryFixedVariant: "#3a4857"
            property string tertiary: "#d5bee5"
            property string conTertiary: "#3a2a49"
            property string tertiaryContainer: "#514060"
            property string conTertiaryContainer: "#f0dbff"
            property string tertiaryFixed: "#f0dbff"
            property string tertiaryFixedDim: "#d5bee5"
            property string conTertiaryFixed: "#241532"
            property string conTertiaryFixedVariant: "#514060"
            property string error: "#ffb4ab"
            property string conError: "#690005"
            property string errorContainer: "#93000a"
            property string conErrorContainer: "#ffdad6"
            property string surface: "#101418"
            property string surfaceDim: "#101418"
            property string surfaceBright: "#36393e"
            property string surfaceContainerLowest: "#0b0e12"
            property string surfaceContainerLow: "#191c20"
            property string surfaceContainer: "#1d2024"
            property string surfaceContainerHigh: "#272a2f"
            property string surfaceContainerHighest: "#32353a"
            property string conSurface: "#e0e2e8"
            property string conSurfaceVariant: "#c2c7cf"
            property string surfaceVariant: "#42474e"
            property string inverseSurface: "#e0e2e8"
            property string inverseOnSurface: "#2d3135"
            property string background: "#101418"
            property string conBackground: "#e0e2e8"
            property string outline: "#8c9199"
            property string outlineVariant: "#42474e"
            property string shadow: "#000000"
            property string scrim: "#000000"
            property string sourceColor: "#404e5e"
        }
    }

    // Expose animated colors to consumers
    readonly property color primary: colorFile.adapter.primary
    readonly property color conPrimary: colorFile.adapter.conPrimary
    readonly property color primaryContainer: colorFile.adapter.primaryContainer
    readonly property color conPrimaryContainer: colorFile.adapter.conPrimaryContainer
    readonly property color inversePrimary: colorFile.adapter.inversePrimary
    readonly property color primaryFixed: colorFile.adapter.primaryFixed
    readonly property color primaryFixedDim: colorFile.adapter.primaryFixedDim
    readonly property color conPrimaryFixed: colorFile.adapter.conPrimaryFixed
    readonly property color conPrimaryFixedVariant: colorFile.adapter.conPrimaryFixedVariant
    readonly property color secondary: colorFile.adapter.secondary
    readonly property color conSecondary: colorFile.adapter.conSecondary
    readonly property color secondaryContainer: colorFile.adapter.secondaryContainer
    readonly property color conSecondaryContainer: colorFile.adapter.conSecondaryContainer
    readonly property color secondaryFixed: colorFile.adapter.secondaryFixed
    readonly property color secondaryFixedDim: colorFile.adapter.secondaryFixedDim
    readonly property color conSecondaryFixed: colorFile.adapter.conSecondaryFixed
    readonly property color conSecondaryFixedVariant: colorFile.adapter.conSecondaryFixedVariant
    readonly property color tertiary: colorFile.adapter.tertiary
    readonly property color conTertiary: colorFile.adapter.conTertiary
    readonly property color tertiaryContainer: colorFile.adapter.tertiaryContainer
    readonly property color conTertiaryContainer: colorFile.adapter.conTertiaryContainer
    readonly property color tertiaryFixed: colorFile.adapter.tertiaryFixed
    readonly property color tertiaryFixedDim: colorFile.adapter.tertiaryFixedDim
    readonly property color conTertiaryFixed: colorFile.adapter.conTertiaryFixed
    readonly property color conTertiaryFixedVariant: colorFile.adapter.conTertiaryFixedVariant
    readonly property color error: colorFile.adapter.error
    readonly property color conError: colorFile.adapter.conError
    readonly property color errorContainer: colorFile.adapter.errorContainer
    readonly property color conErrorContainer: colorFile.adapter.conErrorContainer
    readonly property color surface: colorFile.adapter.surface
    readonly property color surfaceDim: colorFile.adapter.surfaceDim
    readonly property color surfaceBright: colorFile.adapter.surfaceBright
    readonly property color surfaceContainerLowest: colorFile.adapter.surfaceContainerLowest
    readonly property color surfaceContainerLow: colorFile.adapter.surfaceContainerLow
    readonly property color surfaceContainer: colorFile.adapter.surfaceContainer
    readonly property color surfaceContainerHigh: colorFile.adapter.surfaceContainerHigh
    readonly property color surfaceContainerHighest: colorFile.adapter.surfaceContainerHighest
    readonly property color conSurface: colorFile.adapter.conSurface
    readonly property color conSurfaceVariant: colorFile.adapter.conSurfaceVariant
    readonly property color surfaceVariant: colorFile.adapter.surfaceVariant
    readonly property color inverseSurface: colorFile.adapter.inverseSurface
    readonly property color inverseOnSurface: colorFile.adapter.inverseOnSurface
    readonly property color background: colorFile.adapter.background
    readonly property color conBackground: colorFile.adapter.conBackground
    readonly property color outline: colorFile.adapter.outline
    readonly property color outlineVariant: colorFile.adapter.outlineVariant
    readonly property color shadow: colorFile.adapter.shadow
    readonly property color scrim: colorFile.adapter.scrim
    readonly property color sourceColor: colorFile.adapter.sourceColor
}

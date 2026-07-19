pragma Singleton
import QtQuick

QtObject {
    // Cyberpunk Color Palette
    readonly property color backgroundDeepSpace: "#0B0C10"
    readonly property color accentCyan: "#66FCF1"
    readonly property color warningRed: "#FF3B30"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#C5C6C7"
    readonly property color glassPanelBase: "#40151D26"
    readonly property color glassPanelBorder: "#802A3B4C"
    readonly property color glassEdge: "#26FFFFFF"
    readonly property color trackInactive: "#40FFFFFF"
    readonly property color textOnAccent: "#0B0C10"
    readonly property color tickLitMajor: "#FFB3CC"
    readonly property color tickLitMinor: "#FFFFFF"
    readonly property color tickDimMajor: "#2A3B4C"
    readonly property color tickDimMinor: "#151D26"
    readonly property color coverFallback1: "#FF0055"
    readonly property color coverFallback2: "#4A00E0"

    // Animation Timings
    readonly property int durationPress: 100
    readonly property int durationFast: 150
    readonly property int durationTick: 150
    readonly property int durationGauge: 250
    readonly property int durationNormal: 300
    readonly property int durationSlow: 600
    readonly property int durationSpin: 900
    readonly property int durationCover: 8000

    // Radii
    readonly property real radiusSm: 8
    readonly property real radiusMd: 16
    readonly property real radiusLg: 22
    readonly property real radiusPill: 32

    // Typography setup
    readonly property string fontMain: "Inter, Roboto, sans-serif"
    readonly property string fontDisplay: "Orbitron, Roboto, sans-serif"
    readonly property real textXs: 12
    readonly property real textSm: 16
    readonly property real textMd: 18
    readonly property real textLg: 20
    readonly property real textXl: 22
    readonly property real displayMd: 90
    readonly property real displayLg: 100

    // Spacing
    readonly property real spaceXs: 4
    readonly property real spaceSm: 6
    readonly property real spaceMd: 8
    readonly property real spaceLg: 10
    readonly property real spaceXl: 24
    readonly property real spaceXXl: 40

    // Bezel Geometry
    readonly property real bezelMargin: 20
    readonly property real dashboardMargin: 10
    readonly property real panelLift: -30
    readonly property real gaugeInsetLeft: 260
    readonly property real gaugeInsetRight: 880
}

pragma Singleton
import QtQuick

QtObject {
    // Cyberpunk Color Palette
    readonly property color backgroundDeepSpace: "#0B0C10"
    readonly property color accentCyan: "#66FCF1"
    readonly property color warningRed: "#FF3B30"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#C5C6C7"
    readonly property color textOnAccent: "#0B0C10"
    
    readonly property color glassPanelBase: "#40151D26"
    readonly property color glassPanelBorder: "#802A3B4C"
    readonly property color trackInactive: "#40FFFFFF"
    
    readonly property color tickLitMajor: "#FFB3CC"
    readonly property color tickLitMinor: "#FFFFFF"
    readonly property color tickDimMajor: "#2A3B4C"
    readonly property color tickDimMinor: "#151D26"
    
    readonly property color coverFallback1: "#FF0055"
    readonly property color coverFallback2: "#4A00E0"
    readonly property color glassEdge: Qt.rgba(1.0, 1.0, 1.0, 0.15)

    // Animation Timings
    readonly property int durationFast: 150
    readonly property int durationNormal: 300
    readonly property int durationSlow: 600
    readonly property int durationSpin: 900
    readonly property int durationCover: 8000
    readonly property int durationPress: 100
    readonly property int durationTick: 150
    readonly property int durationGauge: 250

    // Radii
    readonly property int radiusSm: 8
    readonly property int radiusMd: 16
    readonly property int radiusLg: 22
    readonly property int radiusPill: 32

    // Typography setup
    readonly property string fontMain: "Inter, Roboto, sans-serif"
    readonly property string fontDisplay: "Orbitron, Roboto, sans-serif"
    readonly property int textXs: 12
    readonly property int textSm: 16
    readonly property int textMd: 18
    readonly property int textLg: 20
    readonly property int textXl: 22
    readonly property int displayMd: 90
    readonly property int displayLg: 100

    // Spacing
    readonly property int spaceXs: 4
    readonly property int spaceSm: 6
    readonly property int spaceMd: 8
    readonly property int spaceLg: 10
    readonly property int spaceXl: 24
    readonly property int spaceXXl: 40

    // Bezel Geometry
    readonly property real bezelMargin: 20
    readonly property real dashboardMargin: 10
    readonly property real panelLift: 30
    readonly property real gaugeInsetLeft: 260
    readonly property real gaugeInsetRight: 880
}

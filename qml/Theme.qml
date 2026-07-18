pragma Singleton
import QtQuick

QtObject {
    // Cyberpunk Color Palette
    readonly property color backgroundDeepSpace: "#0B0C10"
    readonly property color backgroundCharcoal: "#1F2833"
    readonly property color accentCyan: "#66FCF1"
    readonly property color warningRed: "#FF3B30"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#C5C6C7"

    // Animation Timings
    readonly property int durationFast: 150
    readonly property int durationNormal: 300
    readonly property int durationSlow: 600

    // Typography setup
    // Using a system font as fallback, styled to look modern
    readonly property string fontMain: "Inter, Roboto, sans-serif"
    readonly property string fontDisplay: "Orbitron, Roboto, sans-serif"
}

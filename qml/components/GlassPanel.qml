import QtQuick
import com.showcase

Rectangle {
    id: root
    radius: 16
    color: Qt.rgba(0.11, 0.14, 0.18, 0.6) // Semi-transparent tinted background
    border.width: 1
    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.05) // Subtle outer white rim
    
    // Diagonal glass reflection gradient
    gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.rgba(1.0, 1.0, 1.0, 0.08) }
        GradientStop { position: 0.4; color: "transparent" }
        GradientStop { position: 1.0; color: Qt.rgba(Theme.accentCyan.r, Theme.accentCyan.g, Theme.accentCyan.b, 0.05) }
    }

    // Inner glow / shadow effect for glassmorphism feel
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        radius: 15
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(Theme.accentCyan.r, Theme.accentCyan.g, Theme.accentCyan.b, 0.2)
    }
}

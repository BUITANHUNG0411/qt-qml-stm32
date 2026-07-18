import QtQuick
import com.showcase

Rectangle {
    id: root
    color: Theme.backgroundCharcoal
    radius: 16
    border.width: 1
    border.color: Theme.accentCyan
    opacity: 0.9

    // Inner glow / shadow effect for glassmorphism feel
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        radius: 14
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(Theme.accentCyan.r, Theme.accentCyan.g, Theme.accentCyan.b, 0.3)
    }
}

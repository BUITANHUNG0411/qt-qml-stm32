import QtQuick
import com.showcase

Row {
    id: root
    property real value: 0
    property real maxValue: 100
    property int blockCount: 20
    property color activeColor: Theme.accentCyan
    property color warningColor: Theme.warningRed
    property real warningThreshold: 20
    property bool invertWarning: false // If true, warns when value > threshold
    
    spacing: Theme.spaceXs
    Repeater {
        model: root.blockCount
        Rectangle {
            width: Theme.spaceMd; height: Theme.spaceMd; radius: Theme.radiusSm / 4
            property bool isActive: index < (root.value / (root.maxValue / root.blockCount))
            property bool isWarnState: root.invertWarning ? (root.value > root.warningThreshold) : (root.value < root.warningThreshold)
            color: isActive ? (isWarnState ? root.warningColor : root.activeColor) : Theme.textSecondary
            opacity: isActive ? 1.0 : 0.3
        }
    }
}

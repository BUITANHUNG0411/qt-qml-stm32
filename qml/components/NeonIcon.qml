import QtQuick
import QtQuick.Effects
import com.showcase

Item {
    id: root
    property string source
    property color colorizationColor: Theme.accentCyan
    
    Image {
        id: iconImg
        anchors.fill: parent
        source: root.source
        sourceSize: Qt.size(width, height)
        visible: false
    }
    MultiEffect {
        anchors.fill: iconImg
        source: iconImg
        colorization: 1.0
        colorizationColor: root.colorizationColor
        Behavior on colorizationColor { ColorAnimation { duration: Theme.durationFast } }
    }
}

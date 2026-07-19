import QtQuick
import QtQuick.Effects
import com.showcase

Item {
    id: root
    property string source
    property color colorizationColor: Theme.textPrimary
    property color activeColor: Theme.accentCyan
    property bool isToggle: false
    property bool isActive: false
    
    signal clicked()

    scale: mouseArea.pressed ? 0.9 : 1.0
    Behavior on scale { NumberAnimation { duration: Theme.durationPress } }
    
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
        colorizationColor: root.isToggle ? (root.isActive ? root.activeColor : root.colorizationColor) : (mouseArea.pressed ? root.activeColor : root.colorizationColor)
        Behavior on colorizationColor { ColorAnimation { duration: Theme.durationPress } }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}

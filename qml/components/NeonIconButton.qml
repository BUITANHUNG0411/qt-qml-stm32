import QtQuick
import QtQuick.Effects
import com.showcase

Item {
    id: root
    property alias source: iconImg.source
    property alias sourceSize: iconImg.sourceSize
    property color defaultColor: Theme.textPrimary
    property color pressedColor: Theme.accentCyan
    property bool isActive: false
    property color activeColor: Theme.accentCyan
    
    signal clicked()
    
    property color _currentColor: mouseArea.pressed ? pressedColor : (isActive ? activeColor : defaultColor)
    
    scale: mouseArea.pressed ? 0.9 : 1.0
    Behavior on scale { NumberAnimation { duration: Theme.durationPress } }
    
    Image {
        id: iconImg
        anchors.fill: parent
        visible: false
    }
    
    MultiEffect {
        anchors.fill: iconImg
        source: iconImg
        colorization: 1.0
        colorizationColor: root._currentColor
        Behavior on colorizationColor { ColorAnimation { duration: Theme.durationPress } }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}

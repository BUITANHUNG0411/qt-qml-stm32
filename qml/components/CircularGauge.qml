import QtQuick
import QtQuick.Shapes
import com.showcase

Item {
    id: root
    width: 300
    height: 300

    property real value: 0
    property real maxValue: 100
    property bool isWarning: false
    property color gaugeColor: Theme.accentCyan
    property color warningColor: Theme.warningRed

    // Configurable Needle and Ticks properties
    property bool showTicks: true
    property bool showNeedle: true
    property real tickStep: 10
    property real majorTickStep: 20

    property real sweepAngle: (value / maxValue) * 270 // Max 270 degrees sweep
    
    Behavior on sweepAngle {
        NumberAnimation { duration: Theme.durationNormal; easing.type: Easing.OutCubic }
    }

    // Tick Marks and Numbers
    Item {
        id: ticksContainer
        anchors.fill: parent
        visible: root.showTicks

        Repeater {
            model: root.maxValue > 0 && root.tickStep > 0 ? Math.floor(root.maxValue / root.tickStep) + 1 : 0
            
            Item {
                width: root.width
                height: root.height
                anchors.centerIn: parent
                // startAngle is 135. Total sweep is 270.
                rotation: 135 + (index * root.tickStep / root.maxValue) * 270

                Rectangle {
                    property bool isIlluminated: ((index * root.tickStep / root.maxValue) * 270) <= root.sweepAngle
                    width: (index * root.tickStep) % root.majorTickStep === 0 ? root.width * 0.04 : root.width * 0.02
                    height: isIlluminated ? 4 : 2
                    color: isIlluminated ? (root.isWarning ? root.warningColor : root.gaugeColor) : 
                           ((index * root.tickStep) % root.majorTickStep === 0 ? Theme.textPrimary : Theme.textSecondary)
                    x: root.width / 2 + (root.width / 2 - 30) - width
                    y: root.height / 2 - height / 2
                }

                // Tick labels (always keep upright)
                Text {
                    property bool isIlluminated: ((index * root.tickStep / root.maxValue) * 270) <= root.sweepAngle
                    visible: (index * root.tickStep) % root.majorTickStep === 0
                    text: (index * root.tickStep).toString()
                    color: isIlluminated ? Theme.textPrimary : Theme.textSecondary
                    font.family: Theme.fontMain
                    font.pixelSize: root.width * 0.045
                    
                    x: root.width / 2 + (root.width / 2 - 60) - width / 2
                    y: root.height / 2 - height / 2

                    // Inverse rotation to keep the text upright
                    rotation: -(135 + (index * root.tickStep / root.maxValue) * 270)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // Needle
    Item {
        anchors.fill: parent
        visible: root.showNeedle
        rotation: 135 + root.sweepAngle

        Shape {
            x: root.width / 2 + root.width * 0.15
            y: root.height / 2 - root.height * 0.015
            width: root.width / 2 - 35 - (root.width * 0.15)
            height: root.height * 0.03

            layer.enabled: true
            layer.samples: 4

            ShapePath {
                strokeWidth: 0
                strokeColor: "transparent"
                fillColor: root.isWarning ? root.warningColor : root.gaugeColor

                startX: 0; startY: 0
                PathLine { x: parent.width; y: parent.height * 0.4 }
                PathLine { x: parent.width; y: parent.height * 0.6 }
                PathLine { x: 0; y: parent.height }
            }
        }
    }

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4 // Anti-aliasing

        // Background Track
        ShapePath {
            strokeWidth: 6
            strokeColor: Qt.rgba(Theme.textSecondary.r, Theme.textSecondary.g, Theme.textSecondary.b, 0.15)
            fillColor: "transparent"
            capStyle: ShapePath.FlatCap
            
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - 20
                radiusY: root.height / 2 - 20
                startAngle: 135
                sweepAngle: 270
            }
        }

        // Foreground Active Track (Solid Sweep)
        ShapePath {
            strokeWidth: 4
            strokeColor: root.isWarning ? root.warningColor : root.gaugeColor
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - 20
                radiusY: root.height / 2 - 20
                startAngle: 135
                sweepAngle: root.sweepAngle
            }
        }
    }
}

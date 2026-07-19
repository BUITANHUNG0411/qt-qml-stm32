import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
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

    // Cấu hình số lượng vạch tick
    property int tickCount: 80 
    // Hiển thị vạch lớn (kèm số) mỗi N vạch
    property int majorTickInterval: 10 
    // Điểm bắt đầu vùng đỏ (Redline), nếu > 0 sẽ kích hoạt
    property real redlineValue: -1 

    // Giá trị hiển thị chạy mượt mà (trailing effect)
    property real displayedValue: value
    Behavior on displayedValue {
        NumberAnimation { duration: Theme.durationGauge; easing.type: Easing.OutQuad }
    }

    // Lớp 1: Ánh sáng nền (Ambient Backlight)
    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        
        ShapePath {
            strokeWidth: 0
            fillGradient: RadialGradient {
                centerX: root.width / 2; centerY: root.height / 2
                centerRadius: root.width / 2.2
                GradientStop { 
                    position: 0.0; 
                    color: root.isWarning ? Qt.rgba(root.warningColor.r, root.warningColor.g, root.warningColor.b, 0.2) : Qt.rgba(root.gaugeColor.r, root.gaugeColor.g, root.gaugeColor.b, 0.2) 
                }
                GradientStop { position: 1.0; color: "transparent" }
            }
            startX: 0; startY: 0
            PathLine { x: root.width; y: 0 }
            PathLine { x: root.width; y: root.height }
            PathLine { x: 0; y: root.height }
            PathLine { x: 0; y: 0 }
        }
    }

    // Lớp 2: Vùng chứa các vạch (Ticks Container)
    Item {
        id: tickLayer
        anchors.fill: parent
        
        Repeater {
            model: root.tickCount + 1
            
            Item {
                width: root.width
                height: root.height
                anchors.centerIn: parent
                // Góc quay từ 135 đến 135+270 độ
                rotation: 135 + (index / root.tickCount) * 270

                property real tickValue: (index / root.tickCount) * root.maxValue
                property int displayTickValue: tickValue + 0.5
                property bool isIlluminated: tickValue <= root.displayedValue
                property bool isMajor: index % root.majorTickInterval === 0
                property bool isRedline: root.redlineValue > 0 && tickValue >= root.redlineValue

                property real tickInset: Theme.spaceXXl + Theme.spaceLg

                Rectangle {
                    property color activeColor: parent.isRedline ? root.warningColor : (root.isWarning ? root.warningColor : root.gaugeColor)
                    
                    width: parent.isMajor ? root.width * 0.04 : root.width * 0.02
                    height: parent.isMajor ? 4 : 2
                    
                    color: parent.isIlluminated ? (parent.isRedline ? Theme.tickLitMajor : Theme.tickLitMinor) : 
                           (parent.isMajor ? Theme.tickDimMajor : Theme.tickDimMinor)
                    opacity: parent.isIlluminated ? 1.0 : (parent.isMajor ? 0.8 : 0.4)
                    
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 2 + tickInset - width
                    
                    Behavior on opacity { NumberAnimation { duration: Theme.durationTick } }
                    Behavior on color { ColorAnimation { duration: Theme.durationTick } }
                }

                // Chữ số nhãn
                Text {
                    visible: parent.isMajor
                    text: parent.displayTickValue
                    color: parent.isIlluminated ? Theme.textPrimary : Theme.textSecondary
                    font.family: Theme.fontMain
                    font.pixelSize: root.width * 0.045
                    opacity: parent.isIlluminated ? 1.0 : 0.4
                    
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.width / 2 + tickInset + Theme.spaceXXl - width / 2

                    // Giữ chữ luôn thẳng đứng
                    rotation: -(135 + (index / root.tickCount) * 270)
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    
                    Behavior on opacity { NumberAnimation { duration: Theme.durationTick } }
                }
            }
        }
    }
    
    // Lớp 3: Hiệu ứng Phát sáng (Neon Bloom)
    MultiEffect {
        anchors.fill: tickLayer
        source: tickLayer
        shadowEnabled: true
        shadowColor: root.isWarning ? root.warningColor : root.gaugeColor
        shadowBlur: 1.0 // Blur tối đa để tạo vệt sáng
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
    }
}

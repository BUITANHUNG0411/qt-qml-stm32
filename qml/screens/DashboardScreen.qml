import QtQuick
import QtQuick.Layouts
import com.showcase
import "../components"

Item {
    id: root
    anchors.fill: parent

    property var vm: VehicleStatus

    // Top Bar (Telltales)
    Row {
        id: topBar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 70
        spacing: 40

        // Mock Icons (Cyberpunk style)
        Rectangle { width: 30; height: 10; radius: 5; color: Theme.accentCyan; opacity: 0.5 }
        Rectangle { width: 30; height: 10; radius: 5; color: Theme.textSecondary; opacity: 0.2 }
        Rectangle { width: 30; height: 10; radius: 5; color: vm.isWarning ? Theme.warningRed : Theme.textSecondary; opacity: vm.isWarning ? 1.0 : 0.2 }
        Rectangle { width: 30; height: 10; radius: 5; color: Theme.textSecondary; opacity: 0.2 }
    }

    // Main 3-Panel Layout
    Item {
        anchors.fill: parent

        // Left Panel (Speed)
        Item {
            id: leftPanel
            width: 350
            height: 400
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -30
            // Exact center of the left arch is X=270 in clusterFrame. 
            // DashboardScreen has 10 margin inside clusterFrame, so X=260 relative to parent.
            x: 260 - width / 2

            NeonTickGauge {
                anchors.centerIn: parent
                width: 350
                height: 350
                value: vm.speed
                maxValue: 160
                isWarning: vm.isWarning
                tickCount: 80
                majorTickInterval: 10
            }

            Column {
                anchors.centerIn: parent
                spacing: 0
                
                GlowingText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: vm.displaySpeed
                    font.pixelSize: 90
                    glowColor: vm.isWarning ? Theme.warningRed : Theme.accentCyan
                    color: Theme.textPrimary
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "KM/H"
                    color: Theme.textSecondary
                    font.family: Theme.fontMain
                    font.pixelSize: 18
                    font.letterSpacing: 2
                }
            }
        }

        // Center Panel (Media/Nav)
        // centerPanel: intentional z:-1 inset between the two gauge bezels.
        // DO NOT convert to horizontalCenter — it would break the depth layering.
        Item {
            id: centerPanel
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -30
            height: 450
            anchors.left: leftPanel.right
            anchors.right: rightPanel.left
            anchors.leftMargin: -20
            anchors.rightMargin: -20
            z: -1 // Push slightly behind the gauges to create depth and prevent overlapping the glowing ticks

            MusicPlayer {
                anchors.fill: parent
                anchors.margins: 10
            }
        }

        // Right Panel (Gear/RPM)
        Item {
            id: rightPanel
            width: 350
            height: 400
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -30
            // Exact center of the right arch is X=890 in clusterFrame.
            // DashboardScreen has 10 margin inside clusterFrame, so X=880 relative to parent.
            x: 880 - width / 2

            NeonTickGauge {
                anchors.centerIn: parent
                width: 350
                height: 350
                value: vm.rpm
                maxValue: 6000
                isWarning: vm.isWarning
                tickCount: 60
                majorTickInterval: 10
                redlineValue: 5000
            }

            Column {
                anchors.centerIn: parent
                spacing: 10
                
                GlowingText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: vm.gear
                    font.pixelSize: 100
                    glowColor: vm.isWarning ? Theme.warningRed : Theme.accentCyan
                    color: Theme.textPrimary
                }
                
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "COMFORT"
                    color: Theme.accentCyan
                    font.family: Theme.fontMain
                    font.pixelSize: 16
                    font.letterSpacing: 2
                }
            }
        }
    }

    // Bottom Bar (Battery, Range, Temp)
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 80
        width: parent.width * 0.75
        
        // Left: Range
        Column {
            Layout.alignment: Qt.AlignLeft
            spacing: 8
            Text { 
                text: vm.range + " km"
                color: Theme.textPrimary
                font.family: Theme.fontMain
                font.pixelSize: 20 
            }
            // Mock energy blocks
            Row {
                spacing: 4
                Repeater {
                    model: 20
                    Rectangle {
                        width: 8; height: 8; radius: 2
                        color: index < 15 ? Theme.accentCyan : Theme.textSecondary
                        opacity: index < 15 ? 1.0 : 0.3
                    }
                }
            }
        }

        Item { Layout.fillWidth: true } // Spacer

        // Center: Temp
        Column {
            Layout.alignment: Qt.AlignHCenter
            spacing: 5
            Text { 
                text: "TEMP"
                color: Theme.textSecondary
                font.family: Theme.fontMain
                font.pixelSize: 12
                font.letterSpacing: 1
                anchors.horizontalCenter: parent.horizontalCenter 
            }
            Text { 
                text: vm.temperature + " °C"
                color: Theme.textPrimary
                font.family: Theme.fontMain
                font.pixelSize: 22
                anchors.horizontalCenter: parent.horizontalCenter 
            }
        }

        Item { Layout.fillWidth: true } // Spacer

        // Right: Battery
        Column {
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Text { 
                text: vm.battery + " %"
                color: Theme.textPrimary
                font.family: Theme.fontMain
                font.pixelSize: 20
                anchors.right: parent.right 
            }
            Row {
                anchors.right: parent.right 
                spacing: 4
                Repeater {
                    model: 20
                    Rectangle {
                        width: 8; height: 8; radius: 2
                        // Map battery (0-100) to 20 blocks
                        property bool isActive: index < (vm.battery / 5)
                        color: isActive ? (vm.battery < 20 ? Theme.warningRed : Theme.accentCyan) : Theme.textSecondary
                        opacity: isActive ? 1.0 : 0.3
                    }
                }
            }
        }
    }
}

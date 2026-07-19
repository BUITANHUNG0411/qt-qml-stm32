import QtQuick
import QtQuick.Layouts
import com.showcase
import "../components"

Item {
    id: root
    anchors.fill: parent

    property QtObject vm: VehicleStatus
    property real leftGaugeX: Theme.gaugeInsetLeft - Theme.dashboardMargin
    property real rightGaugeX: Theme.gaugeInsetRight - Theme.dashboardMargin

    // Top Bar (Telltales)
    RowLayout {
        id: topBar
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 70
        spacing: Theme.spaceXXl

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
            anchors.verticalCenterOffset: Theme.panelLift
            anchors.left: parent.left
            anchors.leftMargin: root.leftGaugeX - width / 2

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
            anchors.verticalCenterOffset: Theme.panelLift
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
            anchors.verticalCenterOffset: Theme.panelLift
            anchors.left: parent.left
            anchors.leftMargin: root.rightGaugeX - width / 2

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
            spacing: Theme.spaceMd
            Text { 
                text: vm.range + " km"
                color: Theme.textPrimary
                font.family: Theme.fontMain
                font.pixelSize: Theme.textLg
            }
            EnergyBlocks {
                value: vm.range
                maxValue: 400
                warningThreshold: 50
                invertWarning: false
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
            spacing: Theme.spaceMd
            Text { 
                text: vm.battery + " %"
                color: Theme.textPrimary
                font.family: Theme.fontMain
                font.pixelSize: Theme.textLg
                anchors.right: parent.right 
            }
            EnergyBlocks {
                anchors.right: parent.right 
                value: vm.battery
                maxValue: 100
                warningThreshold: 20
                invertWarning: false
            }
        }
    }
}

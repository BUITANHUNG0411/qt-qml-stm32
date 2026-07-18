import QtQuick
import QtQuick.Window
import com.showcase
import "components"
import "screens"

Window {
    id: root
    width: 1200
    height: 800
    visible: true
    title: qsTr("QtStmAutomotiveSimulator")
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint

    // Use the backend-injected ViewModel
    property var vm: VehicleStatus

    Shortcut {
        sequence: "Esc"
        onActivated: Qt.quit()
    }

    // Khung Cluster vật lý giả lập
    Rectangle {
        id: clusterFrame
        anchors.fill: parent
        anchors.margins: 20 // Tạo không gian nền trong suốt để nổi bật khối bo tròn
        color: Theme.backgroundDeepSpace
        radius: 40
        
        border.color: Qt.rgba(Theme.textSecondary.r, Theme.textSecondary.g, Theme.textSecondary.b, 0.3)
        border.width: 2

        // Cho phép kéo thả cửa sổ
        DragHandler {
            target: null
            onActiveChanged: if (active) root.startSystemMove()
        }

        DashboardScreen {
            anchors.fill: parent
            anchors.margins: 10
        }
    }
}

import QtQuick
import QtQuick.Window
import QtQuick.Shapes
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

    // Khung Cluster vật lý giả lập dạng Double Arch (Dựa theo tài liệu inspiration-design)
    Item {
        id: clusterFrame
        anchors.fill: parent
        anchors.margins: 20 // Tạo không gian nền trong suốt để nổi bật khối

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8 // Chống răng cưa (anti-aliasing) chất lượng cao

            ShapePath {
                fillColor: Theme.backgroundDeepSpace
                strokeColor: Qt.rgba(Theme.textSecondary.r, Theme.textSecondary.g, Theme.textSecondary.b, 0.3)
                strokeWidth: 2

                // Đường dẫn SVG (PathSvg) tạo hình "Binocular" / "Double Arch" (Đã căn chỉnh hoàn hảo theo Layout):
                // 1. M 270 0: Đỉnh đồng hồ trái (căn giữa trục X=270 của Gauge)
                // 2. C 380 0, 450 30, 510 30: Lượn mượt xuống phần hõm trên (Y=30 để không che TopBar)
                // 3. L 650 30: Đường ngang hõm trên
                // 4. C 710 30, 780 0, 890 0: Lượn mượt lên đỉnh đồng hồ phải (X=890)
                // 5. A 250 380 0 0 1 890 760: Cung Ellipse phải ôm trọn đồng hồ phải xuống tận đáy
                // 6. C 780 760, 710 730, 650 730: Lượn mượt lên phần hõm dưới (Y=730 bọc trọn BottomBar)
                // 7. L 510 730: Đường ngang hõm dưới
                // 8. C 450 730, 380 760, 270 760: Lượn mượt xuống đáy đồng hồ trái
                // 9. A 250 380 0 0 1 270 0 Z: Cung Ellipse trái ôm trọn đồng hồ trái và khép kín
                PathSvg {
                    path: "M 270 0 " +
                          "C 380 0, 450 30, 510 30 " +
                          "L 650 30 " +
                          "C 710 30, 780 0, 890 0 " +
                          "A 250 380 0 0 1 890 760 " +
                          "C 780 760, 710 730, 650 730 " +
                          "L 510 730 " +
                          "C 450 730, 380 760, 270 760 " +
                          "A 250 380 0 0 1 270 0 Z"
                }
            }
        }

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

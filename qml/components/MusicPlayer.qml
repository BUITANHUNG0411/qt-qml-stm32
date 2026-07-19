import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import com.showcase

Item {
    id: root
    implicitWidth: 350
    implicitHeight: 450

    // Local UI state (declarative only — no JS logic)
    property bool scrubberDragging: false
    property string toastMessage: ""
    property real toastOpacity: 0.0

    // Neon Blur Backdrop driven by current song color1 (Zero-JS)
    Rectangle {
        id: blurBackdrop
        anchors.fill: parent
        color: Theme.backgroundDeepSpace
        opacity: 0.65

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: pathView.currentItem !== null ? (pathView.currentItem.coverColor1 !== undefined ? pathView.currentItem.coverColor1 : "#FF0055") : "#FF0055" }
                GradientStop { position: 1.0; color: Theme.backgroundDeepSpace }
            }
        }

        MultiEffect {
            anchors.fill: parent
            source: parent
            blurEnabled: true
            blurMax: 48
            blur: 1.0
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        // Top 70%: Cover Flow Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PathView {
                id: pathView
                anchors.fill: parent
                model: MusicViewModel
                pathItemCount: 3
                preferredHighlightBegin: 0.5
                preferredHighlightEnd: 0.5
                interactive: true

                Connections {
                    target: MusicViewModel
                    function onCurrentIndexChanged() {
                        pathView.currentIndex = MusicViewModel.currentIndex
                    }
                }

                onMovementEnded: MusicViewModel.setCurrentIndex(currentIndex)

                // 3D Depth Path
                path: Path {
                    startX: 0
                    startY: pathView.height / 2

                    PathAttribute { name: "itemZ"; value: 0 }
                    PathAttribute { name: "itemScale"; value: 0.6 }
                    PathAttribute { name: "itemOpacity"; value: 0.4 }

                    PathLine { x: pathView.width / 2; y: pathView.height / 2 }
                    PathAttribute { name: "itemZ"; value: 100 }
                    PathAttribute { name: "itemScale"; value: 1.0 }
                    PathAttribute { name: "itemOpacity"; value: 1.0 }

                    PathLine { x: pathView.width; y: pathView.height / 2 }
                    PathAttribute { name: "itemZ"; value: 0 }
                    PathAttribute { name: "itemScale"; value: 0.6 }
                    PathAttribute { name: "itemOpacity"; value: 0.4 }
                }

                delegate: Item {
                    width: pathView.width * 0.55
                    height: width
                    scale: PathView.itemScale
                    opacity: PathView.itemOpacity
                    z: PathView.itemZ

                    // Expose properties to avoid binding errors
                    property string songTitle: model.title
                    property string songArtist: model.artist
                    property string coverColor1: model.color1
                    property string coverColor2: model.color2

                    // Base container for the cover (rotates when playing)
                    Rectangle {
                        id: coverRect
                        anchors.fill: parent
                        radius: 16
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: model.color1 !== undefined ? model.color1 : "#FF0055" }
                            GradientStop { position: 1.0; color: model.color2 !== undefined ? model.color2 : "#4A00E0" }
                        }
                        border.color: PathView.isCurrentItem ? Theme.accentCyan : "transparent"
                        border.width: PathView.isCurrentItem ? 2 : 0

                        transform: Rotation {
                            id: coverRotation
                            origin.x: coverRect.width / 2
                            origin.y: coverRect.height / 2
                            axis { x: 0; y: 1; z: 0 }

                            NumberAnimation on angle {
                                from: 0
                                to: 360
                                duration: 8000
                                loops: Animation.Infinite
                                running: PathView.isCurrentItem && MusicViewModel.isPlaying
                            }
                        }

                        // Reflection mask effect fading into background
                        Rectangle {
                            anchors.fill: parent
                            radius: 16
                            gradient: Gradient {
                                GradientStop { position: 0.5; color: "transparent" }
                                GradientStop { position: 1.0; color: Theme.backgroundDeepSpace }
                            }
                        }
                    }

                    // Neon Glow Effect for the current item
                    MultiEffect {
                        anchors.fill: coverRect
                        source: coverRect
                        shadowEnabled: PathView.isCurrentItem
                        shadowColor: Theme.accentCyan
                        shadowBlur: 1.0
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: MusicViewModel.play(index)
                    }
                }
            }

            // Loading spinner overlay (runs only while isLoading)
            Item {
                anchors.centerIn: parent
                width: 64
                height: 64
                visible: MusicViewModel.isLoading

                Rectangle {
                    anchors.fill: parent
                    radius: 32
                    color: "transparent"
                    border.color: Theme.accentCyan
                    border.width: 3
                    opacity: 0.25
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 32
                    color: "transparent"
                    border.color: Theme.accentCyan
                    border.width: 3
                    visible: false
                    id: spinnerArc

                    transform: Rotation {
                        origin.x: 32
                        origin.y: 32
                        NumberAnimation on angle {
                            from: 0
                            to: 360
                            duration: 900
                            loops: Animation.Infinite
                            running: MusicViewModel.isLoading
                        }
                    }
                }

                Text {
                    anchors.top: parent.bottom
                    anchors.topMargin: 8
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Loading..."
                    color: Theme.accentCyan
                    font.family: Theme.fontMain
                    font.pixelSize: 12
                }
            }
        }

        // Bottom 30%: Navigation Control Panel
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: "#40151D26" // Translucent dark base
            border.color: "#802A3B4C" // Subtle border for glass effect
            border.width: 1
            radius: 16

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 5

                // Track Info & Scan Button
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            text: pathView.currentItem ? pathView.currentItem.songTitle : (MusicViewModel.isScanning ? "Scanning..." : "No Music")
                            font.family: Theme.fontMain
                            font.pixelSize: 22
                            font.bold: true
                            color: Theme.textPrimary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        Text {
                            text: pathView.currentItem ? pathView.currentItem.songArtist : ""
                            font.family: Theme.fontMain
                            font.pixelSize: 14
                            color: Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }

                    // Scan Library Button
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 70
                        height: 30
                        radius: 8
                        color: MusicViewModel.isScanning ? Theme.accentCyan : "transparent"
                        border.color: Theme.accentCyan
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: MusicViewModel.isScanning ? "..." : "Scan"
                            color: MusicViewModel.isScanning ? Theme.backgroundDeepSpace : Theme.accentCyan
                            font.family: Theme.fontMain
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: MusicViewModel.scanLibrary()
                            enabled: !MusicViewModel.isScanning
                        }
                    }
                }

                // Scrubber (Progress Bar wrapped in MouseArea)
                Item {
                    Layout.fillWidth: false
                    Layout.preferredWidth: root.width * 0.6
                    Layout.preferredHeight: 10
                    Layout.alignment: Qt.AlignHCenter

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 3
                        color: "#40FFFFFF"
                        radius: 1.5

                        Rectangle {
                            width: parent.width * (root.scrubberDragging
                                ? (scrberMouse.dragX / Math.max(1, root.width))
                                : (MusicViewModel.duration > 0
                                    ? (MusicViewModel.positionMs / MusicViewModel.duration)
                                    : MusicViewModel.progress))
                            height: parent.height
                            color: Theme.accentCyan
                            radius: 1.5

                            // Glowing Thumb
                            Rectangle {
                                id: thumb
                                width: 10
                                height: 10
                                radius: 5
                                color: Theme.textPrimary
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                anchors.rightMargin: -5
                            }

                            MultiEffect {
                                anchors.fill: thumb
                                source: thumb
                                shadowEnabled: true
                                shadowColor: Theme.accentCyan
                                shadowBlur: 1.0
                            }
                        }
                    }

                    MouseArea {
                        id: scrberMouse
                        anchors.fill: parent
                        property real dragX: 0
                        onPressed: {
                            root.scrubberDragging = true
                            dragX = mouseX
                            MusicViewModel.seek(mouseX / Math.max(1, width))
                        }
                        onPositionChanged: {
                            dragX = mouseX
                            MusicViewModel.seek(mouseX / Math.max(1, width))
                        }
                        onReleased: root.scrubberDragging = false
                    }
                }

                // Volume Slider
                Item {
                    Layout.fillWidth: false
                    Layout.preferredWidth: root.width * 0.6
                    Layout.preferredHeight: 14
                    Layout.alignment: Qt.AlignHCenter

                    Image {
                        id: volIcon
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: 16
                        height: 16
                        source: "qrc:/qt/qml/com/showcase/resources/icons/volume.svg"
                        sourceSize: Qt.size(16, 16)
                        visible: false
                    }
                    MultiEffect {
                        anchors.fill: volIcon
                        source: volIcon
                        colorization: 1.0
                        colorizationColor: Theme.textSecondary
                    }

                    Rectangle {
                        anchors.left: volIcon.right
                        anchors.leftMargin: 8
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 3
                        color: "#40FFFFFF"
                        radius: 1.5

                        Rectangle {
                            width: parent.width * MusicViewModel.volume
                            height: parent.height
                            color: Theme.accentCyan
                            radius: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPressed: MusicViewModel.setVolume(mouseX / Math.max(1, width))
                            onPositionChanged: MusicViewModel.setVolume(mouseX / Math.max(1, width))
                        }
                    }
                }

                // Media Controls
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 30

                    Item { Layout.fillWidth: true } // Spacer

                    // Shuffle Button
                    Item {
                        width: 24
                        height: 24
                        opacity: MusicViewModel.shuffleMode ? 1.0 : 0.4
                        Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

                        Image {
                            id: shuffleIcon
                            anchors.fill: parent
                            source: "qrc:/qt/qml/com/showcase/resources/icons/shuffle.svg"
                            sourceSize: Qt.size(24, 24)
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: shuffleIcon
                            source: shuffleIcon
                            colorization: 1.0
                            colorizationColor: MusicViewModel.shuffleMode ? Theme.accentCyan : Theme.textSecondary
                            Behavior on colorizationColor { ColorAnimation { duration: Theme.durationFast } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: MusicViewModel.toggleShuffle()
                        }
                    }

                    // Prev Button
                    Item {
                        width: 26
                        height: 26
                        scale: prevMouse.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Image {
                            id: prevIcon
                            anchors.fill: parent
                            source: "qrc:/qt/qml/com/showcase/resources/icons/prev.svg"
                            sourceSize: Qt.size(26, 26)
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: prevIcon
                            source: prevIcon
                            colorization: 1.0
                            colorizationColor: prevMouse.pressed ? Theme.accentCyan : Theme.textPrimary
                            Behavior on colorizationColor { ColorAnimation { duration: 100 } }
                        }
                        MouseArea { id: prevMouse; anchors.fill: parent; onClicked: MusicViewModel.prev() }
                    }

                    // Play/Pause Button
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: playMouse.pressed ? Theme.accentCyan : "transparent"
                        border.color: Theme.accentCyan
                        border.width: 2
                        scale: playMouse.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Image {
                            id: playIcon
                            width: 20
                            height: 20
                            anchors.centerIn: parent
                            // Toggle icon based on playing state
                            source: MusicViewModel.isPlaying ? "qrc:/qt/qml/com/showcase/resources/icons/pause.svg" : "qrc:/qt/qml/com/showcase/resources/icons/play.svg"
                            sourceSize: Qt.size(20, 20)
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: playIcon
                            source: playIcon
                            colorization: 1.0
                            colorizationColor: playMouse.pressed ? Theme.backgroundDeepSpace : Theme.accentCyan
                            Behavior on colorizationColor { ColorAnimation { duration: 100 } }
                        }
                        MouseArea { id: playMouse; anchors.fill: parent; onClicked: MusicViewModel.togglePlayPause() }
                    }

                    // Next Button
                    Item {
                        width: 26
                        height: 26
                        scale: nextMouse.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        Image {
                            id: nextIcon
                            anchors.fill: parent
                            source: "qrc:/qt/qml/com/showcase/resources/icons/next.svg"
                            sourceSize: Qt.size(26, 26)
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: nextIcon
                            source: nextIcon
                            colorization: 1.0
                            colorizationColor: nextMouse.pressed ? Theme.accentCyan : Theme.textPrimary
                            Behavior on colorizationColor { ColorAnimation { duration: 100 } }
                        }
                        MouseArea { id: nextMouse; anchors.fill: parent; onClicked: MusicViewModel.next() }
                    }

                    // Repeat Button
                    Item {
                        width: 24
                        height: 24
                        opacity: MusicViewModel.repeatMode === MusicEnums.RepeatMode.Off ? 0.4 : 1.0
                        Behavior on opacity { NumberAnimation { duration: Theme.durationFast } }

                        Image {
                            id: repeatIcon
                            anchors.fill: parent
                            source: "qrc:/qt/qml/com/showcase/resources/icons/repeat.svg"
                            sourceSize: Qt.size(24, 24)
                            visible: false
                        }
                        MultiEffect {
                            anchors.fill: repeatIcon
                            source: repeatIcon
                            colorization: 1.0
                            colorizationColor: MusicViewModel.repeatMode === MusicEnums.RepeatMode.Off
                                ? Theme.textSecondary
                                : (MusicViewModel.repeatMode === MusicEnums.RepeatMode.One ? Theme.warningRed : Theme.accentCyan)
                            Behavior on colorizationColor { ColorAnimation { duration: Theme.durationFast } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: MusicViewModel.cycleRepeat()
                        }

                        // Repeat-One badge
                        Rectangle {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            width: 10
                            height: 10
                            radius: 5
                            color: Theme.warningRed
                            visible: MusicViewModel.repeatMode === MusicEnums.RepeatMode.One
                        }
                    }

                    Item { Layout.fillWidth: true } // Spacer
                }

                // Equalizer bars (animate only while playing)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 14
                    spacing: 3

                    Repeater {
                        model: 4
                        Item {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 4
                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                width: 4
                                height: 4
                                radius: 2
                                color: Theme.accentCyan
                                NumberAnimation on height {
                                    from: 4
                                    to: 14
                                    duration: 300 + index * 90
                                    loops: Animation.Infinite
                                    running: MusicViewModel.isPlaying
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Error Toast (driven by playbackError signal)
    Connections {
        target: MusicViewModel
        function onPlaybackError(msg) {
            root.toastMessage = msg
            root.toastOpacity = 1.0
            toastHideTimer.restart()
        }
    }

    Timer {
        id: toastHideTimer
        interval: 3000
        repeat: false
        onTriggered: root.toastOpacity = 0.0
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        width: Math.min(parent.width - 24, toastText.width + 28)
        height: 34
        radius: 8
        color: Theme.warningRed
        opacity: root.toastOpacity
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }

        Text {
            id: toastText
            anchors.centerIn: parent
            text: root.toastMessage
            color: "#FFFFFF"
            font.family: Theme.fontMain
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }
}

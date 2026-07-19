import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import com.showcase

Item {
    id: root
    implicitWidth: 350
    implicitHeight: 450

    // Local UI state
    property bool scrubberDragging: scrberMouse.pressed

    // Neon Blur Backdrop driven by current song
    Rectangle {
        id: blurBackdrop
        anchors.fill: parent
        color: Theme.backgroundDeepSpace
        opacity: 0.65

        Item {
            id: backdropSource
            anchors.fill: parent
            Image {
                anchors.fill: parent
                source: pathView.currentItem !== null ? pathView.currentItem.coverArt : ""
                fillMode: Image.PreserveAspectCrop
                visible: source.toString() !== ""
            }
            Rectangle {
                anchors.fill: parent
                visible: parent.children[0].source.toString() === ""
                gradient: Gradient {
                    GradientStop { position: 0.0; color: pathView.currentItem !== null ? (pathView.currentItem.coverColor1 !== undefined ? pathView.currentItem.coverColor1 : Theme.coverFallback1) : Theme.coverFallback1 }
                    GradientStop { position: 1.0; color: Theme.backgroundDeepSpace }
                }
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
        spacing: Theme.spaceXl

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
                
                currentIndex: MusicViewModel.currentIndex
                onCurrentIndexChanged: {
                    if (interactive && currentIndex !== MusicViewModel.currentIndex) {
                        MusicViewModel.setCurrentIndex(currentIndex)
                    }
                }

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

                    property string songTitle: model.title
                    property string songArtist: model.artist
                    property string coverColor1: model.color1
                    property string coverColor2: model.color2
                    property string coverArt: model.coverArt !== undefined ? model.coverArt : ""

                    Rectangle {
                        id: coverRect
                        anchors.fill: parent
                        radius: Theme.radiusMd
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: model.color1 !== undefined ? model.color1 : Theme.coverFallback1 }
                            GradientStop { position: 1.0; color: model.color2 !== undefined ? model.color2 : Theme.coverFallback2 }
                        }
                        border.color: PathView.isCurrentItem ? Theme.accentCyan : "transparent"
                        border.width: PathView.isCurrentItem ? 2 : 0
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: parent.parent.coverArt
                            fillMode: Image.PreserveAspectCrop
                            visible: source.toString() !== ""
                        }

                        transform: Rotation {
                            id: coverRotation
                            origin.x: coverRect.width / 2
                            origin.y: coverRect.height / 2
                            axis { x: 0; y: 1; z: 0 }
                            NumberAnimation on angle {
                                from: 0; to: 360; duration: Theme.durationCover; loops: Animation.Infinite
                                running: PathView.isCurrentItem && MusicViewModel.isPlaying
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusMd
                            gradient: Gradient {
                                GradientStop { position: 0.5; color: "transparent" }
                                GradientStop { position: 1.0; color: Theme.backgroundDeepSpace }
                            }
                        }
                    }

                    MultiEffect {
                        anchors.fill: coverRect
                        source: coverRect
                        shadowEnabled: PathView.isCurrentItem
                        shadowColor: Theme.accentCyan
                        shadowBlur: 1.0
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: MusicViewModel.play(index)
                    }
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Theme.spaceMd
                visible: MusicViewModel.isLoading

                Item {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.radiusPill
                        color: "transparent"
                        border.color: Theme.accentCyan
                        border.width: 3
                        opacity: 0.25
                    }

                    Item {
                        anchors.fill: parent
                        Rectangle {
                            width: parent.width / 2
                            height: parent.height
                            color: "transparent"
                            border.color: Theme.accentCyan
                            border.width: 3
                            clip: true
                        }
                        transform: Rotation {
                            origin.x: 32; origin.y: 32
                            NumberAnimation on angle {
                                from: 0; to: 360; duration: Theme.durationSpin; loops: Animation.Infinite
                                running: MusicViewModel.isLoading
                            }
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Loading..."
                    color: Theme.accentCyan
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.textXs
                }
            }
        }

        // Bottom 30%: Navigation Control Panel
        GlassPanel {
            Layout.fillWidth: true
            Layout.preferredHeight: 140

            Column {
                anchors.centerIn: parent
                width: parent.width * 0.85
                spacing: Theme.spaceSm

                Item {
                    width: parent.width
                    height: 48

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            text: pathView.currentItem ? pathView.currentItem.songTitle : (MusicViewModel.isScanning ? "Scanning..." : "No Music")
                            font.family: Theme.fontMain
                            font.pixelSize: Theme.textMd
                            font.bold: true
                            color: Theme.textPrimary
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 80
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                        Text {
                            text: pathView.currentItem ? pathView.currentItem.songArtist : ""
                            font.family: Theme.fontMain
                            font.pixelSize: Theme.textXs
                            color: Theme.textSecondary
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width - 80
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                        height: 28
                        radius: Theme.radiusSm
                        color: MusicViewModel.isScanning ? Theme.accentCyan : "transparent"
                        border.color: Theme.accentCyan
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: MusicViewModel.isScanning ? "..." : "Scan"
                            color: MusicViewModel.isScanning ? Theme.backgroundDeepSpace : Theme.accentCyan
                            font.family: Theme.fontMain
                            font.pixelSize: Theme.textXs
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: MusicViewModel.scanLibrary()
                            enabled: !MusicViewModel.isScanning
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: 12
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 3
                        color: Theme.trackInactive
                        radius: 1.5

                        Rectangle {
                            width: parent.width * (root.scrubberDragging
                                ? (scrberMouse.dragX / Math.max(1, parent.width))
                                : (MusicViewModel.duration > 0
                                    ? (MusicViewModel.positionMs / MusicViewModel.duration)
                                    : MusicViewModel.progress))
                            height: parent.height
                            color: Theme.accentCyan
                            radius: 1.5

                            Rectangle {
                                id: thumb
                                width: 10; height: 10; radius: 5
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
                        onPositionChanged: {
                            if (pressed) {
                                dragX = mouseX
                                MusicViewModel.seek(mouseX / Math.max(1, width))
                            }
                        }
                        onPressed: {
                            dragX = mouseX
                            MusicViewModel.seek(mouseX / Math.max(1, width))
                        }
                    }
                }

                Row {
                    width: parent.width
                    height: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spaceMd

                    NeonIcon {
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/qt/qml/com/showcase/resources/icons/volume.svg"
                        colorizationColor: Theme.textSecondary
                    }

                    Rectangle {
                        width: parent.width - 16 - Theme.spaceMd
                        anchors.verticalCenter: parent.verticalCenter
                        height: 3
                        color: Theme.trackInactive
                        radius: 1.5

                        Rectangle {
                            width: parent.width * MusicViewModel.volume
                            height: parent.height
                            color: Theme.accentCyan
                            radius: 1.5
                        }

                        MouseArea {
                            anchors.fill: parent
                            onPositionChanged: if (pressed) MusicViewModel.setVolume(mouseX / Math.max(1, width))
                            onPressed: MusicViewModel.setVolume(mouseX / Math.max(1, width))
                        }
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: Theme.spaceXl

                    NeonIconButton {
                        width: 24; height: 24
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/qt/qml/com/showcase/resources/icons/shuffle.svg"
                        isToggle: true
                        isActive: MusicViewModel.shuffleMode
                        colorizationColor: Theme.textSecondary
                        onClicked: MusicViewModel.toggleShuffle()
                    }

                    NeonIconButton {
                        width: 26; height: 26
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/qt/qml/com/showcase/resources/icons/prev.svg"
                        onClicked: MusicViewModel.prev()
                    }

                    Rectangle {
                        width: 44; height: 44; radius: Theme.radiusLg
                        anchors.verticalCenter: parent.verticalCenter
                        color: playMouse.pressed ? Theme.accentCyan : "transparent"
                        border.color: Theme.accentCyan
                        border.width: 2
                        scale: playMouse.pressed ? 0.9 : 1.0
                        Behavior on scale { NumberAnimation { duration: Theme.durationPress } }
                        Behavior on color { ColorAnimation { duration: Theme.durationPress } }
                        
                        NeonIcon {
                            width: 20; height: 20
                            anchors.centerIn: parent
                            source: MusicViewModel.isPlaying ? "qrc:/qt/qml/com/showcase/resources/icons/pause.svg" : "qrc:/qt/qml/com/showcase/resources/icons/play.svg"
                            colorizationColor: playMouse.pressed ? Theme.backgroundDeepSpace : Theme.accentCyan
                        }
                        MouseArea { id: playMouse; anchors.fill: parent; onClicked: MusicViewModel.togglePlayPause() }
                    }

                    NeonIconButton {
                        width: 26; height: 26
                        anchors.verticalCenter: parent.verticalCenter
                        source: "qrc:/qt/qml/com/showcase/resources/icons/next.svg"
                        onClicked: MusicViewModel.next()
                    }

                    Item {
                        width: 24; height: 24
                        anchors.verticalCenter: parent.verticalCenter

                        NeonIconButton {
                            anchors.fill: parent
                            source: "qrc:/qt/qml/com/showcase/resources/icons/repeat.svg"
                            isToggle: true
                            isActive: MusicViewModel.repeatMode !== MusicEnums.RepeatMode.Off
                            colorizationColor: Theme.textSecondary
                            activeColor: MusicViewModel.repeatMode === MusicEnums.RepeatMode.One ? Theme.warningRed : Theme.accentCyan
                            onClicked: MusicViewModel.cycleRepeat()
                        }
                        
                        Rectangle {
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            width: 10; height: 10; radius: 5
                            color: Theme.warningRed
                            visible: MusicViewModel.repeatMode === MusicEnums.RepeatMode.One
                        }
                    }
                }
            }
        }
    }

    // Declarative Error Toast
    Timer {
        id: toastHideTimer
        interval: 3000
        running: MusicViewModel.lastError !== ""
        onTriggered: MusicViewModel.clearError()
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        width: Math.min(parent.width - 24, toastText.width + 28)
        height: 34
        radius: Theme.radiusSm
        color: Theme.warningRed
        opacity: MusicViewModel.lastError !== "" ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: Theme.durationNormal } }

        Text {
            id: toastText
            anchors.centerIn: parent
            text: MusicViewModel.lastError
            color: Theme.textPrimary
            font.family: Theme.fontMain
            font.pixelSize: Theme.textXs
            elide: Text.ElideRight
        }
    }
}

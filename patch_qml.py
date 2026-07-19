import re

with open('qml/components/MusicPlayer.qml', 'r') as f:
    content = f.read()

# We will replace everything from:
#             ColumnLayout {
#                 anchors.fill: parent
#                 anchors.margins: 15
#                 spacing: 5
# down to the end of Equalizer bars (or the closing brace of ColumnLayout)

start_marker = "            ColumnLayout {"
end_marker = "        // Error Toast (driven by playbackError signal)"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx == -1 or end_idx == -1:
    print("Could not find markers!")
    exit(1)

# Retreat end_idx to the end of the previous line before Error Toast
end_idx = content.rfind("    }", 0, end_idx) + 5

new_content = """            Column {
                anchors.centerIn: parent
                width: parent.width * 0.85
                spacing: 6

                // 1. Track Info (Centered) & Scan Button (Right)
                Item {
                    width: parent.width
                    height: 48

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

                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 60
                        height: 28
                        radius: 8
                        color: MusicViewModel.isScanning ? Theme.accentCyan : "transparent"
                        border.color: Theme.accentCyan
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: MusicViewModel.isScanning ? "..." : "Scan"
                            color: MusicViewModel.isScanning ? Theme.backgroundDeepSpace : Theme.accentCyan
                            font.family: Theme.fontMain
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: MusicViewModel.scanLibrary()
                            enabled: !MusicViewModel.isScanning
                        }
                    }
                }

                // 2. Scrubber
                Item {
                    width: parent.width
                    height: 12

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 3
                        color: "#40FFFFFF"
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

                // 3. Volume Slider
                Item {
                    width: parent.width
                    height: 16

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

                // 4. Media Controls
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 24

                    Item {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
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

                    Item {
                        width: 26
                        height: 26
                        anchors.verticalCenter: parent.verticalCenter
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

                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        anchors.verticalCenter: parent.verticalCenter
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

                    Item {
                        width: 26
                        height: 26
                        anchors.verticalCenter: parent.verticalCenter
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

                    Item {
                        width: 24
                        height: 24
                        anchors.verticalCenter: parent.verticalCenter
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
                }
            }"""

with open('qml/components/MusicPlayer.qml', 'w') as f:
    f.write(content[:start_idx] + new_content + content[end_idx:])
print("Patched!")

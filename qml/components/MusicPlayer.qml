import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Effects
import com.showcase

Item {
    id: root
    implicitWidth: 350
    implicitHeight: 450

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

                    // Base container for the cover
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
                        onClicked: {
                            pathView.currentIndex = index
                            MusicViewModel.setCurrentIndex(index)
                        }
                    }
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

                // Progress Bar
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 10
                    
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 3
                        color: "#40FFFFFF"
                        radius: 1.5
                        
                        Rectangle {
                            width: parent.width * MusicViewModel.progress // Bind to real progress
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
                }

                // Media Controls
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 30

                    Item { Layout.fillWidth: true } // Spacer

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

                    Item { Layout.fillWidth: true } // Spacer
                }
            }
        }
    }
}

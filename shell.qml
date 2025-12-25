import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // Theme colors
    property color colBg: Theme.colBg
    property color colFg: Theme.colFg
    property color col0: Theme.col0
    property color col1: Theme.col1
    property color col2: Theme.col2
    property color col3: Theme.col3
    property color col4: Theme.col4
    property color col5: Theme.col5
    property color col6: Theme.col6
    property color col7: Theme.col7
    property color col8: Theme.col8
    property color col9: Theme.col9
    property color col10: Theme.col10
    property color col11: Theme.col11
    property color col12: Theme.col12
    property color col13: Theme.col13
    property color col14: Theme.col14
    property color col15: Theme.col15
    // Font
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 18

    property int cpuUsage: 0
    property int memUsage: 0

    // CPU tracking
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    property var batteryPerc: 0


    //cat /sys/class/power_supply/BAT1/capacity
    Process { 
      id: batteryProcess 
      command: ["sh", "-c", "cat /sys/class/power_supply/BAT1/capacity"]
      
      stdout: SplitParser {
        onRead: data => {
          batteryPerc = data  
        }
      }
      
      Component.onCompleted: running = true
    }

    // CPU usage
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var user = parseInt(parts[1]) || 0
                var nice = parseInt(parts[2]) || 0
                var system = parseInt(parts[3]) || 0
                var idle = parseInt(parts[4]) || 0
                var iowait = parseInt(parts[5]) || 0
                var irq = parseInt(parts[6]) || 0
                var softirq = parseInt(parts[7]) || 0

                var total = user + nice + system + idle + iowait + irq + softirq
                var idleTime = idle + iowait

                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal
                    var idleDiff = idleTime - lastCpuIdle
                    if (totalDiff > 0) {
                        cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                    }
                }
                lastCpuTotal = total
                lastCpuIdle = idleTime
            }
        }
        Component.onCompleted: running = true
    }

  Process {
    id: songData
    command: ["playerctl", "-p", "spotify", "metadata", "--format", "{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}"]
    
    property string songTitle: ""
    property string songArtist: ""
    property string songAlbum: ""
    property string albumArt: ""
    
    stdout: SplitParser {
        onRead: data => {
            if (!data) return
            var parts = data.split("|")
            songData.songTitle = parts[0] || "Nothing playing"
            songData.songArtist = parts[1] || ""
            songData.songAlbum = parts[2] || ""
            songData.albumArt = parts[3] || ""
        }
    }
    
    Component.onCompleted: running = true
}

    // Memory usage
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                memUsage = Math.round(100 * used / total)
            }
        }
        Component.onCompleted: running = true
    }


    // Current layout (Hyprland: dwindle/master/floating)
    Process {
        id: layoutProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    currentLayout = data.trim()
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Slow timer for system stats
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            songData.running = true
            batteryProcess.running = true
        }
    }

    // Event-based updates for window/layout (instant)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            layoutProc.running = true
        }
    }


    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 40
            color: "transparent"

            margins {
                top: 10
                bottom: 0
                left: 20
                right: 20
            }

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: root.colBg
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    //left elements
                    Item { width: 16 }
                    Text {
                        text: "󰣇"
                        color: root.col2
                        font.pixelSize: root.fontSize
                        Layout.rightMargin: 8
                    }
                    Item { width: 8 }
                    Repeater {
                          model: Hyprland.workspaces.values.filter(ws => ws.id > 0)
                          Rectangle {
                            Layout.preferredHeight: parent.height
                            color: "transparent"
                            property bool isActive: Hyprland.focusedWorkspace?.id === modelData.id
                            Layout.preferredWidth: isActive ? 28 : 12
                            Layout.leftMargin: 4
                            Layout.rightMargin: 4
                            
                            Rectangle {
                                id: circle
                                //circle shape
                                radius: 6
                                width: parent.isActive ? 24 : 15
                                height: 15
                                color: parent.isActive ? root.col1 : root.col3
                                anchors.centerIn: parent
                                
                                Behavior on width {
                                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                                }
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + modelData.id)
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                    Item { width: 16 }
                    Text {
                        text: " " + songData.songTitle
                        color: root.col4
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }
                    Item { Layout.fillWidth: true } // Takes up remaining space
                    //right elements
                    Text {
                        text:  batteryPerc + " 󰂎" 
                        color: root.col12
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }
                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.col1
                    }
                    Text {
                        text:memUsage + " "
                        color: root.col13
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }
                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 16
                        Layout.alignment: Qt.AlignVCenter
                        Layout.leftMargin: 0
                        Layout.rightMargin: 8
                        color: root.col1
                    }
                    Text {
                        text: cpuUsage + " "
                        color: root.col14
                        font.pixelSize: root.fontSize
                        font.family: root.fontFamily
                        font.bold: true
                        Layout.rightMargin: 8
                    }
                    Item { width: 16 }
                }
                // center
                Text {
                    id: clockText
                    text: Qt.formatDateTime(new Date(), "HH:mm")
                    color: root.col2
                    font.pixelSize: root.fontSize
                    font.family: root.fontFamily
                    font.bold: true
                    anchors.centerIn: parent  // Centers in the parent container (screen)
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "HH:mm")
                    }

                }
            }
        }
    }
}

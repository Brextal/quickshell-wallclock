import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Window

ShellRoot {
    id: root

    property int cpuTemp: 0
    property int gpuTemp: 0
    property int ramPercent: 0
    property int diskPercent: 0

    PanelWindow {
        anchors.top: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        implicitWidth: 350
        implicitHeight: 500

        WlrLayershell.layer: WlrLayer.Bottom

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Column {
            id: clockCol
            anchors.right: parent.right
            anchors.rightMargin: 220
            y: 100
            spacing: -28

            Text {
                text: Qt.formatDateTime(clock.date, "HH")
                color: "#3dd1b0"
                style: Text.Outline
                styleColor: "#80000000"
                font.pixelSize: 82
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "mm")
                color: "#3dd1b0"
                opacity: 0.75
                style: Text.Outline
                styleColor: "#80000000"
                font.pixelSize: 62
                font.bold: true
            }
        }

        Text {
            anchors.right: clockCol.right
            anchors.bottom: clockCol.top
            anchors.bottomMargin: 6
            text: Qt.formatDate(clock.date, "MMMM d")
            color: "#f5c842"
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: 16
            font.bold: true
        }

        Text {
            anchors.right: clockCol.right
            anchors.top: clockCol.bottom
            anchors.topMargin: 12
            text: Qt.formatDate(clock.date, "yyyy")
            color: "#d4a017"
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: 14
            font.bold: true
        }
    }

    PanelWindow {
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        implicitHeight: 160

        WlrLayershell.layer: WlrLayer.Bottom

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 60
            spacing: 16

            RingArc {
                value: root.cpuTemp / 100
                displayText: root.cpuTemp + "°"
                label: "CPU"
                arcColor: root.cpuTemp < 60 ? "#3dd1b0" : root.cpuTemp < 80 ? "#ffaa00" : "#ff4444"
            }

            RingArc {
                value: root.gpuTemp / 100
                displayText: root.gpuTemp + "°"
                label: "GPU"
                arcColor: root.gpuTemp < 60 ? "#3dd1b0" : root.gpuTemp < 80 ? "#ffaa00" : "#ff4444"
            }

            RingArc {
                value: root.ramPercent / 100
                displayText: root.ramPercent + "%"
                label: "RAM"
            }

            RingArc {
                value: root.diskPercent / 100
                displayText: root.diskPercent + "%"
                label: "DISK"
            }
        }
    }

    Process {
        id: poller
        command: ["/home/brextal/.config/quickshell/wallclock/stats.sh"]
        running: true

        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    var data = JSON.parse(poller.stdout.text)
                    root.cpuTemp = data.cpuTemp
                    root.gpuTemp = data.gpuTemp
                    root.ramPercent = data.ramPercent
                    root.diskPercent = data.diskPercent
                } catch (e) {}
            }
        }

        onRunningChanged: if (!running) running = true
    }
}

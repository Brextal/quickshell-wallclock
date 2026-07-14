import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Controls
import QtQuick.Window
import Qt5Compat.GraphicalEffects
import "./shared" as Pywal

ShellRoot {
    id: root
    property var pywal: Pywal.Pywal { id: pywalColors }

    property int cpuTemp: 0
    property int gpuTemp: 0
    property int ramPercent: 0
    property int diskPercent: 0
    property int currentWorkspace: 1
    property bool musicActive: false

    // ─── Workspace indicator (top-left) ───

    PanelWindow {
        anchors.top: true
        anchors.left: true
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        implicitWidth: 140
        implicitHeight: 90

        WlrLayershell.layer: WlrLayer.Bottom

        Column {
            anchors.centerIn: parent
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Workspace"
                color: pywalColors.color6
                font.pixelSize: 12
                font.bold: true
                opacity: 0.7
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.currentWorkspace
                color: pywalColors.color4
                font.pixelSize: 36
                font.bold: true
            }
        }

        Connections {
            target: Hyprland
            function onFocusedWorkspaceChanged() {
                root.currentWorkspace = Hyprland.focusedWorkspace?.id ?? 1
            }
        }

        Component.onCompleted: {
            root.currentWorkspace = Hyprland.focusedWorkspace?.id ?? 1
        }
    }

    // ─── Clock (top-right) ───

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
                color: pywalColors.color4
                style: Text.Outline
                styleColor: "#80000000"
                font.pixelSize: 82
                font.bold: true
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(clock.date, "mm")
                color: pywalColors.color4
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
            color: pywalColors.color5
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
            color: pywalColors.color6
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: 14
            font.bold: true
        }
    }

    // ─── Music widget (center-right, floating) ───

    property bool showingMusic: false
    property real musicPosition: 0
    property var cavaBars: [0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    property string coverPath: ""
    property string lastTrackUrl: ""
    property string _dir: Qt.resolvedUrl(".").toString().replace("file://", "") + "/"
    property bool eqEnabled: false
    property var eqGains: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    Timer {
        interval: 1000
        running: root.showingMusic
        repeat: true
        onTriggered: {
            var p = musicPlayer.findActive()
            if (p) root.musicPosition = p.position || 0
        }
    }

    PanelWindow {
        id: musicPanel
        anchors { right: true; top: true }
        margins.top: 220
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        implicitWidth: 164
        implicitHeight: 560
        visible: root.showingMusic

        aboveWindows: true

        mask: Region {
            Region { item: mBtnPrev }
            Region { item: mBtnPlay }
            Region { item: mBtnFolder }
            Region { item: mBtnNext }
        }

        Item {
            anchors.centerIn: parent
            width: 144
            height: 400

            Column {
                anchors.centerIn: parent
                spacing: 10

                // ─── Album Art (circular, spinning) ───

                Item {
                    width: 120; height: 120
                    anchors.horizontalCenter: parent.horizontalCenter

                    Image {
                        id: albumArt
                        width: 120; height: 120
                        anchors.centerIn: parent
                        source: root.coverPath ? "file://" + root.coverPath : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: false
                    }

                    OpacityMask {
                        anchors.centerIn: parent
                        width: 120; height: 120
                        source: albumArt
                        maskSource: Rectangle {
                            width: 120; height: 120
                            radius: 60
                        }

                        NumberAnimation on rotation {
                            from: 0; to: 360
                            duration: 8000
                            loops: Animation.Infinite
                            running: {
                                var p = musicPlayer.findActive()
                                return p && p.isPlaying
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 60
                        color: "transparent"
                        border { color: "#30ffffff"; width: 1 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf001"
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 32
                        color: "#40ffffff"
                        visible: albumArt.status !== Image.Ready
                    }
                }

                // ─── Play / Pause ───

                Item {
                    id: mBtnPlay
                    width: 48; height: 48
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        anchors.fill: parent; radius: 24
                        color: mPlayMa.containsMouse ? "#501e1e2e" : "#301e1e2e"
                        border { color: "#601e1e2e"; width: 1 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: {
                            var p = musicPlayer.findActive()
                            return p && p.isPlaying ? "\uf04c" : "\uf04b"
                        }
                        color: pywalColors.color4
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 18
                    }

                    MouseArea {
                        id: mPlayMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = musicPlayer.findActive()
                            if (p && p.canTogglePlaying) p.togglePlaying()
                        }
                    }
                }

                // ─── Artist ───

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        var p = musicPlayer.findActive()
                        return p && p.trackArtist ? p.trackArtist : "Artist"
                    }
                    color: pywalColors.color4
                    font.pixelSize: 12
                    font.bold: true
                    width: 144
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                // ─── Song title ───

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: {
                        var p = musicPlayer.findActive()
                        return p && p.trackTitle ? p.trackTitle : "Song"
                    }
                    color: pywalColors.foreground
                    font.pixelSize: 11
                    width: 144
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                // ─── Duration ───

                Text {
                    text: {
                        var p = musicPlayer.findActive()
                        if (!p) return "0:00 / 0:00"
                        var pos = Math.floor(root.musicPosition)
                        var dur = Math.floor(p.length || 0)
                        function fmt(s) {
                            var m = Math.floor(s / 60)
                            var sec = s % 60
                            return m + ":" + (sec < 10 ? "0" : "") + sec
                        }
                        return fmt(pos) + " / " + fmt(dur)
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: pywalColors.color5
                    font.pixelSize: 10
                }

                // ─── Separator ───

                Rectangle {
                    width: 80; height: 1
                    color: "#30ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // ─── Prev / Folder / Next ───

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 30

                    Item {
                        id: mBtnPrev
                        width: 30; height: 30
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.fill: parent; radius: 8
                            color: mPrevMa.containsMouse ? "#301e1e2e" : "transparent"
                            border { color: mPrevMa.containsMouse ? "#601e1e2e" : "transparent"; width: 1 }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "\uf04a"
                            color: mPrevMa.containsMouse ? pywalColors.color4 : "#aaaaaa"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: mPrevMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                navProc.command = ["dbus-send", "--session", "--type=method_call",
                                    "--dest=org.mpris.MediaPlayer2.mpv",
                                    "/org/mpris/MediaPlayer2",
                                    "org.mpris.MediaPlayer2.Player.Previous"]
                                navProc.running = false
                                navProc.running = true
                            }
                        }
                    }

                    Item {
                        id: mBtnFolder
                        width: 30; height: 30
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.fill: parent; radius: 8
                            color: mFolderMa.containsMouse ? "#301e1e2e" : "transparent"
                            border { color: mFolderMa.containsMouse ? "#601e1e2e" : "transparent"; width: 1 }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "\uf07c"
                            color: mFolderMa.containsMouse ? pywalColors.color4 : "#aaaaaa"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: mFolderMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.openFolder()
                        }
                    }

                    Item {
                        id: mBtnNext
                        width: 30; height: 30
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            anchors.fill: parent; radius: 8
                            color: mNextMa.containsMouse ? "#301e1e2e" : "transparent"
                            border { color: mNextMa.containsMouse ? "#601e1e2e" : "transparent"; width: 1 }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "\uf04e"
                            color: mNextMa.containsMouse ? pywalColors.color4 : "#aaaaaa"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 12
                        }
                        MouseArea {
                            id: mNextMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                navProc.command = ["dbus-send", "--session", "--type=method_call",
                                    "--dest=org.mpris.MediaPlayer2.mpv",
                                    "/org/mpris/MediaPlayer2",
                                    "org.mpris.MediaPlayer2.Player.Next"]
                                navProc.running = false
                                navProc.running = true
                            }
                        }
                    }
                }

                // ─── Equalizer bars ───

                Item {
                    width: parent.width
                    height: 22

                    Repeater {
                        model: 14
                        Rectangle {
                            width: 3
                            height: 4 + Math.min(root.cavaBars[13 - index] / 700, 1) * 18
                            x: (parent.width - 94) / 2 + index * 7
                            anchors.bottom: parent.bottom
                            radius: 1.5
                            color: pywalColors.color4
                            opacity: 0.7
                            Behavior on height {
                                NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                            }
                        }
                    }
                }

                // ─── Separator ───

                Rectangle {
                    width: 80; height: 1
                    color: "#30ffffff"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                // ─── Equalizer ───

                Item {
                    width: parent.width
                    height: 90

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        spacing: 2

                        Repeater {
                            model: 10
                            Item {
                                width: 14; height: 70

                                Slider {
                                    id: eqSlider
                                    anchors.fill: parent
                                    orientation: Qt.Vertical
                                    from: -12; to: 12; stepSize: 0.5
                                    value: root.eqGains[index]
                                    onMoved: {
                                        var gains = root.eqGains
                                        gains[index] = value
                                        root.eqGains = gains
                                        eqProc.command = ["sh", root._dir + "eq-control.sh", "set-band", index.toString(), value.toString()]
                                        eqProc.running = false
                                        eqProc.running = true
                                    }

                                    background: Rectangle {
                                        x: parent.width / 2 - width / 2
                                        width: 4; height: parent.height
                                        radius: 2
                                        color: "#20ffffff"

                                        Rectangle {
                                            width: parent.width
                                            height: Math.max(0, (1 - eqSlider.visualPosition) * parent.height)
                                            y: eqSlider.visualPosition * parent.height
                                            radius: 2
                                            color: pywalColors.color4
                                            opacity: 0.6
                                        }
                                    }

                                    handle: Rectangle {
                                        x: parent.width / 2 - width / 2
                                        y: eqSlider.visualPosition * (parent.height - height)
                                        width: 10; height: 10
                                        radius: 5
                                        color: eqSlider.pressed ? pywalColors.color5 : pywalColors.color4
                                    }
                                }

                                // Freq label
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.bottom
                                    anchors.topMargin: 2
                                    text: ["60", "170", "315", "600", "1K", "3K", "6K", "12K", "14K", "16K"][index]
                                    color: pywalColors.color5
                                    font.pixelSize: 6
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }
                    }
                }

                // ─── EQ Controls ───

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    // On/Off
                    Item {
                        width: 40; height: 18
                        Rectangle {
                            anchors.fill: parent; radius: 4
                            color: eqBtnMa.containsMouse ? "#301e1e2e" : "transparent"
                            border { color: root.eqEnabled ? pywalColors.color4 : "#30ffffff"; width: 1 }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: root.eqEnabled ? "EQ" : "EQ"
                            color: root.eqEnabled ? pywalColors.color4 : "#aaaaaa"
                            font.pixelSize: 8
                            font.bold: true
                        }
                        MouseArea {
                            id: eqBtnMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.eqEnabled = !root.eqEnabled
                                eqProc.command = ["sh", root._dir + "eq-control.sh", root.eqEnabled ? "enable" : "disable"]
                                eqProc.running = false
                                eqProc.running = true
                            }
                        }
                    }

                    // Preset selector
                    Item {
                        width: 56; height: 18
                        Rectangle {
                            anchors.fill: parent; radius: 4
                            color: presetMa.containsMouse ? "#301e1e2e" : "transparent"
                            border { color: "#30ffffff"; width: 1 }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "Preset"
                            color: "#aaaaaa"
                            font.pixelSize: 8
                        }
                        MouseArea {
                            id: presetMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                presetMenu.visible = !presetMenu.visible
                            }
                        }

                        // Preset dropdown
                        Column {
                            id: presetMenu
                            visible: false
                            anchors.top: parent.bottom
                            anchors.topMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            z: 100

                            Rectangle {
                                width: 80; height: 20; radius: 3
                                color: presetRockMa.containsMouse ? "#401e1e2e" : "#301e1e2e"
                                Text { anchors.centerIn: parent; text: "Rock"; color: pywalColors.foreground; font.pixelSize: 8 }
                                MouseArea { id: presetRockMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { eqProc.command = ["sh", root._dir + "eq-control.sh", "preset", "rock"]; eqProc.running = false; eqProc.running = true; presetMenu.visible = false }
                                }
                            }
                            Rectangle {
                                width: 80; height: 20; radius: 3
                                color: presetPopMa.containsMouse ? "#401e1e2e" : "#301e1e2e"
                                Text { anchors.centerIn: parent; text: "Pop"; color: pywalColors.foreground; font.pixelSize: 8 }
                                MouseArea { id: presetPopMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { eqProc.command = ["sh", root._dir + "eq-control.sh", "preset", "pop"]; eqProc.running = false; eqProc.running = true; presetMenu.visible = false }
                                }
                            }
                            Rectangle {
                                width: 80; height: 20; radius: 3
                                color: presetClassicalMa.containsMouse ? "#401e1e2e" : "#301e1e2e"
                                Text { anchors.centerIn: parent; text: "Classical"; color: pywalColors.foreground; font.pixelSize: 8 }
                                MouseArea { id: presetClassicalMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { eqProc.command = ["sh", root._dir + "eq-control.sh", "preset", "classical"]; eqProc.running = false; eqProc.running = true; presetMenu.visible = false }
                                }
                            }
                            Rectangle {
                                width: 80; height: 20; radius: 3
                                color: presetFlatMa.containsMouse ? "#401e1e2e" : "#301e1e2e"
                                Text { anchors.centerIn: parent; text: "Flat"; color: pywalColors.foreground; font.pixelSize: 8 }
                                MouseArea { id: presetFlatMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: { eqProc.command = ["sh", root._dir + "eq-control.sh", "preset", "flat"]; eqProc.running = false; eqProc.running = true; presetMenu.visible = false }
                                }
                            }
                        }
                    }

                    // Reset
                    Item {
                        width: 20; height: 18
                        Rectangle {
                            anchors.fill: parent; radius: 4
                            color: resetMa.containsMouse ? "#301e1e2e" : "transparent"
                            border { color: "#30ffffff"; width: 1 }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "\uf021"
                            color: "#aaaaaa"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 8
                        }
                        MouseArea {
                            id: resetMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.eqGains = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                                for (var i = 0; i < 10; i++) {
                                    eqProc.command = ["sh", root._dir + "eq-control.sh", "set-band", i.toString(), "0"]
                                    eqProc.running = false
                                    eqProc.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: folderProc
        command: []
        running: false
    }

    Process {
        id: eqProc
        command: []
        running: false
    }

    Process {
        id: navProc
        command: []
        running: false
    }

    Process {
        id: coverProc
        command: []
        running: false
        stdout: StdioCollector { id: coverCol; waitForEnd: true }
        onExited: {
            var out = coverCol.text.trim()
            root.coverPath = out.length > 0 ? out : ""
        }
    }

    Process {
        id: cavaProc
        command: ["sh", root._dir + "cava-read.sh"]
        running: false
    }

    Connections {
        target: root
        function onShowingMusicChanged() {
            if (root.showingMusic) {
                cavaProc.running = true
            } else {
                cavaProc.running = false
            }
        }
    }

    Process {
        id: cavaReader
        command: ["cat", "/tmp/cava_bars"]
        running: false
        stdout: StdioCollector { id: cavaCol; waitForEnd: true }
        onExited: {
            var line = cavaCol.text.trim()
            if (line.length === 0) return
            var parts = line.split(";").filter(function(s) { return s.length > 0 })
            var bars = []
            for (var i = 0; i < 14 && i < parts.length; i++) {
                bars.push(parseInt(parts[i]) || 0)
            }
            while (bars.length < 14) bars.push(0)
            root.cavaBars = bars
        }
    }

    Timer {
        interval: 33
        running: root.showingMusic
        repeat: true
        onTriggered: cavaReader.running = false, cavaReader.running = true
    }

    function openFolder() {
        folderProc.command = ["sh", "-c", "dir=$(zenity --file-selection --directory --title='Seleccionar música') && [ -n \"$dir\" ] && mpv --no-video \"$dir\""]
        folderProc.running = false
        folderProc.running = true
    }

    QtObject {
        id: musicPlayer

        property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

        function findActive() {
            var list = Mpris.players.values
            for (var i = 0; i < list.length; i++) {
                if (list[i] && list[i].isPlaying) return list[i]
            }
            return list.length > 0 ? list[0] : null
        }

        function updateState() {
            var p = findActive()
            player = p
            root.musicActive = (p !== null && p.isPlaying)

            if (p && p.metadata) {
                var url = p.metadata["xesam:url"] || ""
                if (url && url !== root.lastTrackUrl) {
                    root.lastTrackUrl = url
                    coverProc.command = ["sh", root._dir + "find-cover.sh", url]
                    coverProc.running = false
                    coverProc.running = true
                }
            }
        }
    }

    Connections {
        target: Mpris.players
        function onValuesChanged() { musicPlayer.updateState() }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: musicPlayer.updateState()
    }

    IpcHandler {
        target: "wallclock-control"
        function toggleMusic(): void {
            root.showingMusic = !root.showingMusic
        }
    }

    // ─── System stats (bottom-center) ───

    PanelWindow {
        anchors { bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        implicitHeight: 120

        WlrLayershell.layer: WlrLayer.Bottom

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            spacing: 16

            RingArc {
                value: root.cpuTemp / 100
                displayText: root.cpuTemp + "\u00B0"
                label: "CPU"
                arcColor: root.cpuTemp < 60 ? pywalColors.color4 : root.cpuTemp < 80 ? "#ffaa00" : "#ff4444"
            }

            RingArc {
                value: root.gpuTemp / 100
                displayText: root.gpuTemp + "\u00B0"
                label: "GPU"
                arcColor: root.gpuTemp < 60 ? pywalColors.color4 : root.gpuTemp < 80 ? "#ffaa00" : "#ff4444"
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

    Timer {
        id: pollTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: poller.running = true
    }

    Process {
        id: poller
        command: [root._dir + "stats.sh"]
        running: false

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
    }
}

import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Window

ShellRoot {
    PanelWindow {
        anchors.top: true
        anchors.left: true
        exclusionMode: ExclusionMode.Ignore
        color: "#ff4444"
        width: 120
        height: 80
        WlrLayershell.namespace: "qs-wallclock-test"
        WlrLayershell.layer: WlrLayer.Overlay

        Text {
            anchors.centerIn: parent
            text: "TEST"
            color: "#ffffff"
            font.pixelSize: 20
        }
    }
}

import QtQuick

Item {
    id: root
    property real value: 0.0
    property real lineWidth: 5
    property color arcColor: "#3dd1b0"
    property color bgColor: "#22ffffff"
    property string displayText: ""
    property string label: ""
    property int labelSize: 11
    property int valueSize: 18

    implicitWidth: 88
    implicitHeight: 88

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = width / 2
            var cy = height / 2
            var radius = Math.min(cx, cy) - root.lineWidth / 2 - 2
            var startAngle = 3 * Math.PI / 4
            var sweep = 3 * Math.PI / 2
            var endAngle = Math.PI / 4

            ctx.beginPath()
            ctx.arc(cx, cy, radius, startAngle, endAngle, false)
            ctx.lineWidth = root.lineWidth
            ctx.strokeStyle = root.bgColor
            ctx.lineCap = "round"
            ctx.stroke()

            if (root.value > 0) {
                ctx.beginPath()
                var fillEnd = startAngle + Math.min(root.value, 1.0) * sweep
                ctx.arc(cx, cy, radius, startAngle, fillEnd, false)
                ctx.strokeStyle = root.arcColor
                ctx.lineCap = "round"
                ctx.stroke()
            }
        }
    }

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 2
        spacing: -2

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.displayText
            color: "#f5c842"
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: root.valueSize
            font.bold: true
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.label
            color: "#d4a017"
            style: Text.Outline
            styleColor: "#80000000"
            font.pixelSize: root.labelSize
        }
    }

    onValueChanged: canvas.requestPaint()
    onArcColorChanged: canvas.requestPaint()
}

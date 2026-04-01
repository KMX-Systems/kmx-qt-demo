import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root

    width: 980
    height: 640
    title: qsTr("Monitoring Window")
    visible: false

    // Repaint canvas whenever the C++ Engine updates workload
    Connections {
        target: engine
        function onWorkloadChanged() { monitoringCanvas.requestPaint() }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0d0d0d" }
            GradientStop { position: 1.0; color: "#1a1a1a" }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Label {
            text: qsTr("Live Monitoring")
            color: "#dbeafe"
            font.pixelSize: 24
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                radius: 8
                color: "#1d4ed8"
                Label {
                    anchors.centerIn: parent
                    text: qsTr("Workload\n%1%").arg(engine.workload)
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                radius: 8
                color: "#0f766e"
                Label {
                    anchors.centerIn: parent
                    text: qsTr("Users\n%1").arg(engine.activeUsers)
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                radius: 8
                color: "#b45309"
                Label {
                    anchors.centerIn: parent
                    text: qsTr("Alerts\n%1").arg(engine.alerts)
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Label { text: qsTr("Traffic trend"); color: "#e2e8f0" }

                Canvas {
                    id: monitoringCanvas
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    onPaint: {
                        var ctx = getContext("2d")
                        var w = width
                        var h = height
                        var trend = engine.trendData()
                        var trendA = trend[0]
                        var trendB = trend[1]

                        ctx.reset()
                        ctx.fillStyle = "#141414"
                        ctx.fillRect(0, 0, w, h)

                        ctx.strokeStyle = "#333333"
                        ctx.lineWidth = 1
                        for (var i = 0; i <= 5; ++i) {
                            var y = (h - 20) * i / 5 + 10
                            ctx.beginPath()
                            ctx.moveTo(10, y)
                            ctx.lineTo(w - 10, y)
                            ctx.stroke()
                        }

                        function drawSeries(values, color) {
                            ctx.strokeStyle = color
                            ctx.lineWidth = 3
                            ctx.beginPath()
                            for (var j = 0; j < values.length; ++j) {
                                var x = 20 + (w - 40) * j / (values.length - 1)
                                var yy = h - 20 - (h - 40) * values[j] / 100
                                if (j === 0)
                                    ctx.moveTo(x, yy)
                                else
                                    ctx.lineTo(x, yy)
                            }
                            ctx.stroke()
                        }

                        drawSeries(trendA, "#38bdf8")
                        drawSeries(trendB, "#22c55e")
                    }
                }
            }
        }

        Timer {
            interval: 900
            running: root.visible
            repeat: true
            onTriggered: monitoringCanvas.requestPaint()
        }
    }
}

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property int workload: 0
    property int activeUsers: 0
    property int alerts: 0
    property string themeText: ""
    property var notificationsModel

    onWorkloadChanged: trafficCanvas.requestPaint()

    SplitView {
        anchors.fill: parent

        Frame {
            SplitView.preferredWidth: 420

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Label {
                    text: qsTr("System KPIs")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#e2e8f0"
                }

                GridLayout {
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 86
                        color: "#1d4ed8"
                        radius: 8
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("Workload\n%1%").arg(root.workload)
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 86
                        color: "#0f766e"
                        radius: 8
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("Users\n%1").arg(root.activeUsers)
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 86
                        color: "#b45309"
                        radius: 8
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("Alerts\n%1").arg(root.alerts)
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 86
                        color: "#6d28d9"
                        radius: 8
                        Label {
                            anchors.centerIn: parent
                            text: qsTr("Theme\n%1").arg(root.themeText)
                            horizontalAlignment: Text.AlignHCenter
                            color: "white"
                        }
                    }
                }

                Label { text: qsTr("Recent Notifications"); color: "#e2e8f0" }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.notificationsModel
                    spacing: 6
                    delegate: Rectangle {
                        id: notificationDelegate
                        required property string level
                        required property string message
                        width: ListView.view.width
                        height: 46
                        radius: 6
                        color: notificationDelegate.level === "Critical" ? "#7f1d1d" : "#242424"
                        border.color: "#4b5563"

                        Row {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            Label { text: notificationDelegate.level; color: "#bfdbfe" }
                            Label { text: notificationDelegate.message; color: "#e5e7eb" }
                        }
                    }
                }
            }
        }

        Frame {
            SplitView.fillWidth: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Label {
                    text: qsTr("Traffic Graphs")
                    font.pixelSize: 22
                    font.bold: true
                    color: "#e2e8f0"
                }

                Frame {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 8

                        Label { text: qsTr("Inbound / Outbound (Canvas graph)"); color: "#e2e8f0" }

                        Canvas {
                            id: trafficCanvas
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            onPaint: {
                                var ctx = getContext("2d")
                                var w = width
                                var h = height
                                var inbound = [14, 28, 43, 55, 72, 62, 79]
                                var outbound = [10, 26, 36, 46, 58, 50, 67]

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

                                drawSeries(inbound, "#38bdf8")
                                drawSeries(outbound, "#22c55e")
                            }
                        }

                        RowLayout {
                            Label { text: qsTr("Inbound");  color: "#38bdf8" }
                            Label { text: qsTr("Outbound"); color: "#22c55e" }
                        }
                    }
                }

                Frame {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 220

                    RowLayout {
                        anchors.fill: parent
                        spacing: 14

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            Label { text: qsTr("Service distribution (bar graph)"); color: "#e2e8f0" }

                            Repeater {
                                model: [
                                    {"name": "API", "value": 28, "color": "#2563eb"},
                                    {"name": "UI", "value": 18, "color": "#0ea5e9"},
                                    {"name": "DB", "value": 22, "color": "#16a34a"},
                                    {"name": "Queue", "value": 12, "color": "#f59e0b"}
                                ]

                                delegate: RowLayout {
                                    id: serviceRow
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Label { text: serviceRow.modelData.name; Layout.preferredWidth: 50; color: "#e2e8f0" }
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 18
                                        color: "#252525"
                                        radius: 4

                                        Rectangle {
                                            width: parent.width * serviceRow.modelData.value / 30
                                            height: parent.height
                                            color: serviceRow.modelData.color
                                            radius: 4
                                        }
                                    }
                                    Label { text: serviceRow.modelData.value + "%"; Layout.preferredWidth: 42; color: "#a0a0a0" }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

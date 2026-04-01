pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var userModel
    property int workload: 0

    RowLayout {
        anchors.fill: parent
        spacing: 10

        Frame {
            Layout.preferredWidth: 500
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Label {
                    text: qsTr("Team Directory")
                    font.pixelSize: 20
                    font.bold: true
                    color: "#e2e8f0"
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.userModel
                    spacing: 6

                    delegate: Frame {
                        id: userDelegate
                        required property string name
                        required property string role
                        required property string status
                        width: ListView.view.width
                        height: 62
                        RowLayout {
                            anchors.fill: parent
                            Label { text: userDelegate.name; Layout.preferredWidth: 120; color: "#e2e8f0" }
                            Label { text: userDelegate.role; Layout.preferredWidth: 120; color: "#a0a0a0" }
                            Label { text: userDelegate.status; Layout.fillWidth: true; color: "#e2e8f0" }
                            Button { text: qsTr("Open") }
                        }
                    }
                }
            }
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Label {
                    text: qsTr("Control Grid")
                    font.pixelSize: 20
                    font.bold: true
                    color: "#e2e8f0"
                }

                GridView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: 150
                    cellHeight: 110
                    model: 12
                    delegate: Rectangle {
                        id: nodeDelegate
                        required property int index
                        width: 130
                        height: 90
                        radius: 8
                        color: nodeDelegate.index % 2 === 0 ? "#1e3a8a" : "#0f766e"
                        border.color: "#93c5fd"

                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            Label { text: qsTr("Node %1").arg(nodeDelegate.index + 1); color: "white" }
                            ProgressBar {
                                width: 90
                                from: 0
                                to: 100
                                value: (nodeDelegate.index * 9 + root.workload) % 100
                            }
                        }
                    }
                }
            }
        }
    }
}

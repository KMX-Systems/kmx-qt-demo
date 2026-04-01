import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root

    required property var backend
    width: 860
    height: 560
    title: qsTr("Analytics Window")
    visible: false

    Rectangle {
        anchors.fill: parent
        color: "#141414"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Label {
            text: qsTr("Expanded Analytics")
            color: "#dbeafe"
            font.pixelSize: 24
            font.bold: true
        }

        Frame {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 8

                Label { text: qsTr("Weekly throughput (custom graph)"); color: "#e2e8f0" }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    Repeater {
                        model: root.backend.weeklyStats()

                        delegate: ColumnLayout {
                            id: dayColumn
                            required property var modelData
                            spacing: 4
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            Item { Layout.fillHeight: true }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: dayColumn.modelData.read * 3
                                color: "#3b82f6"
                            }

                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: dayColumn.modelData.write * 3
                                color: "#14b8a6"
                            }

                            Label {
                                Layout.alignment: Qt.AlignHCenter
                                text: dayColumn.modelData.day
                                color: "#e2e8f0"
                            }
                        }
                    }
                }
            }
        }
    }
}

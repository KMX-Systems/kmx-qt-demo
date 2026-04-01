import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal openAnalyticsRequested()
    signal openOperationsRequested()
    signal openMonitoringRequested()
    signal openSettingsRequested()

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: "#141414"
        border.color: "#333333"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        Label {
            text: qsTr("Window Launcher")
            font.pixelSize: 26
            font.bold: true
            color: "#e2e8f0"
        }

        Label {
            text: qsTr("Open every dedicated workspace window from one place.")
            color: "#94a3b8"
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            columnSpacing: 12
            rowSpacing: 12

            Frame {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    Label { text: qsTr("Analytics"); font.bold: true; color: "#e2e8f0" }
                    Label { text: qsTr("Throughput and comparative graphs"); color: "#94a3b8"; wrapMode: Text.WordWrap }
                    Item { Layout.fillHeight: true }
                    Button {
                        text: qsTr("Open Analytics Window")
                        Layout.fillWidth: true
                        onClicked: root.openAnalyticsRequested()
                    }
                }
            }

            Frame {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    Label { text: qsTr("Operations"); font.bold: true; color: "#e2e8f0" }
                    Label { text: qsTr("Job queue and live logs"); color: "#94a3b8"; wrapMode: Text.WordWrap }
                    Item { Layout.fillHeight: true }
                    Button {
                        text: qsTr("Open Operations Window")
                        Layout.fillWidth: true
                        onClicked: root.openOperationsRequested()
                    }
                }
            }

            Frame {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    Label { text: qsTr("Monitoring"); font.bold: true; color: "#e2e8f0" }
                    Label { text: qsTr("Live KPIs and trend chart"); color: "#94a3b8"; wrapMode: Text.WordWrap }
                    Item { Layout.fillHeight: true }
                    Button {
                        text: qsTr("Open Monitoring Window")
                        Layout.fillWidth: true
                        onClicked: root.openMonitoringRequested()
                    }
                }
            }

            Frame {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    Label { text: qsTr("Settings"); font.bold: true; color: "#e2e8f0" }
                    Label { text: qsTr("Forms, profiles, and security controls"); color: "#94a3b8"; wrapMode: Text.WordWrap }
                    Item { Layout.fillHeight: true }
                    Button {
                        text: qsTr("Open Settings Window")
                        Layout.fillWidth: true
                        onClicked: root.openSettingsRequested()
                    }
                }
            }
        }
    }
}

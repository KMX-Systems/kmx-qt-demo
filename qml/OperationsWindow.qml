pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root

    required property var backend
    width: 700
    height: 520
    title: qsTr("Operations Window")
    visible: false

    Rectangle {
        anchors.fill: parent
        color: "#141414"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Label {
            text: qsTr("Operations Console")
            font.pixelSize: 22
            font.bold: true
            color: "#e2e8f0"
        }

        TabBar {
            id: operationsTabs
            Layout.fillWidth: true
            TabButton { text: qsTr("Jobs") }
            TabButton { text: qsTr("Logs") }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: operationsTabs.currentIndex

            ListView {
                id: jobsList
                clip: true
                model: root.backend.jobModel
                delegate: Frame {
                    id: jobEntry
                    required property string label
                    required property int progress
                    required property string statusText
                    required property int index
                    width: ListView.view.width
                    height: 56
                    RowLayout {
                        anchors.fill: parent
                        Label { text: jobEntry.label;      Layout.preferredWidth: 110; color: "#e2e8f0" }
                        ProgressBar { Layout.fillWidth: true; from: 0; to: 100; value: jobEntry.progress }
                        Label { text: jobEntry.statusText; Layout.preferredWidth: 70;  color: "#a0a0a0" }
                        Button { text: qsTr("Run"); onClicked: root.backend.runJob(jobEntry.index) }
                    }
                }
            }

            TextArea {
                readOnly: true
                text: root.backend.exportReport()
            }
        }
    }
}

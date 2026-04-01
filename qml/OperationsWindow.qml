import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root

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
                clip: true
                model: engine.jobModel
                delegate: Frame {
                    width: ListView.view.width
                    height: 56
                    RowLayout {
                        anchors.fill: parent
                        Label { text: model.label;      Layout.preferredWidth: 110; color: "#e2e8f0" }
                        ProgressBar { Layout.fillWidth: true; from: 0; to: 100; value: model.progress }
                        Label { text: model.statusText; Layout.preferredWidth: 70;  color: "#a0a0a0" }
                        Button { text: qsTr("Run"); onClicked: engine.runJob(index) }
                    }
                }
            }

            TextArea {
                readOnly: true
                text: engine.exportReport()
            }
        }
    }
}

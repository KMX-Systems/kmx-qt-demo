import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    signal openCommandDialogRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label {
            text: qsTr("Slide Deck")
            font.pixelSize: 22
            font.bold: true
            color: "#e2e8f0"
        }

        SwipeView {
            id: slideView
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                color: "#1d4ed8"
                radius: 8
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Label { text: qsTr("Slide 1"); color: "white"; font.pixelSize: 24; font.bold: true }
                    Label { text: qsTr("Overview with key controls"); color: "white" }
                }
            }

            Rectangle {
                color: "#0f766e"
                radius: 8
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Label { text: qsTr("Slide 2"); color: "white"; font.pixelSize: 24; font.bold: true }
                    Slider {
                        id: slideSlider
                        width: 260
                        from: 0
                        to: 100
                        value: 40
                    }
                    Label { text: qsTr("Value: %1").arg(slideSlider.value.toFixed(0)); color: "white" }
                }
            }

            Rectangle {
                color: "#7c2d12"
                radius: 8
                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Label { text: qsTr("Slide 3"); color: "white"; font.pixelSize: 24; font.bold: true }
                    Button { text: qsTr("Open command dialog"); onClicked: root.openCommandDialogRequested() }
                }
            }
        }

        PageIndicator {
            Layout.alignment: Qt.AlignHCenter
            count: slideView.count
            currentIndex: slideView.currentIndex
        }
    }
}

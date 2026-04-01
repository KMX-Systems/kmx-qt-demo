import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property real dialValue: 55
    signal showAboutRequested()
    signal dialValueEdited(real value)

    ScrollView {
        anchors.fill: parent

        ColumnLayout {
            width: parent.width
            spacing: 14

            GroupBox {
                title: qsTr("Input Controls")
                Layout.fillWidth: true
                palette.windowText: "#e2e8f0"
                palette.text: "#e2e8f0"
                palette.buttonText: "#e2e8f0"

                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    columnSpacing: 10
                    rowSpacing: 8

                    TextField { placeholderText: qsTr("Host name") }
                    TextField { placeholderText: qsTr("Port") }
                    ComboBox { model: ["HTTP", "HTTPS", "gRPC"] }

                    SpinBox { from: 1; to: 100; value: 12 }
                    Slider { from: 0; to: 100; value: 60 }
                    Dial {
                        from: 0
                        to: 100
                        value: root.dialValue
                        onMoved: root.dialValueEdited(value)
                    }

                    RangeSlider {
                        first.value: 20
                        second.value: 85
                        Layout.columnSpan: 2
                    }
                    Label { text: qsTr("Range"); color: "#e2e8f0" }
                }
            }

            GroupBox {
                title: qsTr("Toggles and Modes")
                Layout.fillWidth: true
                palette.windowText: "#e2e8f0"
                palette.text: "#e2e8f0"
                palette.buttonText: "#e2e8f0"

                RowLayout {
                    anchors.fill: parent
                    spacing: 18

                    Column {
                        spacing: 8
                        CompactCheckBox { text: qsTr("Enable logs");   checked: true }
                        CompactCheckBox { text: qsTr("Enable alerts") }
                        Switch   { text: qsTr("Live updates");  checked: true }
                    }

                    Column {
                        spacing: 8
                        ButtonGroup { id: modeGroup }
                        RadioButton { text: qsTr("Mode A"); checked: true; ButtonGroup.group: modeGroup }
                        RadioButton { text: qsTr("Mode B"); ButtonGroup.group: modeGroup }
                        RadioButton { text: qsTr("Mode C"); ButtonGroup.group: modeGroup }
                    }

                    Column {
                        spacing: 8
                        Tumbler {
                            model: [qsTr("Low"), qsTr("Normal"), qsTr("High"), qsTr("Critical")]
                            visibleItemCount: 3
                            height: 90
                            width: 100
                        }
                    }
                }
            }

            GroupBox {
                title: qsTr("Progress and Text")
                Layout.fillWidth: true
                palette.windowText: "#e2e8f0"
                palette.text: "#e2e8f0"
                palette.buttonText: "#e2e8f0"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    ProgressBar {
                        from: 0
                        to: 100
                        value: root.dialValue
                        Layout.fillWidth: true
                    }

                    TextArea {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 120
                        placeholderText: qsTr("Describe rollout notes...")
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Button { text: qsTr("Save");     onClicked: engine.applyConfig({"cpuBudget": Math.round(root.dialValue), "memoryBudget": 68}) }
                        Button { text: qsTr("Deploy");   onClicked: engine.postEvent("Info",    qsTr("Deployment started")) }
                        Button { text: qsTr("Rollback"); onClicked: engine.postEvent("Warning", qsTr("Rollback triggered")) }
                        Item { Layout.fillWidth: true }
                        RoundButton { text: "?"; onClicked: root.showAboutRequested() }
                    }
                }
            }
        }
    }
}

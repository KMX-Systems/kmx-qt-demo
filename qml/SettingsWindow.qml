import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: root

    width: 860
    height: 620
    title: qsTr("Settings Window")
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
            text: qsTr("Settings and Forms")
            color: "#e2e8f0"
            font.pixelSize: 24
            font.bold: true
        }

        TabBar {
            id: settingsTabs
            Layout.fillWidth: true
            TabButton { text: qsTr("General") }
            TabButton { text: qsTr("Accounts") }
            TabButton { text: qsTr("Security") }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: settingsTabs.currentIndex

            ScrollView {
                clip: true
                ColumnLayout {
                    width: parent.width
                    spacing: 12

                    GroupBox {
                        title: qsTr("Environment")
                        Layout.fillWidth: true
                        GridLayout {
                            anchors.fill: parent
                            columns: 2
                            TextField { placeholderText: qsTr("Organization") }
                            TextField { placeholderText: qsTr("Region") }
                            ComboBox { model: [qsTr("Production"), qsTr("Staging"), qsTr("Development")] }
                            SpinBox { from: 1; to: 20; value: 4 }
                        }
                    }

                    GroupBox {
                        title: qsTr("Behavior")
                        Layout.fillWidth: true
                        RowLayout {
                            anchors.fill: parent
                            Switch { text: qsTr("Auto save"); checked: true }
                            Switch { text: qsTr("Notifications"); checked: true }
                            CompactCheckBox { text: qsTr("Verbose logs") }
                        }
                    }

                    GroupBox {
                        title: qsTr("Limits")
                        Layout.fillWidth: true
                        ColumnLayout {
                            anchors.fill: parent
                            Label { text: qsTr("CPU budget"); color: "#e2e8f0" }
                            Slider { id: cpuSlider; from: 0; to: 100; value: engine.cpuBudget }
                            Label { text: qsTr("Memory budget"); color: "#e2e8f0" }
                            Slider { id: memorySlider; from: 0; to: 100; value: engine.memoryBudget }
                        }
                    }

                    GroupBox {
                        title: qsTr("Language")
                        Layout.fillWidth: true
                        RowLayout {
                            anchors.fill: parent
                            Label { text: qsTr("Interface language"); color: "#e2e8f0" }
                            ComboBox {
                                model: ["English", "Română"]
                                onActivated: {
                                    var locales = ["en", "ro"]
                                    engine.setLanguage(locales[currentIndex])
                                }
                            }
                        }
                    }
                }
            }

            ScrollView {
                clip: true
                ColumnLayout {
                    width: parent.width
                    spacing: 12

                    GroupBox {
                        title: qsTr("User Profile")
                        Layout.fillWidth: true
                        GridLayout {
                            anchors.fill: parent
                            columns: 2
                            TextField { placeholderText: qsTr("First name") }
                            TextField { placeholderText: qsTr("Last name") }
                            TextField { placeholderText: qsTr("Email") }
                            ComboBox { model: [qsTr("Admin"), qsTr("Editor"), qsTr("Viewer")] }
                            TextField {
                                placeholderText: qsTr("Date (YYYY-MM-DD)")
                                text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                            }
                            TextField {
                                placeholderText: qsTr("Time (HH:MM)")
                                text: Qt.formatTime(new Date(), "hh:mm")
                            }
                        }
                    }

                    GroupBox {
                        title: qsTr("Preferences")
                        Layout.fillWidth: true
                        RowLayout {
                            anchors.fill: parent
                            ButtonGroup { id: densityGroup }
                            RadioButton { text: qsTr("Compact");     checked: true; ButtonGroup.group: densityGroup }
                            RadioButton { text: qsTr("Comfortable"); ButtonGroup.group: densityGroup }
                            RadioButton { text: qsTr("Expanded");    ButtonGroup.group: densityGroup }
                        }
                    }
                }
            }

            ScrollView {
                clip: true
                ColumnLayout {
                    width: parent.width
                    spacing: 12

                    GroupBox {
                        title: qsTr("Authentication")
                        Layout.fillWidth: true
                        GridLayout {
                            anchors.fill: parent
                            columns: 2
                            TextField { placeholderText: qsTr("Username") }
                            TextField { placeholderText: qsTr("Token"); echoMode: TextInput.Password }
                            CompactCheckBox { text: qsTr("Enable MFA"); checked: true }
                            ComboBox { model: ["TOTP", "SMS", qsTr("Hardware key")] }
                        }
                    }

                    GroupBox {
                        title: qsTr("Session Controls")
                        Layout.fillWidth: true
                        RowLayout {
                            anchors.fill: parent
                            DelayButton { text: qsTr("Expire all sessions"); delay: 1800 }
                            Button { text: qsTr("Rotate keys") }
                            Button { text: qsTr("Audit") }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Item { Layout.fillWidth: true }
            Button { text: qsTr("Discard") }
            Button { text: qsTr("Apply");  onClicked: engine.applyConfig({"cpuBudget": Math.round(cpuSlider.value), "memoryBudget": Math.round(memorySlider.value)}) }
            Button { text: qsTr("Save");   onClicked: engine.applyConfig({"cpuBudget": Math.round(cpuSlider.value), "memoryBudget": Math.round(memorySlider.value)}) }
        }
    }
}

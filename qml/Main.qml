import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    width: 1360
    height: 860
    visible: true
    title: qsTr("KMX Qt Demo")

    required property var backend
    property real dialValue: 55
    property color uiLightGray: "#c7ced8"

    Shortcut { sequence: "Ctrl+1"; onActivated: tabs.currentIndex = 0 }
    Shortcut { sequence: "Ctrl+2"; onActivated: tabs.currentIndex = 1 }
    Shortcut { sequence: "Ctrl+3"; onActivated: tabs.currentIndex = 2 }
    Shortcut { sequence: "Ctrl+4"; onActivated: tabs.currentIndex = 3 }
    Shortcut { sequence: "Ctrl+5"; onActivated: tabs.currentIndex = 4 }

    Shortcut { sequence: "Ctrl+Shift+A"; onActivated: analyticsWindow.visible = true }
    Shortcut { sequence: "Ctrl+Shift+O"; onActivated: operationsWindow.visible = true }
    Shortcut { sequence: "Ctrl+Shift+M"; onActivated: monitoringWindow.visible = true }
    Shortcut { sequence: "Ctrl+Shift+S"; onActivated: settingsWindow.visible = true }
    Shortcut { sequence: "Ctrl+Shift+C"; onActivated: commandDialog.open() }
    Shortcut { sequence: "Ctrl+Shift+L"; onActivated: tabs.currentIndex = 4 }

    menuBar: MenuBar {
        palette.windowText: root.uiLightGray
        palette.buttonText: root.uiLightGray
        palette.text: root.uiLightGray

        Menu {
            title: qsTr("File")
            Action { text: qsTr("Open analytics window");  onTriggered: analyticsWindow.visible = true }
            Action { text: qsTr("Open operations window"); onTriggered: operationsWindow.visible = true }
            Action { text: qsTr("Open monitoring window"); onTriggered: monitoringWindow.visible = true }
            Action { text: qsTr("Open settings window");   onTriggered: settingsWindow.visible = true }
            MenuSeparator {}
            Action { text: qsTr("Quit"); onTriggered: Qt.quit() }
        }
        Menu {
            title: qsTr("View")
            Action { text: qsTr("Toggle navigation drawer"); onTriggered: sideDrawer.opened ? sideDrawer.close() : sideDrawer.open() }
            Action { text: qsTr("Show about dialog");        onTriggered: aboutDialog.open() }
        }
        Menu {
            title: qsTr("Tools")
            Action { text: qsTr("Open command dialog"); onTriggered: commandDialog.open() }
            Action { text: qsTr("Show quick popup");    onTriggered: quickPopup.open() }
        }
    }

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 10

            ToolButton {
                text: qsTr("Menu")
                onClicked: sideDrawer.opened ? sideDrawer.close() : sideDrawer.open()
            }

            ToolSeparator {}

            ToolButton { text: qsTr("Analytics"); onClicked: analyticsWindow.visible = true }
            ToolButton { text: qsTr("Ops");        onClicked: operationsWindow.visible = true }
            ToolButton { text: qsTr("Monitor");    onClicked: monitoringWindow.visible = true }
            ToolButton { text: qsTr("Settings");   onClicked: settingsWindow.visible = true }
            ToolButton { text: qsTr("Command");    onClicked: commandDialog.open() }

            Item { Layout.fillWidth: true }

            Label {
                text: qsTr("Theme")
                color: "#dbeafe"
            }

            ComboBox {
                id: themeBox
                model: ["Ocean", "Sunset", "Contrast"]
            }

            RoundButton {
                text: "+"
                onClicked: root.backend.postEvent("Info", qsTr("Manual event at %1").arg(Qt.formatTime(new Date(), "hh:mm:ss")))
            }
        }
    }

    footer: Frame {
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 14

            Label { text: qsTr("Status: Running"); color: root.uiLightGray }
            Label { text: qsTr("Users: %1").arg(root.backend.activeUsers);  color: root.uiLightGray }
            Label { text: qsTr("Alerts: %1").arg(root.backend.alerts); color: root.uiLightGray }

            ProgressBar {
                Layout.fillWidth: true
                from: 0
                to: 100
                value: root.backend.workload
            }

            BusyIndicator {
                running: root.backend.autoRefresh
            }
        }
    }

    Drawer {
        id: sideDrawer
        width: Math.min(root.width * 0.28, 360)
        height: root.height

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Label {
                text: qsTr("Navigation")
                font.pixelSize: 20
                font.bold: true
                color: "#e2e8f0"
            }

            Button { text: qsTr("Dashboard");         onClicked: tabs.currentIndex = 0 }
            Button { text: qsTr("Controls");          onClicked: tabs.currentIndex = 1 }
            Button { text: qsTr("Data");              onClicked: tabs.currentIndex = 2 }
            Button { text: qsTr("Slides");            onClicked: tabs.currentIndex = 3 }
            Button { text: qsTr("Launcher");          onClicked: tabs.currentIndex = 4 }
            Button { text: qsTr("Monitoring Window"); onClicked: monitoringWindow.visible = true }
            Button { text: qsTr("Settings Window");   onClicked: settingsWindow.visible = true }

            Item { Layout.fillHeight: true }

            Switch {
                id: autoRefreshSwitch
                text: qsTr("Auto refresh")
                checked: root.backend.autoRefresh
                onCheckedChanged: root.backend.autoRefresh = checked
            }

            DelayButton {
                text: qsTr("Safe reset")
                delay: 1400
                onActivated: root.backend.resetSystem()
            }
        }
    }

    Dialog {
        id: aboutDialog
        title: qsTr("About this demo")
        modal: true
        standardButtons: Dialog.Ok
        parent: Overlay.overlay
        x: Math.round(((parent ? parent.width : root.width) - width) / 2)
        y: Math.round(((parent ? parent.height : root.height) - height) / 2)
        contentWidth: 380
        contentHeight: aboutDialogText.implicitHeight

        Label {
            id: aboutDialogText
            text: qsTr("Qt Quick Controls + C++ Engine demo\nApp version: %1").arg(root.backend.appVersion)
            width: aboutDialog.contentWidth
            wrapMode: Text.WordWrap
        }
    }

    Dialog {
        id: commandDialog
        title: qsTr("Quick command")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        parent: Overlay.overlay
        x: Math.round(((parent ? parent.width : root.width) - width) / 2)
        y: Math.round(((parent ? parent.height : root.height) - height) / 2)
        contentWidth: 420

        ColumnLayout {
            width: commandDialog.contentWidth
            spacing: 10

            Label { text: qsTr("Create event") }
            TextField { id: commandInput; placeholderText: qsTr("Type command name") }
            ComboBox { id: levelBox; model: ["Info", "Warning", "Critical"] }
            Slider {
                id: prioritySlider
                from: 1
                to: 5
                stepSize: 1
                value: 3
            }
            Label { text: qsTr("Priority: %1").arg(prioritySlider.value.toFixed(0)) }
        }

        onAccepted: {
            if (commandInput.text.length > 0)
                root.backend.postEvent(levelBox.currentText, commandInput.text)
        }
    }

    Popup {
        id: quickPopup
        x: root.width - width - 20
        y: 80
        width: 280
        height: 150
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "#1a1a1a"
            border.color: "#444444"
        }

        Column {
            anchors.centerIn: parent
            spacing: 10
            Label { text: qsTr("Quick actions"); color: "#e5e7eb" }
            Button { text: qsTr("Open Analytics");  onClicked: analyticsWindow.visible = true }
            Button { text: qsTr("Open Monitoring"); onClicked: monitoringWindow.visible = true }
            Button { text: qsTr("Open Settings");   onClicked: settingsWindow.visible = true }
            Button { text: qsTr("Close");           onClicked: quickPopup.close() }
        }
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
        anchors.margins: 12
        spacing: 10

        TabBar {
            id: tabs
            Layout.fillWidth: true
            TabButton { text: qsTr("Dashboard") }
            TabButton { text: qsTr("Controls") }
            TabButton { text: qsTr("Data") }
            TabButton { text: qsTr("Slides") }
            TabButton { text: qsTr("Launcher") }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabs.currentIndex

            DashboardPage {
                workload: root.backend.workload
                activeUsers: root.backend.activeUsers
                alerts: root.backend.alerts
                themeText: themeBox.currentText
                notificationsModel: root.backend.notificationModel
            }

            ControlsPage {
                backend: root.backend
                dialValue: root.dialValue
                onShowAboutRequested: aboutDialog.open()
                onDialValueEdited: (v) => root.dialValue = v
            }

            DataPage {
                userModel: root.backend.userModel
                workload: root.backend.workload
            }

            SlidesPage {
                onOpenCommandDialogRequested: commandDialog.open()
            }

            LauncherPage {
                onOpenAnalyticsRequested: analyticsWindow.visible = true
                onOpenOperationsRequested: operationsWindow.visible = true
                onOpenMonitoringRequested: monitoringWindow.visible = true
                onOpenSettingsRequested: settingsWindow.visible = true
            }
        }
    }

    AnalyticsWindow {
        id: analyticsWindow
        backend: root.backend
    }

    OperationsWindow {
        id: operationsWindow
        backend: root.backend
    }

    MonitoringWindow {
        id: monitoringWindow
        backend: root.backend
    }

    SettingsWindow {
        id: settingsWindow
        backend: root.backend
    }
}

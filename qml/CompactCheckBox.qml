import QtQuick
import QtQuick.Controls

CheckBox {
    id: control

    spacing: 6
    padding: 0
    topPadding: 0
    bottomPadding: 0
    leftPadding: indicator.width + spacing
    rightPadding: 0
    font.pixelSize: 12

    indicator: Rectangle {
        implicitWidth: 14
        implicitHeight: 14
        x: control.mirrored ? control.width - width : 0
        y: Math.round((control.height - height) / 2)
        radius: 2
        border.width: 1
        border.color: control.enabled ? "#9ca3af" : "#6b7280"
        color: control.checked ? "#60a5fa" : "transparent"

        Rectangle {
            anchors.centerIn: parent
            visible: control.checked
            width: 6
            height: 6
            radius: 1
            color: "#0b1220"
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.enabled ? "#e2e8f0" : "#94a3b8"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
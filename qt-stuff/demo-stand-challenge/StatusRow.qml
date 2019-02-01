import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Row {
    property alias text: lbl.text
    property alias color: val.color

    Layout.alignment: Qt.AlignRight
    spacing: 10
    Text {
        id: lbl
        text: "status:"
        font.pointSize: root.primaryFontSize
    }
    Rectangle {
        id: val
        color: "green"
        width: height
        height: parent.height
        radius: height / 2
        border.width: 1
    }
}

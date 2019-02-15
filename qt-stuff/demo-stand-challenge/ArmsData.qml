import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

GridLayout {
    property alias statusLeft: statusLeft.color
    property alias statusRight: statusRight.color
    property alias xLeft: xLeft.text
    property alias xRight: xRight.text
    property alias yLeft: yLeft.text
    property alias yRight: yRight.text
    property alias zLeft: zLeft.text
    property alias zRight: zRight.text
    property alias yawLeft: yawLeft.text
    property alias yawRight: yawRight.text
    property alias pitchLeft: pitchLeft.text
    property alias pitchRight: pitchRight.text
    property alias rollLeft: rollLeft.text
    property alias rollRight: rollRight.text
    property bool calibrationNeededLeft: true
    property bool calibrationNeededRight: true

    rows: 8
    columns: 3
    rowSpacing: 10
    columnSpacing: 15

    Text {
        Layout.row: 1
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        font.bold: true
        text: "left"
    }
    Item {
        Layout.row: 1
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
    }
    Text {
        Layout.row: 1
        Layout.column: 3
        Layout.alignment: Qt.AlignLeft
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        font.bold: true
        text: "right"
    }

    // status
    Rectangle {
        id: statusLeft
        Layout.row: 2
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        color: "red"
        width: height
        height: statusLabel.height
        radius: height / 2
        border.width: 1
    }
    Text {
        id: statusLabel
        Layout.row: 2
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: root.secondaryFontSize
        font.bold: true
        text: "status"
    }
    Rectangle {
        id: statusRight
        Layout.row: 2
        Layout.column: 3
        color: "red"
        width: height
        height: statusLabel.height
        radius: height / 2
        border.width: 1
    }

    // x
    Text {
        id: xLeft
        Layout.row: 3
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }
    Text {
        Layout.row: 3
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: root.secondaryFontSize
        font.bold: true
        text: "x"
    }
    Text {
        id: xRight
        Layout.row: 3
        Layout.column: 3
        Layout.alignment: Qt.AlignLeft
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }

    // y
    Text {
        id: yLeft
        Layout.row: 4
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }
    Text {
        Layout.row: 4
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: root.secondaryFontSize
        font.bold: true
        text: "y"
    }
    Text {
        id: yRight
        Layout.row: 4
        Layout.column: 3
        Layout.alignment: Qt.AlignLeft
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }

    // z
    Text {
        id: zLeft
        Layout.row: 5
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }
    Text {
        Layout.row: 5
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: root.secondaryFontSize
        font.bold: true
        text: "z"
    }
    Text {
        id: zRight
        Layout.row: 5
        Layout.column: 3
        Layout.alignment: Qt.AlignLeft
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }

    // yaw
    Text {
        id: yawLeft
        Layout.row: 6
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }
    Text {
        Layout.row: 6
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: root.secondaryFontSize
        font.bold: true
        text: "yaw"
    }
    Text {
        id: yawRight
        Layout.row: 6
        Layout.column: 3
        Layout.alignment: Qt.AlignLeft
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }

    // pitch
    Text {
        id: pitchLeft
        Layout.row: 7
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }
    Text {
        Layout.row: 7
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: root.secondaryFontSize
        font.bold: true
        text: "pitch"
    }
    Text {
        id: pitchRight
        Layout.row: 7
        Layout.column: 3
        Layout.alignment: Qt.AlignLeft
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }

    // roll
    Text {
        id: rollLeft
        Layout.row: 8
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }
    Text {
        Layout.row: 8
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: root.secondaryFontSize
        font.bold: true
        text: "roll"
    }
    Text {
        id: rollRight
        Layout.row: 8
        Layout.column: 3
        Layout.alignment: Qt.AlignLeft
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "0"
    }

    // calibration
    Text {
        id: calibrationNeededLeft

        Layout.row: 9
        Layout.column: 1
        Layout.alignment: Qt.AlignRight
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "-"
    }
    Text {
        Layout.row: 9
        Layout.column: 2
        Layout.alignment: Qt.AlignHCenter
        font.pointSize: root.secondaryFontSize
        font.bold: true
        text: "calibNeed"
    }
    Text {
        id: calibrationNeededRight
        Layout.row: 9
        Layout.column: 3
        Layout.alignment: Qt.AlignLeft
        font.pointSize: root.secondaryFontSize
        font.family: "Courier New"
        text: "-"
    }
}

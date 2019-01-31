import QtQuick 2.12
import QtQuick.Controls 2.12

Button {
    id: btn

    property string unpressedColor: "#41CD52"
    property string pressedColor: "#16A81A"

    topPadding: 15
    leftPadding: 25
    rightPadding: 25
    bottomPadding: 15

    contentItem: Text {
        text: btn.text
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: btn.font.pointSize
        color: "white"
    }

    background: Rectangle {
        id: btn_backg
        color: btn.enabled ? (btn.pressed ? pressedColor : unpressedColor) : "#ccc"
        radius: 10
        border.color: pressedColor
        border.width: btn.enabled ? 1 : 0
    }
}

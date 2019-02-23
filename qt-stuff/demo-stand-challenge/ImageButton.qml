import QtQuick 2.12
import QtQuick.Controls 2.12

Image {
    id: btn

    property alias text: txt.text
    property alias fontSize: txt.font.pointSize
    property alias tapEnabled: tap.enabled
    property string unpressedImage: "qrc:/img/button-start.png"
    property string pressedImage: "qrc:/img/button-pressed.png"
    property string unpressedColor: "black"
    property string pressedColor: "white"

    signal clicked

    source: btn.enabled ? (tap.pressed ? pressedImage : unpressedImage) : "qrc:/img/button-disabled.png"
    fillMode: Image.PreserveAspectFit

    Text {
        id: txt
        anchors.centerIn: parent
        font.pointSize: root.calculateFontSize(btn.paintedWidth, 0.04)
        font.family: typodermic.name
        color: btn.enabled ? (tap.pressed ? pressedColor : unpressedColor) : "gray"
        text: "BUTTON"
    }

    TapHandler {
        id: tap
        onTapped: {
            clicked();
        }
    }
}

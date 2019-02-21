import QtQuick 2.12
import QtQuick.Controls 2.12

Image {
    id: btn

    property alias text: txt.text
    property string unpressedImage: "qrc:/img/button-start.png"

    signal clicked

    source: btn.enabled ? (tap.pressed ? "qrc:/img/button-pressed.png" : unpressedImage) : "qrc:/img/button-disabled.png"
    fillMode: Image.PreserveAspectFit

    Text {
        id: txt
        anchors.centerIn: parent
        font.pointSize: root.primaryFontSize
        font.family: typodermic.name
        color: btn.enabled ? (tap.pressed ? "white" : "black") : "gray"
        text: "BUTTON"
    }

    TapHandler {
        id: tap
        onTapped: {
            clicked();
        }
    }
}

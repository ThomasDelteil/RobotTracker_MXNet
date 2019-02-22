import QtQuick 2.12

Image {
    sourceSize.width: width
    sourceSize.height: width
    fillMode: Image.PreserveAspectFit
    source: "qrc:/img/check-box.png"

    property bool checkState: false

    Image {
        id: checkmark
        anchors.fill: parent
        anchors.margins: 5
        fillMode: Image.PreserveAspectFit
        source: "qrc:/img/check-mark.png"
        visible: checkState
    }
}

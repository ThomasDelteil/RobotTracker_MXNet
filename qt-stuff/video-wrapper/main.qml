import QtQuick 2.12
import QtQuick.Window 2.12
import QtMultimedia 5.12

Window {
    visible: true
    width: 900
    height: 500
    title: qsTr("CamTest")

    Camera {
        id: camera
        viewfinder.resolution: Qt.size(640, 480)
    }
    Binding {
        target: wrapper
        property: "source"
        value: camera
    }
    VideoOutput {
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        source: wrapper
    }
}

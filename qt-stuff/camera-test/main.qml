import QtQuick 2.11
import QtQuick.Window 2.11
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtMultimedia 5.11

ApplicationWindow {
    id: root
    visible: true
    width: 900
    minimumWidth: 700
    height: 500
    minimumHeight: 400
    title: qsTr("Camera test")

    property bool cameraUpsideDown: false // if you need to rotate viewfinder to 180

    Rectangle {
        anchors.fill: parent

        Text {
            id: cameraStatus
            anchors.centerIn: parent
            width: parent.width
            text: qsTr("loading camera...")
            font.pixelSize: 40
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        Camera {
            id: camera
            //cameraState: tabCamera.checked ? Camera.ActiveState : Camera.LoadedState
            //viewfinder.resolution: Qt.size(848, 480) // picture quality
            metaData.orientation: cameraUpsideDown ? 180 : 0

//            focus {
//                focusMode: Camera.FocusMacro
//                focusPointMode: Camera.FocusPointCenter
//            }

            imageCapture {
                onCaptureFailed: {
                    console.log("Some error taking a picture\n", message);
                }
                onImageCaptured: {
                    //console.log("photo has been captured")
                }
                onImageSaved: {
                    //console.log("photo has been saved:", camera.imageCapture.capturedImagePath)
                }
            }

            onError: {
                cameraStatus.text = qsTr("Error: ") + errorString;
                console.log(errorCode, errorString);
            }

            Component.onCompleted: {
                console.log(qsTr("camera orientation:"), camera.orientation);
                console.log(qsTr("camera state:"), camera.cameraState);
                console.log(qsTr("camera status:"), camera.cameraStatus);
                console.log(qsTr("camera supported resolutions:"), imageCapture.supportedResolutions);

//                var supRezes = camera.supportedViewfinderResolutions();
//                for (var rez in supRezes)
//                {
//                    console.log(supRezes[rez].width, "x", supRezes[rez].height);
//                }
            }
        }

        VideoOutput {
            anchors.fill: parent
            orientation: cameraUpsideDown ? 180 : 0
            fillMode: VideoOutput.PreserveAspectCrop
            source: camera
        }
    }

//    Component.onCompleted: {
//        console.log("stopping the camera...");
//        camera.stop();
//        console.log("starting the camera...");
//        camera.start();
//        console.log("started the camera");
//    }
}

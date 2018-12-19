import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12

Item {
    signal finishedTrial

    ColumnLayout {
        anchors.fill: parent
        //anchors.margins: 5
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.7
            color: root.backgroundColor

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
                metaData.orientation: root.cameraUpsideDown ? 180 : 0

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
//                    console.log(qsTr("camera orientation:"), camera.orientation);
//                    console.log(qsTr("camera state:"), camera.cameraState);
//                    console.log(qsTr("camera status:"), camera.cameraStatus);
//                    console.log(qsTr("camera supported resolutions:"), imageCapture.supportedResolutions);
                }
            }

            VideoOutput {
                anchors.fill: parent
                orientation: root.cameraUpsideDown ? 180 : 0
                fillMode: VideoOutput.PreserveAspectCrop
                source: camera
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.33
            spacing: 0

            Rectangle {
                Layout.preferredWidth: parent.width * 0.7
                Layout.fillHeight: true
                color: root.backgroundColor
                //border.width: 1

//                Rectangle {
//                    anchors.centerIn: parent
//                    width: parent.width * 0.6
//                    height: parent.height * 0.7
//                    radius: 10

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 30

                        FancyButton {
                            id: btn_start
                            //Layout.alignment: Qt.AlignHCenter
                            unpressedColor: "#0096FF"
                            pressedColor: "#3679CC"
                            text: "Start"
                            font.pixelSize: root.primaryFontSize * 2
                            onClicked: {
                                btn_start.enabled = false;
                            }
                        }

                        FancyButton {
                            id: btn_stop
                            //Layout.alignment: Qt.AlignHCenter
                            unpressedColor: "#FF2600"
                            pressedColor: "#B5331E"
                            text: "Stop"
                            font.pixelSize: root.primaryFontSize * 2
                            enabled: !btn_start.enabled
                            onClicked: {
                                btn_start.enabled = true;
                            }
                        }
                    }
//                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: root.backgroundColor
                //color: "blue"
                //border.width: 1

                FancyButton {
                    anchors.centerIn: parent
                    unpressedColor: "#008F00"
                    pressedColor: "#2C641B"
                    text: "Done"
                    font.pixelSize: root.primaryFontSize * 3
                    enabled: !btn_stop.enabled
                    onClicked: {
                        finishedTrial();
                    }
                }
            }
        }
    }
}

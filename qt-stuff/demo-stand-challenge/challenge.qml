import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12

Item {
    id: chllng
    signal finishedTrial

    function processResults(result)
    {
        appendToOutput(result);

        var jsn = JSON.parse(result);
        thingLeft.x = cameraBackground.width * jsn["lw_x"];
        thingLeft.y = cameraBackground.height * jsn["lw_y"];
        thingRight.x = cameraBackground.width * jsn["rw_x"];
        thingRight.y = cameraBackground.height * jsn["rw_y"];
    }

    function appendToOutput(msg, consoleAsWell = false)
    {
        ta_mxnetOutput.append(msg + "\n---");
        if (consoleAsWell === true) { console.log(msg); }
    }

    property bool readyForNextCapture: true

    ColumnLayout {
        anchors.fill: parent
        //anchors.margins: 5
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.7

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    id: cameraBackground
                    Layout.preferredWidth: parent.width * 0.6
                    Layout.fillHeight: true
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
                        deviceId: "/dev/video0" // QT_GSTREAMER_CAMERABIN_VIDEOSRC="nvcamerasrc ! nvvidconv" ./your-application
                        //cameraState: tabCamera.checked ? Camera.ActiveState : Camera.LoadedState
                        viewfinder.resolution: Qt.size(640, 480) // picture quality
                        metaData.orientation: root.cameraUpsideDown ? 180 : 0

                        //focus {
                        //    focusMode: Camera.FocusMacro
                        //    focusPointMode: Camera.FocusPointCenter
                        //}

                        imageCapture {
                            onCaptureFailed: {
                                appendToOutput("Capture #" + requestId + " error: " + message);
                                //camera.imageCapture.cancelCapture();
                                //console.log("Some error taking a picture: ", message);
                            }
                            onImageCaptured: {
                                // TODO try to send frames without saving them to disk
                                //console.log("photo has been captured: ", requestId, preview) // image://camera/preview_1
                                readyForNextCapture = true;
                            }
                            onImageSaved: {
                                //console.log("photo has been saved:", path)
                                appendToOutput("Sending #" + requestId + " to MXNet");
                                backend.uploadFile(root.mxNetEndpoint, path);
                            }
                        }

                        onError: {
                            cameraStatus.text = qsTr("Error: ") + errorString;
                            console.log(errorCode, errorString);
                        }

//                        onAvailabilityChanged: {
//                            console.log(camera.availability);
//                        }
//                        onCameraStateChanged: {
//                            console.log(camera.cameraState);
//                        }
//                        onCameraStatusChanged: {
//                            console.log(camera.cameraStatus);
//                        }


                        Component.onCompleted: {
                            //console.log(qsTr("camera orientation:"), camera.orientation);
                            //console.log(qsTr("camera state:"), camera.cameraState);
                            //console.log(qsTr("camera status:"), camera.cameraStatus);
                            console.log(qsTr("camera supported resolutions:"), imageCapture.supportedResolutions);
                        }
                    }

                    VideoOutput {
                        anchors.fill: parent
                        orientation: root.cameraUpsideDown ? 180 : 0
                        fillMode: VideoOutput.PreserveAspectCrop
                        source: camera
                    }

                    // left thing
                    Rectangle {
                        id: thingLeft
                        x: parent.width / 4
                        y: parent.height / 4
                        width: 40
                        height: 40
                        color: "blue"
                        radius: 20
                        visible: btn_stop.enabled
                        border.width: 3
                        border.color: "white"
                    }
                    // right thing
                    Rectangle {
                        id: thingRight
                        x: parent.width / 1.3
                        y: parent.height / 1.3
                        width: 40
                        height: 40
                        color: "red"
                        radius: 20
                        visible: btn_stop.enabled
                        border.width: 3
                        border.color: "white"
                    }

                    // TODO replace with https://doc-snapshots.qt.io/qt5-dev/qtquickhandlers-index.html (take the ones from 5.12)
//                    MouseArea {
//                        anchors.fill: parent
//                        onPositionChanged: {
//                            //console.log(mouseX, mouseY);
//                            target1.x = mouseX - target1.width / 2;
//                            target1.y = mouseY - target1.height / 2;
//                        }
//                    }
                }

                Rectangle {
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.fillHeight: true
                    color: root.backgroundColor
                    border.width: 1

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 5

                        TextArea {
                            id: ta_mxnetOutput
                            readOnly: true
                            font.pixelSize: root.secondaryFontSize
                            font.family: "Courier New"
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            selectByMouse: true
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.3
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
                            unpressedColor: "#0096FF"
                            pressedColor: "#3679CC"
                            text: "Start"
                            font.pixelSize: root.primaryFontSize * 2
                            onClicked: {
                                btn_start.enabled = false;
                                tm_sendFrame.start();
                            }
                        }

                        FancyButton {
                            id: btn_stop
                            unpressedColor: "#FF2600"
                            pressedColor: "#B5331E"
                            text: "Stop"
                            font.pixelSize: root.primaryFontSize * 2
                            enabled: !btn_start.enabled
                            onClicked: {
                                btn_start.enabled = true;
                                tm_sendFrame.stop();
                                camera.imageCapture.cancelCapture();
                                readyForNextCapture = true;
                            }
                        }

                        FancyButton {
                            id: btn_play
                            unpressedColor: "#0096FF"
                            pressedColor: "#3679CC"
                            text: "Playback"
                            font.pixelSize: root.primaryFontSize * 2
                            enabled: btn_start.enabled
                            onClicked: {
                                btn_start.enabled = false;
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
                        console.log(backend.get_);
                        // TODO also delete shots at application closing
                        backend.deleteProfileFolder();
                    }
                }
            }
        }
    }

    Timer {
        id: tm_sendFrame
        repeat: true
        interval: root.timerRate
        onTriggered: {
            if (readyForNextCapture === true)
            {
                readyForNextCapture = false;
                var reqID = camera.imageCapture.captureToLocation(
                            backend.get_currentProfilePath()
                            + "/"
                            + getCurrentDateTime()
                            + ".jpg"
                            );
                //console.log(reqID);
            }
            else
            {
                chllng.appendToOutput("waiting for the camera, skipping the frame...", true);
                //camera.stop();
                //camera.start();
                //console.log("before: ", camera.imageCapture.errorString.length);
                //camera.imageCapture.cancelCapture();
                //console.log("after: ", camera.imageCapture.errorString.length);
            }
        }
    }
}

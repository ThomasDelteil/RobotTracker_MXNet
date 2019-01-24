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
        trackerOne.x = cameraBackground.width * jsn["lw_x"];
        trackerOne.y = cameraBackground.height * jsn["lw_y"];
        trackerTwo.x = cameraBackground.width * jsn["rw_x"];
        trackerTwo.y = cameraBackground.height * jsn["rw_y"];
    }

    function appendToOutput(msg, consoleAsWell = false)
    {
        // https://bugreports.qt.io/browse/QTCREATORBUG-21884
        //if (consoleAsWell === undefined) { consoleAsWell = false; }

        ta_mxnetOutput.append(msg + "\n---");
        if (consoleAsWell === true) { console.log(msg); }
    }

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
                        deviceId: "/dev/video0" // NVIDIA Jetson TX2: QT_GSTREAMER_CAMERABIN_VIDEOSRC="nvcamerasrc ! nvvidconv" ./your-application
                        viewfinder.resolution: Qt.size(640, 480) // picture quality
                        metaData.orientation: root.cameraUpsideDown ? 180 : 0

                        //focus {
                        //    focusMode: Camera.FocusMacro
                        //    focusPointMode: Camera.FocusPointCenter
                        //}

                        onError: {
                            cameraStatus.text = qsTr("Error: ") + errorString;
                            console.log(errorCode, errorString);
                        }


                        Component.onCompleted: {
                            //console.log(qsTr("camera orientation:"), camera.orientation);
                            //console.log(qsTr("camera state:"), camera.cameraState);
                            //console.log(qsTr("camera status:"), camera.cameraStatus);
                            console.log(qsTr("camera supported resolutions:"), imageCapture.supportedResolutions);
                        }
                    }

                    Binding {
                        target: backend.videoWrapper
                        property: "source"
                        value: camera
                    }

                    VideoOutput {
                        anchors.fill: parent
                        orientation: root.cameraUpsideDown ? 180 : 0
                        fillMode: VideoOutput.PreserveAspectCrop
                        source: backend.videoWrapper
                    }

                    // tracker #1
                    Rectangle {
                        id: trackerOne
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
                    // tracker #2
                    Rectangle {
                        id: trackerTwo
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
            backend.enableSendingToMXNet(true);
        }
    }
}

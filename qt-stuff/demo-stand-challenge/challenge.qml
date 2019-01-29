import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12

Item {
    id: chllng

    property int currentFPSvalue_camera: 0
    property int currentFPSvalue_trackers: 0

    signal nextWindow(string windowName)

    function processResults(result)
    {
        appendToOutput(result, false);

        var jsn = JSON.parse(result);
        trackerOne.x = cameraBackground.width * jsn["lw_x"];
        trackerOne.y = cameraBackground.height * jsn["lw_y"];
        trackerTwo.x = cameraBackground.width * jsn["rw_x"];
        trackerTwo.y = cameraBackground.height * jsn["rw_y"];
    }

    // https://bugreports.qt.io/browse/QTCREATORBUG-21884
    //function appendToOutput(msg, panelAsWell = false)
    function appendToOutput(msg, panelAsWell)
    {
        if (panelAsWell === undefined) { panelAsWell = false; }

        if (root.debugOutput === true)
        {
            console.log(msg);
            if (panelAsWell === true) { ta_mxnetOutput.append(msg + "\n---"); }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        //anchors.margins: 5
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.8

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    id: cameraBackground
                    Layout.preferredWidth: root.debugOutput ? parent.width * 0.6 : parent.width
                    Layout.fillWidth: !root.debugOutput
                    Layout.fillHeight: true
                    color: root.backgroundColor

                    Text {
                        id: cameraStatus
                        anchors.centerIn: parent
                        width: parent.width
                        text: qsTr("loading camera...")
                        font.pointSize: 40
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

                        /* // animation
                        Behavior on x {
                            NumberAnimation {
                                //duration: 10
                                easing.type: Easing.OutQuart
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                //duration: 10
                                easing.type: Easing.OutQuart
                            }
                        }
                        */
                    }
                    // tracker #2
                    Rectangle {
                        id: trackerTwo
                        x: parent.width / 1.3
                        y: parent.height / 1.3
                        width: 40
                        height: 40
                        color: "green"
                        radius: 20
                        visible: btn_stop.enabled
                        border.width: 3
                        border.color: "white"

                        /* // animation
                        Behavior on x {
                            NumberAnimation {
                                duration: 10
                                easing.type: Easing.OutQuart
                            }
                        }
                        Behavior on y {
                            NumberAnimation {
                                duration: 10
                                easing.type: Easing.OutQuart
                            }
                        }
                        */
                    }

                    Text {
                        id: fpsCounter_camera
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.topMargin: 10
                        anchors.leftMargin: 15
                        text: "0"
                        font.pointSize: 40
                        color: "yellow"
                        visible: root.fpsCounters
                    }
                    Text {
                        id: fpsCounter_trackers
                        anchors.top: fpsCounter_camera.bottom
                        anchors.left: fpsCounter_camera.left
                        text: "0"
                        font.pointSize: 40
                        color: "red"
                        //visible: btn_stop.enabled
                        visible: root.fpsCounters
                    }
                }

                Rectangle {
                    Layout.preferredWidth: parent.width * 0.4
                    Layout.fillHeight: true
                    color: root.backgroundColor
                    border.width: 1
                    visible: root.debugOutput

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 5

                        TextArea {
                            id: ta_mxnetOutput
                            readOnly: true
                            font.pointSize: root.secondaryFontSize
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
            Layout.preferredHeight: parent.height * 0.2
            spacing: 20

            FancyButton {
                id: btn_start
                Layout.leftMargin: 15
                unpressedColor: "#0096FF"
                pressedColor: "#3679CC"
                text: "Start"
                font.pointSize: root.primaryFontSize * 1.5
                onClicked: {
                    startChallenge();
                }
            }

            FancyButton {
                id: btn_stop
                unpressedColor: "#FF2600"
                pressedColor: "#B5331E"
                text: "Stop"
                font.pointSize: root.primaryFontSize * 1.5
                enabled: !btn_start.enabled
                onClicked: {
                    stopChallenge();
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

//            FancyButton {
//                id: btn_play
//                unpressedColor: "#0096FF"
//                pressedColor: "#3679CC"
//                text: "Playback"
//                font.pointSize: root.primaryFontSize * 1.5
//                enabled: btn_start.enabled
//                onClicked: {
//                    btn_start.enabled = false;
//                }
//            }

            FancyButton {
                Layout.rightMargin: 15
                unpressedColor: "#008F00"
                pressedColor: "#2C641B"
                text: "Done"
                font.pointSize: root.primaryFontSize * 2.5
                enabled: !btn_stop.enabled
                onClicked: {
                    nextWindow("welcome.qml");
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

    Timer {
        id: tm_fpsCounter
        running: root.fpsCounters
        repeat: true
        interval: 1000
        onTriggered: {
            fpsCounter_camera.text = currentFPSvalue_camera;
            currentFPSvalue_camera = 0;

            fpsCounter_trackers.text = currentFPSvalue_trackers;
            currentFPSvalue_trackers = 0;
        }
    }

    function startChallenge()
    {
        btn_start.enabled = false;
        tm_sendFrame.start();
    }

    function stopChallenge()
    {
        btn_start.enabled = true;
        tm_sendFrame.stop();
        currentFPSvalue_trackers = 0;
    }
}

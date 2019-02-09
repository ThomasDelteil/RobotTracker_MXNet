import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12

Item {
    id: chllng

    property int currentFPSvalue_camera: 0
    property int currentFPSvalue_trackers: 0

    property real trackerOneX: cameraBackground.width / 4
    property real trackerOneY: cameraBackground.height / 4
    property real trackerTwoX: cameraBackground.width / 1.3
    property real trackerTwoY: cameraBackground.height / 1.3

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

    //function appendToOutput(msg, panelAsWell = false)
    function appendToOutput(msg, panelAsWell)
    {
        // https://bugreports.qt.io/browse/QTCREATORBUG-21884
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
                    z: 1

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
                            //console.log("camera orientation:", camera.orientation);
                            //console.log("camera state:", camera.cameraState);
                            //console.log("camera status:", camera.cameraStatus);
                            /*
                            console.log("camera supported IC resolutions:", imageCapture.supportedResolutions);
                            console.log("camera supported VF resolutions:");
                            var supRezes = camera.supportedViewfinderResolutions();
                            for (var rez in supRezes)
                            {
                                console.log(supRezes[rez].width, "x", supRezes[rez].height);
                            }
                            */
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
                        x: trackerOneX
                        y: trackerOneY
                        width: 40
                        height: 40
                        color: "blue"
                        radius: 20
                        visible: root.manualTrackers || btn_stop.enabled
                        border.width: 3
                        border.color: "white"

                        DragHandler {
                            enabled: root.manualTrackers
                            onActiveChanged: {
                                if (active) // dragging started
                                {
                                    chllng.trackerOneX = trackerOne.x;
                                    chllng.trackerOneY = trackerOne.y;
                                }
                                else // dragging stopped
                                {
                                    var xMovement = checkXmovement(translation.x, trackerOne),
                                        yMovement = checkYmovement(translation.y, trackerOne);

                                    if (xMovement === 0) { trackerOne.x = chllng.trackerOneX; }
                                    if (yMovement === 0) { trackerOne.y = chllng.trackerOneY; }

                                    appendToOutput("Left arm movement: ".concat(xMovement, " | ", yMovement), true);
                                }
                            }
                            //onTranslationChanged: {
                            //    console.log(translation)
                            //}
                        }

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
                        x: trackerTwoX
                        y: trackerTwoY
                        width: 40
                        height: 40
                        color: "green"
                        radius: 20
                        visible: root.manualTrackers || btn_stop.enabled
                        border.width: 3
                        border.color: "white"

                        DragHandler {
                            enabled: root.manualTrackers
                            onActiveChanged: {
                                if (active) // dragging started
                                {
                                    chllng.trackerTwoX = trackerTwo.x;
                                    chllng.trackerTwoY = trackerTwo.y;
                                }
                                else // dragging stopped
                                {
                                    var xMovement = checkXmovement(translation.x, trackerTwo),
                                        yMovement = checkYmovement(translation.y, trackerTwo);

                                    if (xMovement === 0) { trackerTwo.x = chllng.trackerTwoX; }
                                    if (yMovement === 0) { trackerTwo.y = chllng.trackerTwoY; }

                                    appendToOutput("Right arm movement: ".concat(xMovement, " | ", yMovement), true);
                                }
                            }
                            //onTranslationChanged: {
                            //    console.log(translation)
                            //}
                        }

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
            Layout.leftMargin: 15
            Layout.rightMargin: 15
            spacing: 20

            FancyButton {
                id: btn_start
                unpressedColor: "#0096FF"
                pressedColor: "#3679CC"
                text: "Start"
                font.pointSize: root.primaryFontSize * 1.5
                visible: enabled
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
                visible: enabled
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

    function checkXmovement(val, tracker)
    {
        /*
        if (tracker.x < cameraBackground.x)
        {
            tracker.x = cameraBackground.x;
            return 0;
        }
        if (tracker.x > cameraBackground.width)
        {
            tracker.x = cameraBackground.width - tracker.width;
            return 1;
        }
        */
        if (tracker.x + tracker.width / 2 < cameraBackground.x || tracker.x - tracker.width / 2 > cameraBackground.width)
        {
            return 0;
        }
        return (val / cameraBackground.width).toFixed(3);
    }

    function checkYmovement(val, tracker)
    {
        /*
        if (tracker.y < cameraBackground.y)
        {
            tracker.y = cameraBackground.y;
            return 0;
        }
        if (tracker.y > cameraBackground.height)
        {
            tracker.y = cameraBackground.height - tracker.height;
            return 1;
        }
        */
        if (tracker.y + tracker.height / 2 < cameraBackground.y || tracker.y - tracker.height / 2 > cameraBackground.height)
        {
            return 0;
        }
        return (val / cameraBackground.height).toFixed(3);
    }
}

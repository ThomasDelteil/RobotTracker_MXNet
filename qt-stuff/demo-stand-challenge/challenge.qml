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

        trackerLeft.x = originalFrame.width * jsn["lw_x"] - root.trackerWidth/2;
        trackerLeft.y = originalFrame.height * jsn["lw_y"] - root.trackerWidth/2;
        gotNewCoordinates(trackerLeft);

        trackerRight.x = originalFrame.width * jsn["rw_x"] - root.trackerWidth/2;
        trackerRight.y = originalFrame.height * jsn["rw_y"] - root.trackerWidth/2;
        gotNewCoordinates(trackerRight);

        for (var i in jsn["skeleton"])
        {
            if (jsn["skeleton"][i]["name"] === "left_elbow")
            {
                cropRegionLeft.x = originalFrame.width * (jsn["lw_x"] + (jsn["lw_x"] - jsn["skeleton"][i]["x"]) / 2) - root.cropRegionWidth/2;
                cropRegionLeft.y = originalFrame.height * (jsn["lw_y"] + (jsn["lw_y"] - jsn["skeleton"][i]["y"]) / 2) - root.cropRegionWidth/2;
            }
            if (jsn["skeleton"][i]["name"] === "right_elbow")
            {
                cropRegionRight.x = originalFrame.width * (jsn["rw_x"] + (jsn["rw_x"] - jsn["skeleton"][i]["x"]) / 2) - root.cropRegionWidth/2;
                cropRegionRight.y = originalFrame.height * (jsn["rw_y"] + (jsn["rw_y"] - jsn["skeleton"][i]["y"]) / 2) - root.cropRegionWidth/2;
            }
        }

        //crop_pos = wrist_pos + (wrist_pos - elbow_pos) / 2
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

                            //console.log("camera supported IC resolutions:", imageCapture.supportedResolutions);
                            /*
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
                        id: vo
                        anchors.fill: parent
                        orientation: root.cameraUpsideDown ? 180 : 0
                        fillMode: VideoOutput.PreserveAspectFit//PreserveAspectCrop
                        source: backend.videoWrapper

                        Rectangle {
                            id: originalFrame
                            anchors.centerIn: parent
                            width: parent.contentRect.width
                            height: parent.contentRect.height
                            color: "transparent"

                            // tracker #1 (left hand)
                            Rectangle {
                                id: trackerLeft
                                property string name: "left"
                                x: originalFrame.width/4 - width/2
                                y: originalFrame.height/1.3 - height/2
                                width: root.trackerWidth
                                height: width
                                color: "blue"
                                radius: width * 0.5
                                visible: root.manualTrackers || btn_stop.enabled
                                border.width: 2
                                border.color: "white"

                                DragHandler {
                                    enabled: root.manualTrackers
                                    onActiveChanged: {
                                        if (!active) // dragging stopped
                                        {
                                            gotNewCoordinates(parent);
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
                            // tracker #2 (right hand)
                            Rectangle {
                                id: trackerRight
                                property string name: "right"
                                x: originalFrame.width/1.3 - width/2
                                y: originalFrame.height/1.3 - height/2
                                width: root.trackerWidth
                                height: width
                                color: "green"
                                radius: width * 0.5
                                visible: root.manualTrackers || btn_stop.enabled
                                border.width: 2
                                border.color: "white"

                                DragHandler {
                                    enabled: root.manualTrackers
                                    onActiveChanged: {
                                        if (!active) // dragging stopped
                                        {
                                            gotNewCoordinates(parent);
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

                            // crop region for the left hand
                            Rectangle {
                                id: cropRegionLeft
                                x: trackerLeft.x - width/2
                                y: trackerLeft.y - height/2
                                width: root.cropRegionWidth
                                height: root.cropRegionWidth
                                color: "blue"
                                opacity: 0.3
                                visible: btn_stop.enabled
                            }
                            // crop region for the right hand
                            Rectangle {
                                id: cropRegionRight
                                x: trackerRight.x - width/2
                                y: trackerRight.y - height/2
                                width: root.cropRegionWidth
                                height: root.cropRegionWidth
                                color: "green"
                                opacity: 0.3
                                visible: btn_stop.enabled
                            }

                            // FPS counters
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

                            // screen divider, just for convenience
                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                visible: root.manualTrackers

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    border.width: 1
                                    border.color: "blue"
                                    color: "transparent"
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    border.width: 1
                                    border.color: "green"
                                    color: "transparent"
                                }
                            }
                        }
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

    function checkXcoordinate(tracker)
    {
        if (tracker.name === "left")
        {
            if (tracker.x + tracker.width/2 < 0)
            {
                tracker.x = 0;
                return 0;
            }
            if (tracker.x + tracker.width/2  > originalFrame.width/2)
            {
                tracker.x = originalFrame.width/2 - tracker.width;
                return 1;
            }
            return ((tracker.x + tracker.width/2) / (originalFrame.width/2)).toFixed(3);
        }
        else
        {
            if (tracker.x + tracker.width/2 < originalFrame.width/2)
            {
                tracker.x = originalFrame.width/2;
                return 0;
            }
            if (tracker.x + tracker.width/2 > originalFrame.width)
            {
                tracker.x = originalFrame.width - tracker.width;
                return 1;
            }
            return ((tracker.x + tracker.width/2 - originalFrame.width/2) / (originalFrame.width / 2)).toFixed(3);
        }

    }

    function checkYcoordinate(tracker)
    {
        if (tracker.y + tracker.height/2 < 0)
        {
            tracker.y = 0;
            return 0;
        }
        if (tracker.y + tracker.height/2 > originalFrame.height)
        {
            tracker.y = originalFrame.height - tracker.height;
            return 1;
        }
        return ((tracker.y + tracker.height/2) / originalFrame.height).toFixed(3);
    }

    function gotNewCoordinates(tracker)
    {
        var xCoordinate = checkXcoordinate(tracker),
            yCoordinate = checkYcoordinate(tracker);

        appendToOutput("".concat(tracker.name, " movement: ", xCoordinate, " | ", yCoordinate), true);

        moveTheArm(tracker.name, xCoordinate, yCoordinate);
    }

    function moveTheArm(armName, xCoordinate, yCoordinate)
    {
        robotsModel.move({ name: armName }, xCoordinate, yCoordinate)
    }
}

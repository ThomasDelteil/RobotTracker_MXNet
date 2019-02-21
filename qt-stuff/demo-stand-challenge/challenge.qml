import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12

Item {
    id: chllng

    property int currentFPSvalue_camera: 0
    property int currentFPSvalue_trackers: 0

    property alias camera: camera

    signal nextWindow(string windowName)

    function processPoseResults(result) {

        //appendToOutput(result, false);
        var jsn = JSON.parse(result)

        var re_x = jsn["skeleton"]["left_elbow"]["x"]
        var re_y = jsn["skeleton"]["left_elbow"]["y"]
        var rw_x = jsn["skeleton"]["left_wrist"]["x"]
        var rw_y = jsn["skeleton"]["left_wrist"]["y"]
        var le_x = jsn["skeleton"]["right_elbow"]["x"]
        var le_y = jsn["skeleton"]["right_elbow"]["y"]
        var lw_x = jsn["skeleton"]["right_wrist"]["x"]
        var lw_y = jsn["skeleton"]["right_wrist"]["y"]

        var leftTarget = leftCroppingOverlay.mapFromItem(
                    originalFrame, originalFrame.width * lw_x,
                    originalFrame.height * lw_y)

        var rightTarget = rightCroppingOverlay.mapFromItem(
                    originalFrame, originalFrame.width * rw_x,
                    originalFrame.height * rw_y)

        trackerLeft.target = leftTarget
        trackerRight.target = rightTarget

        leftHandCropRegion.x = originalFrame.width * (lw_x + (lw_x - le_x) / 2)
                - backend.cropRegionWidth / 2
        leftHandCropRegion.y = originalFrame.height * (lw_y + (lw_y - le_y) / 2)
                - backend.cropRegionWidth / 2

        //console.log("qml rect:", leftHandCropRegion.x, leftHandCropRegion.y, backend.cropRegionWidth());
        rightHandCropRegion.x = originalFrame.width * (rw_x + (rw_x - re_x) / 2)
                - backend.cropRegionWidth / 2
        rightHandCropRegion.y = originalFrame.height
                * (rw_y + (rw_y - re_y) / 2) - backend.cropRegionWidth / 2
    }

    function processLeftHandResults(result) {
        palmLeft.text = result
        processGrip('left', result)
    }
    function processRightHandResults(result) {
        palmRight.text = result
        processGrip('right', result)
    }

    //function appendToOutput(msg, panelAsWell = false)
    function appendToOutput(msg, panelAsWell) {
        // https://bugreports.qt.io/browse/QTCREATORBUG-21884
        if (panelAsWell === undefined) {
            panelAsWell = false
        }

        if (root.debugOutput === true) {
            console.log(msg)
            if (panelAsWell === true) {
                ta_mxnetOutput.append(msg + "\n---")
            }
        }
    }

    function updateLeftPalmDebug() {
        leftPalmDebug.source = ""
        leftPalmDebug.source = "image://palms/left"
    }

    function updateRightPalmDebug() {
        rightPalmDebug.source = ""
        rightPalmDebug.source = "image://palms/right"
    }

    function delay(cb) {
        updateSourceTimer.triggered.connect(cb)
        updateSourceTimer.start()
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

                        function updateResolution(resolution) {
                            camera.viewfinder.resolution = resolution
                            backend.videoWrapper.frameSize = resolution
                        }

                        // NVIDIA Jetson TX2: QT_GSTREAMER_CAMERABIN_VIDEOSRC="nvcamerasrc ! nvvidconv" ./your-application
                        deviceId: "/dev/video0"

                        metaData.orientation: root.cameraUpsideDown ? 180 : 0

                        onCameraStatusChanged: {
                            console.log("camera status changed to " + camera.cameraStatus)
                        }

                        onCameraStateChanged: {
                            console.log("camera state changed to " + camera.cameraState)

                            if (cameraState != Camera.ActiveState) {
                                return
                            }

                            console.log("Camera supported VF resolutions:")
                            var resolutions = camera.supportedViewfinderResolutions()
                            var resolution = Qt.size(0, 0)
                            if (!resolutions.length) {
                                // this happens on Jetson, try hardcoding it
                                resolution = Qt.size(2592, 1080)
                            } else {
                                resolutions.forEach(function (r) {
                                    console.log(r.width, "x", r.height)
                                    if (r.width > resolution.width) {
                                        resolution = Qt.size(r.width, r.height)
                                    }
                                })
                            }

                            camera.viewfinder.resolution = resolution
                            updateResolution(resolution)
                            console.log("resolution set to " + resolution)
                        }

                        //focus {
                        //    focusMode: Camera.FocusMacro
                        //    focusPointMode: Camera.FocusPointCenter
                        //}
                        onError: {
                            cameraStatus.text = qsTr("Error: ") + errorString
                            console.log(errorCode, errorString)
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
                        // fillMode: VideoOutput.Stretch
                        fillMode: VideoOutput.PreserveAspectFit //PreserveAspectCrop
                        source: backend.videoWrapper

                        Rectangle {
                            id: originalFrame

                            anchors.centerIn: parent
                            width: parent.contentRect.width
                            height: parent.contentRect.height
                            color: "transparent"

                            onWidthChanged: console.log(
                                                'originalFrame size: ' + Qt.size(
                                                    width, height))
                            onHeightChanged: console.log(
                                                 'originalFrame size: ' + Qt.size(
                                                     width, height))

                            /* left robot position */
                            Rectangle {
                                id: robotLeft

                                x: robotsModel.leftArm.mapXFromRobot(
                                       leftCroppingOverlay)
                                y: robotsModel.leftArm.mapYFromRobot(
                                       leftCroppingOverlay)
                                width: root.trackerWidth
                                height: width
                                color: "blue"
                                radius: width * 0.5
                                border.width: 2
                                border.color: "white"
                                opacity: 0.3

                                // animation
                                Behavior on x {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutQuart
                                    }
                                }
                                Behavior on y {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutQuart
                                    }
                                }
                            }

                            /* right robot position */
                            Rectangle {
                                id: robotRight

                                x: robotsModel.rightArm.mapXFromRobot(
                                       leftCroppingOverlay)
                                y: robotsModel.rightArm.mapYFromRobot(
                                       leftCroppingOverlay)
                                width: root.trackerWidth
                                height: width
                                color: "green"
                                radius: width * 0.5
                                border.width: 2
                                border.color: "white"
                                opacity: 0.3

                                // animation
                                Behavior on x {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutQuart
                                    }
                                }
                                Behavior on y {
                                    NumberAnimation {
                                        duration: 100
                                        easing.type: Easing.OutQuart
                                    }
                                }
                            }

                            RowLayout {
                                id: croppingOverlay

                                property int bufferWidth: 100
                                property real overlayOpacity: 0.1

                                anchors.fill: parent

                                Item {
                                    id: leftCroppingOverlay

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Rectangle {
                                        anchors.fill: parent
                                        color: 'blue'
                                        opacity: croppingOverlay.overlayOpacity
                                    }

                                    // tracker #1 (left hand)
                                    Rectangle {
                                        id: trackerLeft
                                        property string name: "left"

                                        property var target: ({
                                                                  "x": originalFrame.width / 4
                                                                       - width / 2,
                                                                  "y": originalFrame.height / 1.3
                                                                       - height / 2
                                                              })

                                        property real proxy: x + y

                                        x: Math.min(Math.max(0, target.x),
                                                    parent.width)
                                        y: Math.min(Math.max(0, target.y),
                                                    parent.height)

                                        width: root.trackerWidth
                                        height: width
                                        color: "blue"
                                        radius: width * 0.5
                                        visible: root.manualTrackers
                                                 || btn_stop.enabled
                                        border.width: 2
                                        border.color: "white"

                                        transform: Translate {
                                            y: -trackerLeft.height / 2
                                            x: -trackerLeft.width / 2
                                        }

                                        onProxyChanged: {
                                            moveTheArm(name, x / parent.width,
                                                       y / parent.height)
                                        }

                                        DragHandler {
                                            id: leftDrag

                                            xAxis {
                                                minimum: 0
                                                maximum: parent.parent.width
                                            }

                                            yAxis {
                                                minimum: 0
                                                maximum: parent.parent.height
                                            }

                                            enabled: true
                                        }

                                        // animation
                                        Behavior on x {
                                            NumberAnimation {
                                                duration: 100
                                                easing.type: Easing.OutQuart
                                            }
                                        }
                                        Behavior on y {
                                            NumberAnimation {
                                                duration: 100
                                                easing.type: Easing.OutQuart
                                            }
                                        }
                                    }
                                }

                                Item {
                                    width: croppingOverlay.bufferWidth
                                    Layout.fillHeight: true
                                }

                                Item {
                                    id: rightCroppingOverlay

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Rectangle {
                                        anchors.fill: parent
                                        color: 'green'
                                        opacity: croppingOverlay.overlayOpacity
                                    }

                                    // tracker #2 (right hand)
                                    Rectangle {
                                        id: trackerRight
                                        property string name: "right"

                                        property var target: ({
                                                                  "x": originalFrame.width / 1.3
                                                                       - width / 2,
                                                                  "y": originalFrame.height / 1.3
                                                                       - height / 2
                                                              })

                                        property real proxy: x + y

                                        x: Math.min(Math.max(0, target.x),
                                                    parent.width)
                                        y: Math.min(Math.max(0, target.y),
                                                    parent.height)

                                        width: root.trackerWidth
                                        height: width
                                        color: "green"
                                        radius: width * 0.5
                                        visible: root.manualTrackers
                                                 || btn_stop.enabled
                                        border.width: 2
                                        border.color: "white"

                                        transform: Translate {
                                            y: -trackerLeft.height / 2
                                            x: -trackerLeft.width / 2
                                        }

                                        onProxyChanged: {
                                            moveTheArm(name, x / parent.width,
                                                       y / parent.height)
                                        }

                                        DragHandler {
                                            id: rightDrag

                                            xAxis {
                                                minimum: 0
                                                maximum: parent.parent.width
                                            }

                                            yAxis {
                                                minimum: 0
                                                maximum: parent.parent.height
                                            }

                                            enabled: true
                                        }

                                        // animation
                                        Behavior on x {
                                            NumberAnimation {
                                                duration: 100
                                                easing.type: Easing.OutQuart
                                            }
                                        }
                                        Behavior on y {
                                            NumberAnimation {
                                                duration: 100
                                                easing.type: Easing.OutQuart
                                            }
                                        }
                                    }
                                }
                            }

                            Image {
                                id: leftPalmDebug

                                width: backend.cropRegionWidth
                                height: width
                                cache: false
                                anchors {
                                    top: parent.top
                                    left: parent.left
                                    margins: 10
                                }
                            }

                            Image {
                                id: rightPalmDebug

                                width: backend.cropRegionWidth
                                height: width
                                cache: false
                                anchors {
                                    top: parent.top
                                    right: parent.right
                                    margins: 10
                                }
                            }

                            // crop region for the left hand
                            Rectangle {
                                id: leftHandCropRegion
                                width: backend.cropRegionWidth
                                height: backend.cropRegionWidth
                                color: "blue"
                                opacity: 0.6
                                visible: btn_stop.enabled

                                Text {
                                    id: palmLeft
                                    anchors.centerIn: parent
                                    font.pointSize: root.primaryFontSize * 3
                                    font.bold: true
                                    color: "white"
                                    text: "2"
                                }
                            }

                            // crop region for the right hand
                            Rectangle {
                                id: rightHandCropRegion
                                width: backend.cropRegionWidth
                                height: backend.cropRegionWidth
                                color: "green"
                                opacity: 0.6
                                visible: btn_stop.enabled

                                Text {
                                    id: palmRight
                                    anchors.centerIn: parent
                                    font.pointSize: root.primaryFontSize * 3
                                    font.bold: true
                                    color: "white"
                                    text: "2"
                                }
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
                    startChallenge()
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
                    stopChallenge()
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                RowLayout {
                    id: scoreLayout
                    anchors.centerIn: parent
                    spacing: 15
                    visible: false

                    FancyButton {
                        topPadding: 10
                        rightPadding: 15
                        bottomPadding: 10
                        leftPadding: 15
                        unpressedColor: "#E0E0E0"
                        pressedColor: "#C1C1C1"
                        text: "-"
                        font.pointSize: root.primaryFontSize
                        onClicked: {
                            var s = parseInt(score.text)
                            if (s > 0) {
                                score.text = s - 1
                            }
                        }
                    }

                    Text {
                        id: score
                        text: "0"
                        font.pointSize: root.primaryFontSize * 2
                    }

                    FancyButton {
                        topPadding: 10
                        rightPadding: 15
                        bottomPadding: 10
                        leftPadding: 15
                        unpressedColor: "#E0E0E0"
                        pressedColor: "#C1C1C1"
                        text: "+"
                        font.pointSize: root.primaryFontSize
                        onClicked: {
                            score.text = parseInt(score.text) + 1
                        }
                    }
                }
            }

            FancyButton {
                unpressedColor: "#008F00"
                pressedColor: "#2C641B"
                text: "Done"
                font.pointSize: root.primaryFontSize * 1.5
                enabled: !btn_stop.enabled
                onClicked: {
                    enabled = false
                    text = "saving..."

                    request("http://".concat(backend.dbServer(),
                                             "/user/saveScore/",
                                             backend.get_currentProfile(), "/",
                                             score.text), "POST", function (o) {
                                                 enabled = true
                                                 text = "Done"

                                                 if (o.status === 200
                                                         || o.responseText === "0") {
                                                     console.log(o.responseText)
                                                 } else {
                                                     console.log("[error] Couldn't save the score. Player ID:",
                                                                 backend.get_currentProfile(
                                                                     ),
                                                                 "| score:",
                                                                 score.text)
                                                     // FIXME dialog never opens
                                                     dialogScoreError.open()
                                                 }

                                                 scoreLayout.visible = false
                                                 score.text = 0

                                                 backend.set_currentProfile(0)

                                                 nextWindow("welcome.qml")
                                             })
                }
            }
        }
    }

    Timer {
        id: tm_sendFrame
        repeat: true
        interval: root.timerRate
        onTriggered: {
            backend.enableSendingToMXNet(true)
        }
    }

    Timer {
        id: tm_fpsCounter
        running: root.fpsCounters
        repeat: true
        interval: 1000
        onTriggered: {
            fpsCounter_camera.text = currentFPSvalue_camera
            currentFPSvalue_camera = 0

            fpsCounter_trackers.text = currentFPSvalue_trackers
            currentFPSvalue_trackers = 0
        }
    }

    Dialog {
        id: dialogScoreError
        x: (parent.width - width) / 2
        y: 0
        modal: true
        width: 400
        height: 250
        standardButtons: Dialog.Close

        title: "Score saving error"

        Item {
            anchors.fill: parent

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    TextArea {
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: "Couldn't save your score! Please, write it down, and we'll save it later"
                        font.family: "Courier New"
                        font.pointSize: root.secondaryFontSize
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }

    function startChallenge() {
        scoreLayout.visible = true
        btn_start.enabled = false
        robotsModel.sendChanges = true
        tm_sendFrame.start()
    }

    function stopChallenge() {
        btn_start.enabled = true
        robotsModel.sendChanges = false
        tm_sendFrame.stop()
        currentFPSvalue_trackers = 0
    }

    function moveTheArm(armName, xCoordinate, yCoordinate) {
        var arm = null
        if (armName === 'left') {
            arm = robotsModel.leftArm
        }
        if (armName === 'right') {
            arm = robotsModel.rightArm
        }

        arm.move(xCoordinate, yCoordinate)
    }

    function processGrip(armName, result) {
        var arm = null
        if (armName === 'left') {
            arm = robotsModel.leftArm
        }
        if (armName === 'right') {
            arm = robotsModel.rightArm
        }

        // @disable-check M126
        if (result == 2) {
            arm.open()
        }

        // @disable-check M126
        if (result == 1) {
            arm.close()
        }
    }
}

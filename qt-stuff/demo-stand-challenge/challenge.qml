import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12

Item {
    id: chllng

    signal nextWindow(string windowName)

    property int currentFPSvalue_camera: 0
    property int currentFPSvalue_trackers: 0

    property alias camera: camera

    property int remainingSeconds: backend.get_timeForChallenge()


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

        var leftSourcePoint = Qt.point(lw_x * originalFrame.width, lw_y * originalFrame.height)
        var leftTarget = leftCroppingOverlayInner.mapFromItem(originalFrame, leftSourcePoint.x,
                                                         leftSourcePoint.y)
        var rightSourcePoint = Qt.point(rw_x * originalFrame.width, rw_y * originalFrame.height)
        var rightTarget = rightCroppingOverlayInner.mapFromItem(originalFrame,
                                                           rightSourcePoint.x,
                                                           rightSourcePoint.y)

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

    Rectangle {
        anchors.fill: parent
        color: "#CECFD4"

        ColumnLayout {
            anchors.fill: parent
            spacing: 20

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

                            property size viewfinderResolution: viewfinder.resolution

                            viewfinder.resolution: Qt.size(vo.width, vo.height)

                            onViewfinderResolutionChanged: {
                                console.log('viewfinder changed: ' + JSON.stringify(
                                                viewfinder))
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
                                    console.log('empty')
                                } else {
                                    resolutions.forEach(function (r) {
                                        console.log(r.width, "x", r.height)
                                    })
                                }
                            }

                            //focus {
                            //    focusMode: Camera.FocusMacro
                            //    focusPointMode: Camera.FocusPointCenter
                            //}
                            onError: {
                                cameraStatus.text = qsTr(
                                            "Error: ") + errorString
                                console.log(errorCode, errorString)
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
                            // fillMode: VideoOutput.PreserveAspectFit
                            fillMode: VideoOutput.PreserveAspectCrop
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

                                RowLayout {
                                    id: croppingOverlay

                                    property int bufferWidth: 100
                                    property int marginWidth: 50
                                    property real overlayOpacity: 0.1

                                    anchors.fill: parent

                                    Item {
                                        id: leftCroppingOverlay

                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        Item {
                                            id: leftCroppingOverlayInner

                                            anchors {
                                                fill: parent
                                                topMargin: croppingOverlay.marginWidth + (originalFrame.height - vo.height ) / 2
                                                bottomMargin: croppingOverlay.marginWidth + (originalFrame.height - vo.height ) / 2
                                                leftMargin: croppingOverlay.marginWidth
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                color: 'blue'
                                                opacity: croppingOverlay.overlayOpacity
                                            }

                                            /* left robot position */
                                            PositionDot {
                                                id: robotLeft

                                                position: robotsModel.leftArm.mapToItem(
                                                              parent.width,
                                                              parent.height)
                                                diameter: root.trackerWidth
                                                color: "blue"
                                                opacity: 0.3
                                            }

                                            // tracker #1 (left hand)
                                            TargetPositionDot {
                                                id: trackerLeft

                                                property string name: "left"

                                                diameter: root.trackerWidth
                                                color: "blue"
                                                visible: root.manualTrackers
                                                         || btn_stop.enabled
                                                onNormalPositionChanged: {
                                                    moveTheArm(name,
                                                               normalPosition)
                                                }
                                            }

                                            DragHandler {
                                                target: trackerLeft
                                                onCentroidChanged: chllng.onCentroidChanged(this)
                                            }
                                        }

                                        ColumnLayout {
                                            anchors {
                                                top: parent.top
                                                left: parent.left
                                                margins: 10
                                                topMargin: (originalFrame.height - vo.height ) / 2 + 10
                                            }

                                            spacing: 10

                                            Image {
                                                id: leftPalmDebug

                                                width: backend.cropRegionWidth
                                                height: width
                                                cache: false
                                                visible: sourceSize.height > 0
                                            }

                                            // FPS counters
                                            Text {
                                                id: fpsCounter_camera
                                                text: "0"
                                                font.pointSize: 40
                                                color: "yellow"
                                                visible: root.fpsCounters
                                            }
                                            Text {
                                                id: fpsCounter_trackers
                                                text: "0"
                                                font.pointSize: 40
                                                color: "red"
                                                //visible: btn_stop.enabled
                                                visible: root.fpsCounters
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

                                        Item {
                                            id: rightCroppingOverlayInner

                                            anchors {
                                                fill: parent
                                                topMargin: croppingOverlay.marginWidth + (originalFrame.height - vo.height ) / 2
                                                bottomMargin: croppingOverlay.marginWidth + (originalFrame.height - vo.height ) / 2
                                                rightMargin: croppingOverlay.marginWidth
                                            }

                                            Rectangle {
                                                anchors.fill: parent
                                                color: 'green'
                                                opacity: croppingOverlay.overlayOpacity
                                            }

                                            /* left robot position */
                                            PositionDot {
                                                id: robotRight

                                                position: robotsModel.rightArm.mapToItem(
                                                              parent.width,
                                                              parent.height)
                                                diameter: root.trackerWidth
                                                color: "green"
                                                opacity: 0.3
                                            }

                                            // tracker #2 (right hand)
                                            TargetPositionDot {
                                                id: trackerRight

                                                property string name: "right"

                                                diameter: root.trackerWidth
                                                color: "green"
                                                visible: root.manualTrackers
                                                         || btn_stop.enabled
                                                onNormalPositionChanged: {
                                                    moveTheArm(name,
                                                               normalPosition)
                                                }
                                            }

                                            DragHandler {
                                                target: trackerRight
                                                onCentroidChanged: chllng.onCentroidChanged(this)
                                            }
                                        }

                                        ColumnLayout {
                                            anchors {
                                                top: parent.top
                                                right: parent.right
                                                margins: 10
                                                topMargin: (originalFrame.height - vo.height ) / 2 + 10
                                            }

                                            spacing: 10

                                            Image {
                                                id: rightPalmDebug

                                                width: backend.cropRegionWidth
                                                height: width
                                                cache: false
                                            }
                                        }
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

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#F3F3F3"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 20

                    ImageButton {
                        id: btn_start
                        Layout.preferredHeight: parent.height * 0.6
                        Layout.maximumWidth: parent.width * 0.35
                        unpressedImage: "qrc:/img/button-start.png"
                        text: "START"
                        visible: enabled
                        onClicked: {
                            startChallenge()
                        }
                    }

                    ImageButton {
                        id: btn_stop
                        Layout.preferredHeight: parent.height * 0.6
                        Layout.maximumWidth: parent.width * 0.35
                        unpressedImage: "qrc:/img/button-stop.png"
                        text: "STOP"
                        enabled: !btn_start.enabled
                        visible: enabled
                        onClicked: {
                            stopChallenge()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Text  {
                            id: challengeTimer
                            anchors.centerIn: parent
                            font.family: titillium.name
                            font.pointSize: root.primaryFontSize * 2
                            font.bold: true
                            text: secondsToMinutes(backend.get_timeForChallenge())
                            visible: false
                        }

                        RowLayout {
                            id: scoreLayout
                            anchors.centerIn: parent
                            spacing: 15
                            visible: false

                            FancyButton {
                                topPadding: 10
                                rightPadding: 20
                                bottomPadding: 10
                                leftPadding: 20
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
                                font.family: titillium.name
                                font.pointSize: root.primaryFontSize * 2
                                font.bold: true
                                text: "0"
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

                    ImageButton {
                        Layout.preferredHeight: parent.height * 0.6
                        Layout.maximumWidth: parent.width * 0.35
                        unpressedImage: "qrc:/img/button-done.png"
                        text: "DONE"
                        enabled: !btn_stop.enabled
                        onClicked: {
                            enabled = false
                            text = "saving..."

                            backend.set_currentScore(score.text);

                            request("http://".concat(backend.dbServer(),
                                                     "/user/saveScore/",
                                                     backend.get_currentProfile(
                                                         ), "/", backend.get_currentScore()),
                                    "POST", function (o) {
                                        enabled = true
                                        text = "Done"

                                        if (o.status === 200
                                                || o.responseText === "0") {
                                            console.log(o.responseText)
                                        } else {
                                            console.log("[error] Couldn't save the score. Player ID:",
                                                        backend.get_currentProfile(
                                                            ), "| score:",
                                                        backend.get_currentScore())
                                            // FIXME dialog opens only for a fraction of second
                                            //dialogScoreError.open()
                                        }

                                        scoreLayout.visible = false;
                                        score.text = 0;

                                        nextWindow("finish.qml");
                                    })
                        }
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

    Timer {
        id: challengeCountdown
        interval: 1000
        repeat: true
        onTriggered: {
            remainingSeconds--;
            challengeTimer.text = secondsToMinutes(remainingSeconds);
            if (remainingSeconds === 0)
            {
                btn_stop.clicked();
            }
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

    function startChallenge()
    {
        scoreLayout.visible = false;
        score.text = 0;

        challengeTimer.visible = true;
        challengeCountdown.start();

        btn_start.enabled = false;
        robotsModel.sendChanges = true;
        tm_sendFrame.start();

    }

    function stopChallenge()
    {
        scoreLayout.visible = true;

        challengeTimer.visible = false;
        challengeTimer.text = secondsToMinutes(backend.get_timeForChallenge());
        challengeCountdown.stop();
        remainingSeconds = backend.get_timeForChallenge();

        btn_start.enabled = true;
        robotsModel.sendChanges = false;
        tm_sendFrame.stop();
        currentFPSvalue_trackers = 0;
    }

    function onCentroidChanged(item) {
        item.target.target = Qt.point(item.target.x, item.target.y)
    }

    function moveTheArm(armName, position) {
        //console.log('moveTheArm: ' + armName + ': ' + position)

        var arm = null
        if (armName === 'left') {
            arm = robotsModel.leftArm
        }
        if (armName === 'right') {
            arm = robotsModel.rightArm
        }

        arm.move(position.x, position.y)
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
        if (result == 0) {
            arm.open()
        }

        // @disable-check M126
        if (result == 1) {
            arm.close()
        }
    }

    function secondsToMinutes(secs)
    {
        var minutes = Math.floor(secs / 60);
        var seconds = secs - (minutes * 60);
        if (minutes < 10) { minutes = "0".concat(minutes); }
        if (seconds < 10) { seconds = "0".concat(seconds); }
        return minutes.concat(":", seconds);
    }
}

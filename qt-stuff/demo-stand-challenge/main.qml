import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.VirtualKeyboard.Settings 2.2
import io.qt.Backend 1.0

ApplicationWindow {
    id: root
    visible: true
    visibility: "FullScreen"
    width: 1100
    minimumWidth: 900
    height: 700
    minimumHeight: 600
    title: qsTr("Challenge")
    color: root.backgroundColor

    property real scaleRatio: Screen.devicePixelRatio.toFixed(0) < 2 ? 1.5 : 2
    property int primaryFontSize: 24
    property int secondaryFontSize: 18
    property string backgroundColor: "#ECECEC"
    property string primaryColor: "#43ADEE"

    property bool cameraUpsideDown: false // if you need to rotate viewfinder to 180
    property double timerRate: 0.05 * 1000 // ms, the rate of grabbing frames (0.05 * 1000 = 20 FPS)
    property int trackerWidth: 40 // trackers width (and height)

    property bool debugOutput: false // show debug panel (can really kill the performance)
    property bool fpsCounters: true // show FPS counters
    property bool manualTrackers: true // move trackers manually
    property bool maintenance: true // enable maintenance window

    Backend {
        id: backend

        onRequestPoseDone: {
            if (root.fpsCounters === true) {
                loader.item.currentFPSvalue_trackers++
            }
            loader.item.processPoseResults(result)
        }
        onRequestLeftHandDone: {
            loader.item.processLeftHandResults(result)
        }
        onRequestRightHandDone: {
            loader.item.processRightHandResults(result)
        }

        onRequestFailed: {
            loader.item.appendToOutput("Error: " + error, true)
        }

        onCounterIncreased: {
            if (root.fpsCounters === true) {
                loader.item.currentFPSvalue_camera++
            }
        }

        onLeftPalmChanged: {
            loader.item.updateLeftPalmDebug()
        }

        onRightPalmChanged: {
            loader.item.updateRightPalmDebug()
        }
    }

    FontLoader { id: typodermic; source: "qrc:/fonts/typodermic.ttf" }
    FontLoader { id: titillium; source: "qrc:/fonts/titillium.ttf" }
    FontLoader { id: titilliumBold; source: "qrc:/fonts/titillium-bold.ttf" }

    RobotsModel {
        id: robotsModel
    }

    Binding {
        target: VirtualKeyboardSettings
        property: "fullScreenMode"
        value: true
    }

    Drawer {
        id: drawer
        edge: Qt.TopEdge
        width: root.width
        height: root.height
        interactive: root.maintenance

        Maintenance {
            id: maintenanceView
        }
    }

    Loader {
        id: loader
        anchors.fill: parent
        source: "qrc:/welcome.qml"

        Connections {
            target: loader.item
            onNextWindow: {
                loader.source = "qrc:/" + windowName
            }
        }
    }

    function getCurrentDateTime()
    {
        return new Date().toISOString().replace(/[:|.|T]/g, "-").replace("Z", "");
    }

    // HTTP-request to the URL
    function request(url, method, callback) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function (myxhr) {
            return function () {
                if (myxhr.readyState === 4) {
                    callback(myxhr)
                }
            }
        })(xhr)

        xhr.open(method, url)
        xhr.send()
    }

    function calculateFontSize(parentWidth, parentWidthFraction)
    {
        var fontSize = parentWidth > 0 ? parentWidth * parentWidthFraction * root.scaleRatio : root.primaryFontSize;
        //console.log(parentWidth, parentWidthFraction, fontSize);
        return Math.round(fontSize);
    }
}

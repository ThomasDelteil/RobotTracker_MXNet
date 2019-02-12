import QtQuick 2.12
import QtWebSockets 1.1

Item {
    id: root

    property alias leftArm: left
    property alias rightArm: right

    QtObject {
        id: proxy

        //property string ip: "10.78.144.127"
        property string ip: "localhost"
        property string port: "3000"

        property url httpUrl: "http://" + ip + ":" + port
        property url wsUrl: "ws://" + ip + ":" + port + "/listen"
    }

    function sendRequest(route, data, callback) {
        let url = proxy.httpUrl + "/" + route
        let dataString = !!data ? JSON.stringify(data) : null
        console.log("Sending: " + url + 'with data: ' + dataString)

        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function () {
            if (doc.readyState === XMLHttpRequest.DONE) {
                console.log(route + " succeeded, calling callback")
                if (!!callback) {
                    callback(doc)
                }
            }

            if (doc.readyState === XMLHttpRequest.UNSENT) {
                console.log(route + "  XMLHttpRequest.UNSENT")
            }

            if (doc.readyState === XMLHttpRequest.OPENED) {
                console.log(route + " XMLHttpRequest.OPENED")
            }

            if (doc.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
                console.log(route + " XMLHttpRequest.HEADERS_RECEIVED")
            }

            if (doc.readyState === XMLHttpRequest.LOADING) {
                console.log(route + " XMLHttpRequest.LOADING")
            }
        }

        if (!!dataString) {
            doc.open("POST", url)
            doc.send(dataString)
        } else {
            doc.open("GET", url)
            doc.send()
        }
    }

    function open(arm) {
        sendRequest(arm.name + "/open")
    }

    function close() {
        sendRequest(arm.name + "/close")
    }

    function calibrate(arm) {
        sendRequest(arm.name + "/calibrate")
    }

    function getPosition(arm, relativeY, relativeZ) {
        return {
            "x": arm.minX,
            "y": arm.minY + (arm.maxY - arm.minY) * relativeY,
            "z": arm.minZ + (arm.maxZ - arm.minZ) * relativeZ,
            "roll": arm.minRoll,
            "pitch": arm.minPitch,
            "yaw": arm.minYaw
        }
    }

    function move(arm, relativeY, relativeZ) {
        if (arm.name === 'left') {
            arm = left
        }

        if (arm.name === 'right') {
            arm = right
        }

        sendRequest(arm.name + "/move", getPosition(arm, relativeY, relativeZ))
    }

    RobotArm {
        id: left

        property string name: 'left'

        property real minX: 0.253
        property real maxX: 0.253

        property real minY: -0.25
        property real maxY: 0.25

        property real minZ: 0.1
        property real maxZ: 0.37

        property real minRoll: 0
        property real maxRoll: 0

        property real minPitch: Math.PI / 2
        property real maxPitch: Math.PI / 2

        property real minYaw: -Math.PI / 2
        property real maxYaw: -Math.PI / 2
    }

    RobotArm {
        id: right

        property string name: 'right'

        property real minX: 0.253
        property real maxX: 0.253

        property real minY: -0.25
        property real maxY: 0.25

        property real minZ: 0.1
        property real maxZ: 0.37

        property real minRoll: 0
        property real maxRoll: 0

        property real minPitch: Math.PI / 2
        property real maxPitch: Math.PI / 2

        property real minYaw: -Math.PI / 2
        property real maxYaw: -Math.PI / 2
    }

    Timer {
        id: reconnectTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: stateListener.active = true
    }

    WebSocket {
        id: stateListener

        active: true
        url: proxy.wsUrl

        onUrlChanged: {
            console.log('UrlChanged: ' + url)
        }

        //url: server.url
        onTextMessageReceived: {
            console.log('Message received: ' + message)

            var obj = JSON.parse(message)
            if (!!obj.left) {
                left.parse(obj.left)
            } else {
                console.log("No position for left")
            }

            if (!!obj.right) {
                right.parse(obj.right)
            } else {
                console.log("No position for right")
            }
        }

        onActiveChanged: {
            console.log("ActiveChanged: " + active)
        }

        onStatusChanged: {
            console.log("Socket status changed: " + status)

            if (status === WebSocket.Connecting) {
                console.log("WebSocket.Connecting")
                root.state = "disconnected"
                return
            }

            if (status === WebSocket.Open) {
                console.log("WebSocket.Open")
                root.state = "connected"
                return
            }

            if (status === WebSocket.Closing) {
                console.log("WebSocket.Closing")
                root.state = "disconnected"
                return
            }

            if (status === WebSocket.Closed) {
                console.log("WebSocket.Closed")
                root.state = "disconnected"
                active = false
                reconnectTimer.start()
                return
            }

            if (status === WebSocket.Error) {
                console.log("WebSocket.Error: " + stateListener.errorString)
                root.state = "disconnected"
                return
            }

            root.state = "disconnected"
            console.log("WebSocket.Unknown")
        }
    }

    states: [
        State {
            name: "connected"
        },
        State {
            name: "disconnected"
        }
    ]
}

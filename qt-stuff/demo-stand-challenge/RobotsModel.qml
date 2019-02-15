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
        var url = proxy.httpUrl + "/" + route
        var dataString = !!data ? JSON.stringify(data) : null
        console.log("Sending: " + url + ' with data: ' + dataString)

        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function () {
            if (doc.readyState === XMLHttpRequest.DONE) {
                console.log(route + " succeeded")
                if (!!callback) {
                    callback(doc)
                }
            }

            //            if (doc.readyState === XMLHttpRequest.UNSENT) {
            //                console.log(route + "  XMLHttpRequest.UNSENT")
            //            }

            //            if (doc.readyState === XMLHttpRequest.OPENED) {
            //                console.log(route + " XMLHttpRequest.OPENED")
            //            }

            //            if (doc.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            //                console.log(route + " XMLHttpRequest.HEADERS_RECEIVED")
            //            }

            //            if (doc.readyState === XMLHttpRequest.LOADING) {
            //                console.log(route + " XMLHttpRequest.LOADING")
            //            }
        }

        if (!!dataString) {
            doc.open("POST", url)
            doc.setRequestHeader("Content-type", "application/json")
            doc.send(dataString)
        } else {
            doc.open("GET", url)
            doc.send()
        }
    }

    function open(arm) {
        sendRequest(arm.name + "/open")
    }

    function close(arm) {
        sendRequest(arm.name + "/close")
    }

    function calibrate(arm) {
        sendRequest(arm.name + "/calibrate")
    }

    function setLearningMode(arm, isOn) {
        sendRequest(arm.name + "/learningMode", {
                        "isOn": isOn
                    })
    }

    function getPosition(arm, relativeY, relativeZ) {
        return {
            "x": arm.minX,
            "y": arm.minY + (arm.maxY - arm.minY) * relativeY,
            "z": arm.maxZ - (arm.maxZ - arm.minZ) * relativeZ,
            "roll": arm.minRoll,
            "pitch": arm.minPitch,
            "yaw": arm.minYaw
        }
    }

    property real threshold: 0.01

    property var leftLastPosition: null
    property var leftLastSentPosition: null
    property var rightLastPosition: null
    property var rightLastSentPosition: null

    function positionChanged(position, sentPosition) {
        if (!position) {
            return false
        }

        if (!sentPosition) {
            return true
        }

        if (Math.abs(position.y - sentPosition.y) > threshold) {
            return true
        }

        if (Math.abs(position.z - sentPosition.z) > threshold) {
            return true
        }

        return false
    }

    Timer {
        interval: 500
        repeat: true
        running: true
        triggeredOnStart: true

        onTriggered: {
            if (positionChanged(leftLastPosition, leftLastSentPosition)) {
                sendRequest("left/move", leftLastPosition)
                leftLastSentPosition = leftLastPosition
            }

            if (positionChanged(rightLastPosition, rightLastSentPosition)) {
                sendRequest("right/move", rightLastPosition)
                rightLastSentPosition = rightLastPosition
            }
        }
    }

    function move(arm, relativeY, relativeZ) {
        if (arm.name === 'left') {
            leftLastPosition = getPosition(left, relativeY, relativeZ)
        }

        if (arm.name === 'right') {
            rightLastPosition = getPosition(right, relativeY, relativeZ)
        }
    }

    RobotArm {
        id: left

        name: 'left'
    }

    RobotArm {
        id: right

        name: 'right'
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

    state: "disconnected"
}

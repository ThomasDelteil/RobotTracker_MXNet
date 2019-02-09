import QtQuick 2.0
import QtWebSockets 1.1

Item {
    id: root

    property alias leftArm: left
    property alias rightArm: right

    QtObject {
        id: proxy

        property string ip: "10.78.144.127"
        property string port: "3000"

        property url httpUrl: "http://" + ip + ":" + port
        property url wsUrl: "ws://" + ip + ":" + port + "/listen"
    }

    function sendRequest(route, data, callback) {
        console.log("Sending: " + route)

        var doc = new XMLHttpRequest()
        doc.onreadystatechange = function () {
            if (doc.readyState === XMLHttpRequest.DONE) {
                console.log(route + " succeeded, calling callback")
                callback(doc)
            }
        }

        doc.open("GET", proxy.httpUrl + route)
        if (!!data) {
            doc.send(data)
        } else {
            doc.send(data)
        }
    }

    function calibrate() {
        sendRequest("/calibrate")
    }

    function move(arm) {
        var postData = {
            y: arm.data.y,
            z: arm.data.z
        }
        sendRequest(arm.name + "/move", data)
    }

    RobotArm {
        id: left
    }

    RobotArm {
        id: right
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
            left.parse(obj.left)
            right.parse(obj.right)
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

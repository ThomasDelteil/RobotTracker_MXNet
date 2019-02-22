import QtQuick 2.12
import QtWebSockets 1.1

Item {
    id: root

    property bool sendChanges: true

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

    Timer {
        interval: 500
        repeat: true
        running: root.sendChanges
        triggeredOnStart: true

        onTriggered: {
            left.sendChanges()
            right.sendChanges()
        }
    }

    RobotArm {
        id: left

        name: 'left'
        proxy: proxy
    }

    RobotArm {
        id: right

        name: 'right'
        proxy: proxy
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
            //console.log('Message received: ' + message)

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

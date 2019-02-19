import QtQuick 2.12

QtObject {
    id: root

    enum ConnectionStatus {
        Disconnected = 0,
        Connecting = 1,
        Connected = 2,
        Error = 3
    }

    property int connectionStatus: RobotArm.ConnectionStatus.Connecting

    property real x
    property real y
    property real z

    property real roll
    property real pitch
    property real yaw

    property bool isOpen

    property string name

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

    property bool calibrationNeeded
    property bool learningMode

    property var proxy

    function move(relativeY, relativeZ) {
        impl.lastPosition = impl.getPosition(relativeY, relativeZ)
    }

    function open() {
        impl.lastOpen = true
    }

    function close() {
        impl.lastOpen = false
    }

    function calibrate() {
        impl.calibrate()
    }

    function setLearningMode(isOn) {
        impl.setLearningMode(isOn)
    }

    function parse(object) {
        root.x = object.x
        root.y = object.y
        root.z = object.z
        root.roll = object.roll
        root.pitch = object.pitch
        root.yaw = object.yaw
        root.isOpen = object.open
        root.calibrationNeeded = object.calibrationNeeded
        root.learningMode = object.learningMode
    }

    function getConnectionStatusColor() {
        switch (connectionStatus) {
        case 0:
            return "red"
        case 1:
            return "lightblue"
        case 2:
            return "green"
        case 3:
            return "yellow"
        }
    }

    function sendChanges() {
        if (impl.positionChanged()) {
            impl.move(impl.lastPosition)
            impl.lastSentPosition = impl.lastPosition
        }

        if (impl.openedChanged()) {
            if (impl.lastOpen) {
                impl.open()
            } else {
                impl.close()
            }

            impl.lastSentOpen = impl.lastOpen
        }
    }

    property var impl: QtObject {
        id: impl

        property var lastPosition: null
        property var lastSentPosition: null

        property var lastOpen: null
        property var lastSentOpen: null

        property real threshold: 0.01

        function sendRequest(route, data, callback) {
            var url = root.proxy.httpUrl + "/" + route
            var dataString = !!data ? JSON.stringify(data) : null
            console.log("Sending: " + url + (!!dataString ? ' with data: ' + dataString : ''))

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

        function open() {
            sendRequest(root.name + "/open")
        }

        function close() {
            sendRequest(root.name + "/close")
        }

        function calibrate() {
            sendRequest(root.name + "/calibrate")
        }

        function setLearningMode(isOn) {
            var data = {
                "isOn": isOn
            }
            sendRequest(root.name + "/learningMode", data)
        }

        function getPosition(relativeY, relativeZ) {
            return {
                "x": root.minX,
                "y": root.minY + (root.maxY - root.minY) * relativeY,
                "z": root.maxZ - (root.maxZ - root.minZ) * relativeZ,
                "roll": root.minRoll,
                "pitch": root.minPitch,
                "yaw": root.minYaw
            }
        }

        function move(position) {
            sendRequest(root.name + "/move", position)
        }

        function positionChanged() {
            if (!lastPosition) {
                return false
            }

            if (!lastSentPosition) {
                return true
            }

            if (Math.abs(lastPosition.y - lastSentPosition.y) > threshold) {
                return true
            }

            if (Math.abs(lastPosition.z - lastSentPosition.z) > threshold) {
                return true
            }

            return false
        }

        function openedChanged() {
            if (lastOpen === null) {
                return false
            }

            if (!lastSentOpen === null) {
                return true
            }

            return lastOpen !== lastSentOpen
        }
    }
}

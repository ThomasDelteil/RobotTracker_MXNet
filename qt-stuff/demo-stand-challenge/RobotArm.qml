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

    property real x: minX + rangeX / 2.0
    property real y: minY + rangeY / 2.0
    property real z: minZ + rangeZ / 2.0

    property real normalizedX: rangeX > 0 ? Math.abs(x - minX) / rangeX : 0
    property real normalizedY: rangeY > 0 ? Math.abs(y - minY) / rangeY : 0
    property real normalizedZ: rangeZ > 0 ? Math.abs(z - minZ) / rangeZ : 0

    /*
    onNormalizedXChanged: console.log('onNormalizedXChanged: ' + normalizedX)
    onNormalizedYChanged: console.log('onNormalizedYChanged: ' + normalizedY)
    onNormalizedZChanged: console.log('onNormalizedZChanged: ' + normalizedZ)
    */

    property real roll: minRoll
    property real pitch: minPitch
    property real yaw: minYaw

    property real normalizedRoll: rangeRoll > 0 ? Math.abs(
                                                      roll - minRoll) / rangeRoll : 0
    property real normalizedPitch: rangePitch > 0 ? Math.abs(
                                                        pitch - minPitch) / rangePitch : 0
    property real normalizedYaw: rangeYaw > 0 ? Math.abs(
                                                    yaw - minYaw) / rangeYaw : 0

    property bool isOpen: false

    property string name

    property real minX: 0.253
    property real maxX: 0.253
    property real rangeX: Math.abs(maxX - minX)

    property real minY: -0.25
    property real maxY: 0.25
    property real rangeY: Math.abs(maxY - minY)
    property real transferY

    property real minZ: 0.1
    property real maxZ: 0.37
    property real rangeZ: Math.abs(maxZ - minZ)

    property real minRoll: 0
    property real maxRoll: 0
    property real rangeRoll: Math.abs(maxRoll - minRoll)
    property real transferRoll

    property real minPitch: Math.PI / 2
    property real maxPitch: Math.PI / 2
    property real rangePitch: Math.abs(maxPitch - minPitch)
    property real transferPitch

    property real minYaw: 0 //-Math.PI / 2
    property real maxYaw: 0 //-Math.PI / 2
    property real rangeYaw: Math.abs(maxYaw - minYaw)
    property real transferYaw

    property bool calibrationNeeded: true
    property bool learningMode: true

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
        if (!isOn) {
            impl.selectGripper_1()
            console.log(name + ' arm tool selected')
        }
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
        if (learningMode) {
            return
        }

        if (impl.positionChanged()) {
            //console.log('will send position: ' + JSON.stringify(impl.lastPosition))
            impl.move(impl.lastPosition)
            impl.lastSentPosition = impl.lastPosition
        }
/*
        if (impl.openedChanged()) {
            if (impl.lastOpen) {
                impl.open()
            } else {
                impl.close()
            }

            impl.lastSentOpen = impl.lastOpen
        }
	*/
    }

    function sendOpenClosedChanges() {
        if (learningMode) {
            return
        }
        var currentState = impl.lastOpen
//	console.log(name + ': timer sendOpenClosedChanges: lastOpen=' + impl.lastOpen + ', impl.lastSentOpen=' + impl.lastSentOpen)
        if (impl.openedChanged(currentState)) {
//	    console.log(name + ': state changed')
            if (currentState) {
                console.log(name +': sending OPEN')
                impl.open()
            } else {
                console.log(name +': sending CLOSE')
                impl.close()
            }

            impl.lastSentOpen = currentState
        }
    }

    function mapToItem(itemWidth, itemHeight) {
        return Qt.point(Math.abs(itemWidth) * normalizedY, Math.abs(itemHeight) * (1 - normalizedZ))
    }

    function mapXFromRobot(frame) {
        // root.y = root.minY + (root.maxY - root.minY) * relativeY
        var x_frame = mapCoords(root.y, frame.width, root.minY, root.maxY)
        //console.log('robot y -> x:' + root.y + ' -> ' + x_frame)
        return x_frame
    }

    function mapYFromRobot(frame) {
        // root.z = root.maxZ - (root.maxZ - root.minZ) * relativeZ
        var y_frame = mapCoords(root.z, frame.height, root.minZ, root.maxZ)
        // flip y axis
        y_frame = frame.height - y_frame
        //console.log('robot z -> y:' + root.z + ' -> ' + y_frame)
        return y_frame
    }

    function clipCoords(c, c_min, c_max) {
        return Math.min(Math.max(c, c_min), c_max)
    }

    function mapCoords(source, target_space, source_min, source_max) {
        var source_clip = clipCoords(source, source_min, source_max)
        var source_space = source_max - source_min
        return target_space * (source - source_min) / source_space
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
            //console.log("Sending "  + url + (!!dataString ? ' with data: ' + dataString : ''))

            var doc = new XMLHttpRequest()
            doc.onreadystatechange = function () {
                if (doc.readyState === XMLHttpRequest.DONE) {
//                    console.log(route + " succeeded")
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

        function selectGripper_1() {
            var data = {
                "toolId": 11
            }
            sendRequest(root.name + "/tools", data)
        }

        function getPosition(relativeY, relativeZ) {
            var roll = root.minRoll
            var pitch = root.minPitch
            var yaw = root.minYaw

            // flipping the gropper
            var y = root.minY + root.rangeY * relativeY
            if ((name == 'left' && y > transferY) ||
                    (name == 'right' && y < transferY)) {
                roll = transferRoll
                pitch = transferPitch
                yaw = transferYaw
            }

            return {
                "x": root.minX, // constant
                "y": y,
                "z": root.maxZ - root.rangeZ * relativeZ, //flit z coord vertically
                "roll": roll,
                "pitch": pitch,
                "yaw": yaw
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

        function openedChanged(currentState) {
            if (currentState === null) {
                return false
            }

            if (!lastSentOpen === null) {
                return true
            }

            return currentState !== lastSentOpen
        }
    }
}

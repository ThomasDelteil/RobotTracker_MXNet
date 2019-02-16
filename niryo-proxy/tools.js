"use strict";

const rosLib = require('roslib')
const EventEmitter = require('events');

const ROBOT_COMMAND_TYPE = {
    "JOINTS": 1,
    "POSE": 2,
    "POSITION": 3,
    "RPY": 4,
    "SHIFT_POSE": 5,
    "TOOL": 6
}

const GRIP_COMMAND = {
    "OPEN": 1,
    "CLOSE": 2
}

class ArmConfig {
    constructor(name, host, port, server_name, action_name) {
        this.name = name
        this.host = host
        this.port = port
        this.server_name = server_name
        this.action_name = action_name
    }

    toString() {
        return JSON.stringify(this)
    }
}

class ArmState {
    constructor() {
        this.x = null
        this.y = null
        this.z = null
        this.yaw = null
        this.pitch = null
        this.roll = null
        this.calibrationNeeded = null
        this.open = null
        this.learningMode = null
        this.toolId = null
        this.gripOpen = null
    }

    updatePosition(positionMessage) {
        let updatedRpy = this.updateAndSignal(positionMessage.rpy)
        let updatesPos = this.updateAndSignal(positionMessage.position)
        return updatedRpy || updatesPos
    }

    updateHardwareStatus(hardwareStatusMessage) {
        if (hardwareStatusMessage.calibration_needed != this.calibrationNeeded) {
            this.calibrationNeeded = hardwareStatusMessage.calibration_needed
            return true
        }
        return false
    }

    updateLearningMode(learningMode) {
        if (this.updateLearningMode != learningMode) {
            this.learningMode = learningMode
            return true
        }
        return false
    }

    updateToolId(toolId) {
        if (toolId != this.toolId) {
            this.toolId = toolId
            return true
        }
        return false
    }

    updateGripOpen(gripOpen) {
        if (gripOpen != this.gripOpen) {
            this.gripOpen = gripOpen
            return true
        }
        return false
    }

    updateAndSignal(other) {

        if (other == null) {
            return false
        }

        // Create arrays of property names
        let objectUpdated = false
        var otherProps = Object.getOwnPropertyNames(other);

        for (let propName of otherProps) {
            if (this[propName] !== other[propName]) {
                this[propName] = other[propName]
                objectUpdated = true
            }
        }

        return objectUpdated
    }
}

class Arm extends EventEmitter {
    constructor(config) {
        super()
        this.config = config
        this.state = new ArmState()
        this.connected = false
    }

    init() {
        const url = `ws://${this.config.host}:${this.config.port}`

        console.log(`${this.config.name}: Initializing for url: ${url}`)

        this.ros = new rosLib.Ros({
            url: url
        })

        let that = this

        // If there is an error on the backend, an 'error' emit will be emitted.
        this.ros.on('error', function (error) {
            console.log(`${that.config.name}: error: ${error}`)
            //that.emit('error', error)
            this.connected = false
        })

        // Find out exactly when we made a connection.
        this.ros.on('connection', function () {
            console.log(`${that.config.name}: connected`)
            that.emit('connection')
            that.onconnect()
        })

        this.ros.on('close', function () {
            if (that.connected) {
                console.log(`${that.config.name}: disconnected`)
                that.connected = false
            }
            //that.emit('close')
            let reconnect = function () {
                if (that.connected) {
                    return
                }

                that.ros.connect(url)
            }

            setTimeout(reconnect, 1000)
        })

        this.client = new rosLib.ActionClient({
            ros: this.ros,
            serverName: '/niryo_one/commander/robot_action',
            actionName: 'niryo_one_msgs/RobotMoveAction'
        })

        this.changeToolClient = new rosLib.Service({
            ros: this.ros,
            name: '/niryo_one/change_tool',
            serviceType: 'niryo_one_msgs/SetInt'
        })

        this.moveTopic = new rosLib.Topic({
            ros: this.ros,
            name: '/niryo_one/commander/trajectory',
            messageType: 'niryo_one_msgs/RobotMoveCommand'
        })

        this.calibrateClient = new rosLib.Service({
            ros: this.ros,
            name: '/niryo_one/calibrate_motors',
            serviceType: 'niryo_one_msgs/SetInt'
        })

        this.activateLearningModeClient = new rosLib.Service({
            ros: this.ros,
            name: '/niryo_one/activate_learning_mode',
            serviceType: 'niryo_one_msgs/SetInt',
        });
    }

    onconnect() {

        let that = this

        let toolParam = new rosLib.Param({
            ros: this.ros,
            name: '/niryo_one_tools/tool_list',
        })

        toolParam.get(function (message) {
            that.toolList = message
        })

        let robotState = new rosLib.Topic({
            ros: this.ros,
            name: '/niryo_one/robot_state',
            messageType: 'niryo_one_msgs/RobotState',
        })

        robotState.subscribe(function (message) {
            if (that.state.updatePosition(message)) {
                that.emit('state_change', that.state)
            }
        })

        let hardwareStatus = new rosLib.Topic({
            ros: this.ros,
            name: '/niryo_one/hardware_status',
            messageType: 'niryo_one_msgs/HardwareStatus',
        })

        hardwareStatus.subscribe(function (message) {
            if (that.state.updateHardwareStatus(message)) {
                that.emit('state_change', that.state)
            }
        })

        let learningModelStatus = new rosLib.Topic({
            ros: this.ros,
            name: '/niryo_one/learning_mode',
            messageType: 'std_msgs/Bool',
        })

        learningModelStatus.subscribe(function (message) {
            if (that.state.updateLearningMode(message.data)) {
                that.emit('state_change', that.state)
            }
        })

        // Tool id
        let currentTool = new rosLib.Topic({
            ros: this.ros,
            name: '/niryo_one/current_tool_id',
            messageType: 'std_msgs/Int32',
        });

        currentTool.subscribe(function (message) {
            if (that.state.updateToolId(message.data)) {
                that.emit('state_change', that.state)
            }
        })

        this.connected = true
    }

    changeTool(toolId) {
        let that = this
        let request = new rosLib.ServiceRequest({
            value: toolId
        })

        this.changeToolClient.callService(request, function (response) {
            if (response.status === 200) {
                console.log(`${that.config.name}: changeTool: changed to tool ${toolId}`)
            } else {
                console.log(`${that.config.name}: changeTool: error ${response.message}`)
            }
        }, function (error) {
            console.log(`${that.config.name}: changeTool: ${error}`)
        })
    }

    openGrip() {
        this.runGripCommand(GRIP_COMMAND.OPEN)
    }

    closeGrip() {
        this.runGripCommand(GRIP_COMMAND.CLOSE)
    }

    runGripCommand(toolCmd) {
        let that = this
        const command = {
            'cmd_type': ROBOT_COMMAND_TYPE.TOOL,
            'tool_cmd': {
                'tool_id': this.state.toolId,
                'cmd_type': toolCmd,
                'gripper_open_speed': 300,
                'gripper_close_speed': 500,
                'activate': false,
                'gpio': 0
            }
        }

        var goal = new rosLib.Goal({
            actionClient: this.client,
            goalMessage: new rosLib.Message({
                'cmd': command
            })
        })

        goal.on('feedback', function (feedback) {
            console.log(`${that.config.name}: feedback: ${JSON.stringify(feedback)}`)
        })

        goal.on('result', function (result) {
            console.log(`${that.config.name}: result: ${JSON.stringify(result)}`)
            if (result.status == 1) {
                that.state.updateGripOpen(toolCmd == GRIP_COMMAND.OPEN)
            }
        })

        goal.on('timeout', function () {
            console.log(`${that.config.name}: timeout`)
        })

        goal.send(1000);
    }

    calibrate() {
        let that = this
        let request = new rosLib.ServiceRequest({
            value: 2
        })

        this.calibrateClient.callService(request, function (response) {
            if (response.status === 200) {
                console.log(`${that.config.name}: calibrate: succeeded`)
            } else {
                console.log(`${that.config.name}: calibrate: error ${response.message}`)
            }
        }, function (error) {
            console.log(`${that.config.name}: calibrate: ${error}`)
        })
    }

    learningMode(isOn) {
        let that = this
        let request = new rosLib.ServiceRequest({
            value: isOn ? 1 : 0
        })

        this.activateLearningModeClient.callService(request, function (response) {
            if (response.status === 200) {
                console.log(`${that.config.name}: activateLearningModeClient: succeeded: ${isOn}`)
            } else {
                console.log(`${that.config.name}: activateLearningModeClient: error ${response.message}`)
            }
        }, function (error) {
            console.log(`${that.config.name}: calibrate: ${error}`)
        })
    }
/*
    move_pose(pos) {
        console.log(`${this.config.name}: move_pose`)

        const command = {
            'cmd_type': 2,
            'position': {
                'x': pos.x,
                'y': pos.y,
                'z': pos.z,
            },
            'rpy': {
                'roll': pos.roll,
                'pitch': pos.pitch,
                'yaw': pos.yaw,
            }
        }

        let that = this

        // Create a goal.
        var goal = new rosLib.Goal({
            actionClient: this.client,
            goalMessage: new rosLib.Message({ 'cmd': command })
        });

        goal.on('feedback', function (feedback) {
            console.log(`${that.config.name}: feedback: ${feedback.sequence}`)
            that.emit('feedback', feedback)
        });

        goal.on('result', function (result) {
            console.log(`${that.config.name}: result: ${result.sequence}`)
            that.emit('result', result)
        });

        goal.on('timeout', function () {
            console.log(`${that.config.name}: timeout`)
            that.emit('timeout')
        });

        // Send the goal to the action server.
        goal.send(1000);

        console.log(`${this.config.name}: move_pose: goal sent`)
    }
*/

    move_pose(pos) {
        console.log(`${this.config.name}: move_pose: ${JSON.stringify(pos)}`)

        const command = {
            'cmd_type': 2,
            'position': {
                'x': pos.x,
                'y': pos.y,
                'z': pos.z,
            },
            'rpy': {
                'roll': pos.roll,
                'pitch': pos.pitch,
                'yaw': pos.yaw,
            }
        }

        this.moveTopic.publish(new rosLib.Message(command))
        console.log(`${this.config.name}: move_pose: move sent`)
    }

    describe() {
        console.log(`${this.config.name}: I'm an arm with config: ${this.config}`)
    }
}

module.exports = {
    Arm: Arm,
    ArmConfig: ArmConfig
};
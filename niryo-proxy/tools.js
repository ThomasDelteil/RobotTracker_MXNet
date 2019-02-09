"use strict";

const rosLib = require('roslib')
const EventEmitter = require('events');

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
        if(this.updateLearningMode != learningMode) {
            this.learningMode = learningMode
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
    }

    init() {
        const url = `ws://${this.config.host}:${this.config.port}`

        console.log(`${this.config.name}: Initializing for url: ${url}`)

        this.ros = new rosLib.Ros({
            url: url
        })

        let that = this

        // If there is an error on the backend, an 'error' emit will be emitted.
        this.ros.on('error', function(error) {
            console.log(`${that.config.name}: error: ${error}`)
            //that.emit('error', error)
        })

        // Find out exactly when we made a connection.
        this.ros.on('connection', function() {
            console.log(`${that.config.name}: connected`)
            that.emit('connection')
        })

        this.ros.on('close', function() {
            console.log(`${that.config.name}: disconnected`)
            //that.emit('close')
        })

        this.client = new rosLib.ActionClient({
            ros: this.ros,
            serverName: this.config.server_name,
            actionName: this.config.action_name
        })

        let robotState = new rosLib.Topic({
            ros: this.ros,
            name: '/niryo_one/robot_state',
            messageType: 'niryo_one_msgs/RobotState',
        })

        robotState.subscribe(function(message) {
            if(that.state.updatePosition(message)) {
                that.emit('state_change', that.state)
            }
        })

        let hardwareStatus = new rosLib.Topic({
          ros: this.ros,
          name: '/niryo_one/hardware_status',
          messageType: 'niryo_one_msgs/HardwareStatus',
        })

        hardwareStatus.subscribe(function(message) {
            if(that.state.updateHardwareStatus(message)) {
                that.emit('state_change', that.state)
            }
        })

        let learningModelStatus = new rosLib.Topic({
          ros: this.ros,
          name: '/niryo_one/learning_mode',
          messageType: 'std_msgs/Bool',
        })

        learningModelStatus.subscribe(function(message) {
            if(that.state.updateLearningMode(message.data)) {
                that.emit('state_change', that.state)
            }
        })
    }

    // move_pose(pos) {
    //     console.log(`${this.config.name}: move_pose`)

    //     const command = {
    //         'cmd_type': 2,
    //         'position': {
    //             'x': pos.x,
    //             'y': pos.y,
    //             'z': pos.z,
    //         },
    //         'rpy': {
    //             'roll': pos.roll,
    //             'pitch': pos.pitch,
    //             'yaw': pos.yaw,
    //         }
    //     }

    //     let that = this

    //     // Create a goal.
    //     var goal = new rosLib.Goal({
    //         actionClient: this.client,
    //         goalMessage: new rosLib.Message({ 'cmd': command })
    //     });

    //     goal.on('feedback', function (feedback) {
    //         console.log(`${that.config.name}: feedback: ${feedback.sequence}`)
    //         that.emit('feedback', feedback)
    //     });

    //     goal.on('result', function (result) {
    //         console.log(`${that.config.name}: result: ${result.sequence}`)
    //         that.emit('result', result)
    //     });

    //     goal.on('timeout', function () {
    //         console.log(`${that.config.name}: timeout`)
    //         that.emit('timeout')
    //     });

    //     // Send the goal to the action server.
    //     goal.send(1000);

    //     console.log(`${this.config.name}: move_pose: goal sent`)
    // }

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

        this.move_topic = new rosLib.Topic({
            ros: this.ros,
            name: '/niryo_one/commander/trajectory',
            messageType: 'niryo_one_msgs/RobotMoveCommand'
        })

        console.log(`${this.config.name}: move_pose: this.move_topic: ${this.move_topic}`)

        this.move_topic.publish(new rosLib.Message(command))

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
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

class RobotState {
    constructor(name, armStateMsg) {
        this.name = name
        this.x = armStateMsg.position.x
        this.y = armStateMsg.position.y
        this.z = armStateMsg.position.z
        this.yaw = armStateMsg.rpy.yaw
        this.pitch = armStateMsg.rpy.pitch
        this.roll = armStateMsg.rpy.roll
    }

    equals(other) {

        if (other == null) {
            return false
        }

        // Create arrays of property names
        var aProps = Object.getOwnPropertyNames(this);
        var bProps = Object.getOwnPropertyNames(other);

        // If number of properties is different,
        // objects are not equivalent
        if (aProps.length != bProps.length) {
            return false;
        }

        for (let propName of aProps) {
            // If values of same property are not equal,
            // objects are not equivalent
            if (this[propName] !== other[propName]) {
                return false;
            }
        }

        // If we made it this far, objects
        // are considered equivalent
        return true;
    }
}

class Arm extends EventEmitter {
    constructor(config) {
        super()
        this.config = config
        this.state = null
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

        this.robotStateSubscriber = new rosLib.Topic({
            ros: this.ros,
            name: '/niryo_one/robot_state',
            messageType: 'niryo_one_msgs/RobotState',
        })

        this.robotStateSubscriber.subscribe(function(message) {
            let newState = new RobotState(that.config.name, message)
            if (!newState.equals(that.state)) {
                that.state = newState
                that.emit('position_change', that.state)
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
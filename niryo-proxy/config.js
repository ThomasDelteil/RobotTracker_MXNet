"use strict";

const rosLib = require('roslib')

const LEFT_ARM_HOST = 'localhost'
const LEFT_ARM_PORT = 9090

const RIGHT_ARM_HOST = 'localhost'
const RIGHT_ARM_PORT = 9091

const MAX_LEFT = new rosLib.Vector3(0.225, -0.220, 0.1)
const MAX_RIGHT = new rosLib.Vector3(0.225, 0.220, 0.1)

const ROLL = 0.0
const PITCH = 1.57
const YAW = 1.67

const SERVER_NAME = '/niryo_one/commander/robot_action'
const ACTION_NAME = 'niryo_one_msgs/RobotMoveAction'

module.exports = {
    arms: {
        left: {
            name: 'left',
            host: LEFT_ARM_HOST,
            port: LEFT_ARM_PORT,
            server_name: SERVER_NAME,
            action_name: ACTION_NAME
        },
        right: {
            name: 'right',
            host: RIGHT_ARM_HOST,
            port: RIGHT_ARM_PORT,
            server_name: SERVER_NAME,
            action_name: ACTION_NAME
        }
    },
    positions: {
        max_left: {
            ...MAX_LEFT,
            roll: ROLL,
            pitch: PITCH,
            yaw: YAW
        },
        max_right: {
            ...MAX_RIGHT,
            roll: ROLL,
            pitch: PITCH,
            yaw: YAW
        }
    }
};
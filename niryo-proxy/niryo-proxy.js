"use strict";

/* const eventemitter2 = require('eventemitter2') */
const config = require('./config.js')
const tools = require('./tools.js')
const rosLib = require('roslib')

let left_config = new tools.ArmConfig(...Object.values(config.arms.left))
let right_config = new tools.ArmConfig(...Object.values(config.arms.right))
let left_arm = new tools.Arm(left_config);
let right_arm = new tools.Arm(right_config);

left_arm.describe();
right_arm.describe();

let left_ready = false
let right_ready = false

let ready = () => {
    return left_ready && right_ready
}

let left_pose = { ...config.positions.max_left }
let right_pose = { ...config.positions.max_left }

left_arm.on('connection', () => {
    left_ready = true
    if (ready()) {
        left_arm.move_pose(left_pose);
        right_arm.move_pose(left_pose);
    }
})

left_arm.on('connection', () => {
    right_ready = true
    if (ready()) {
        left_arm.move_pose(left_pose);
        right_arm.move_pose(left_pose);
    }
})

left_arm.init();
right_arm.init();

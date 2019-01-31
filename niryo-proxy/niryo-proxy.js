"use strict";

/* const eventemitter2 = require('eventemitter2') */
const config = require('./config.js')
const tools = require('./tools.js')
const rosLib = require('roslib')

let left_config = new tools.ArmConfig(...Object.values(config.arms.left))
let right_config = new tools.ArmConfig(...Object.values(config.arms.right))

const express = require('express')
const timeout = require('connect-timeout')
const app = express()
app.use(timeout('1s'))
const port = 3000


const make_arm = (config) => {
    const arm = new tools.Arm(config);
    arm.describe();

    let ready = false
    arm.on('connection', () => ready = true)
    arm.init();

    const failed_callback = (error) => {
        console.error(`${arm.config.name}: rosLib failed callback: ${error}`)
    }

    const not_ready = (result) => {
        if (ready) {
            return false
        }

        result.send('Not ready!')
        return true
    }

    const actions = ['getActionServers', 'getTopics', 'getServices', 'getNodes', 'getParams']

    for (let action of actions) {
        app.get(`/${arm.config.name}/${action}`, (req, res) => {
            if (not_ready(res)) {
                return
            }

            const func = arm.ros[action]
            func((result) => {
                console.log(`${arm.config.name}: ${action}: ${result}`)
                res.send(result)
            }, failed_callback)
        })
    }

    const actions_with_parameter = ['getTopicsForType', 'getServicesForType']

    for (let action of actions) {
        app.get(`/${arm.config.name}/${action}`, (req, res) => {
            if (not_ready(res)) {
                return
            }

            const func = arm.ros[action]
            const param = req.param('param')
            func(param, (result) => {
                console.log(`${arm.config.name}: ${action} (param: ${param}): ${result}`)
                res.send(result)
            }, failed_callback)
        })
    }
}

make_arm(left_config)
make_arm(right_config)

app.get('/', (req, res) => {
    res.send('Hello World!')
})

console.log(`All app routes: ${JSON.stringify(app._router.stack)}`)

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
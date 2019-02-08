"use strict";

/* const eventemitter2 = require('eventemitter2') */
const config = require('./config.js')
const tools = require('./tools.js')
const rosLib = require('roslib')

let left_config = new tools.ArmConfig(...Object.values(config.arms.left))
let right_config = new tools.ArmConfig(...Object.values(config.arms.right))

const express = require('express')
const timeout = require('connect-timeout')
const request = require('request')

const app = express()
app.use(timeout('1s'))
const port = 3000

let stateCallbackUrl = null

const make_arm = (config) => {
    const arm = new tools.Arm(config);
    arm.describe();

    let ready = false
    arm.on('connection', () => ready = true)
    arm.init();

    arm.on('position_change', function(state) {
        if (stateCallbackUrl != null) {
            request({
                method: 'post',
                url: stateCallbackUrl,
                json: state
            }, function(err, resp, body) {
                if (err) console.log(err)
            })
        }
    })

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

            // const func = arm.ros['getTopics'].bind(this)
            arm.ros[action]((result) => {
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

            const param = req.param('param')
            arm.ros[action](param, (result) => {
                console.log(`${arm.config.name}: ${action} (param: ${param}): ${result}`)
                res.send(result)
            }, failed_callback)
        })
    }

    app.get(`/${arm.config.name}/state`, (req, res) => {
        if (not_ready(res)) {
            return
        }
        res.send(arm.state)
    })
}

let left_arm = make_arm(left_config)
let right_arm = make_arm(right_config)

app.use(express.json())

app.get('/', (req, res) => {
    res.send('Hello World!')
})

app.post('/register', (req, res) => {
    if (not_ready(res)) {
        return
    }
    stateCallbackUrl = req.body.callback
    res.send('OK')
})

app.post('/deregister', (req, res) => {
    if (not_ready(res)) {
        return
    }
    stateCallbackUrl = null
    res.send('OK')
})

app.post('/devnull', (req, res) => {
    if (not_ready(res)) {
        return
    }
    console.log('devnull')
    console.log(req.body)
    res.send('OK')
})

let pos1 = {
    x: 0.225,
    y: -0.220,
    z: 0.1,
    roll: 0.0,
    pitch: 1.57,
    yaw: 1.67
}

let pos2 = {
    x: 0.225,
    //    y: 0.220,
    y: 0.0,
    z: 0.1,
    roll: 0.0,
    pitch: 1.57,
    yaw: 1.67
}

let po2 = {...pos1
}
let left = true

app.get('/move', (req, res) => {
    left_arm.move_pose(pos1)
    console.info(`started move!`)

    console.info(`po2: ${JSON.stringify(po2)}`)

    left_arm.move_pose(po2)

    po2.y += 0.05

    console.info(`started second move!`)
    left = !left
})


console.log(`All app routes: ${JSON.stringify(app._router.stack)}`)

app.listen(port, () => console.log(`Example app listening on port ${port}!`))
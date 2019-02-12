"use strict";

/* const eventemitter2 = require('eventemitter2') */
const EventEmitter = require('events');
const config = require('./config.js')
const tools = require('./tools.js')

let left_config = new tools.ArmConfig(...Object.values(config.arms.left))
let right_config = new tools.ArmConfig(...Object.values(config.arms.right))

const express = require('express')
const timeout = require('connect-timeout')
const request = require('request')
const WebSocket = require('ws')

const app = express()
const expressWs = require('express-ws')(app)

app.use(timeout('1s'))
app.use(express.json())

const port = 3000

let stateCallbackUrl = null

class State extends EventEmitter {
    constructor(leftArm, rightArm) {
        super()
        this.left = {}
        this.right = {}

        let that = this

        leftArm.on('state_change', function (state) {
            that.left = state
            that.emitStateChange()
        })

        rightArm.on('state_change', function (state) {
            that.right = state
            that.emitStateChange()
        })
    }

    emitStateChange() {
        this.emit('state_change', {
            "left": this.left,
            "right": this.right
        })
    }

    toString() {
        return JSON.stringify({
            "left": this.left,
            "right": this.right
        })
    }
}

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
        app.get(`/${arm.config.name}/${action}`, (req, result) => {
            if (not_ready(result)) {
                return
            }

            const func = arm.ros[action].bind(arm.ros)
            func((result) => {
                console.log(`${arm.config.name}: ${action}: ${result}`)
                result.send(result)
            }, failed_callback)
        })
    }

    const actions_with_parameter = ['getTopicsForType', 'getServicesForType']

    for (let action of actions) {
        app.get(`/${arm.config.name}/${action}`, (request, result) => {
            if (not_ready(result)) {
                return
            }

            const param = request.param('param')
            const func = arm.ros[action].bind(arm.ros)
            func(param, (result) => {
                console.log(`${arm.config.name}: ${action} (param: ${param}): ${result}`)
                result.send(result)
            }, failed_callback)
        })
    }

    app.get(`/${arm.config.name}/state`, (request, result) => {
        if (not_ready(result)) {
            return
        }
        result.send(arm.state)
    })

    app.get(`/${arm.config.name}/tools`, (request, result) => {
        if (not_ready(result)) {
            return
        }
        result.send(arm.toolList)
    })

    app.post(`/${arm.config.name}/tools`, (request, result) => {
        if (not_ready(result)) {
            return
        }
        arm.changeTool(request.body.toolId)
        result.send()
    })

    app.get(`/${arm.config.name}/open`, (request, result) => {
        if (not_ready(result)) {
            return
        }
        arm.openGrip()
        result.send()
    })

    app.get(`/${arm.config.name}/close`, (request, result) => {
        if (not_ready(result)) {
            return
        }
        arm.closeGrip()
        result.send()
    })

    app.post(`/${arm.config.name}/move`, (request, result) => {
        if (not_ready(result)) {
            console.log('not ready')
            return
        }

        arm.move_pose(request.body)
        result.send('OK')
    })

    return arm
}

let leftArm = make_arm(left_config)
let rightArm = make_arm(right_config)
let state = new State(leftArm, rightArm)

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
    res.send('OK')
})

app.ws('/listen', (ws, req) => {
    ws.send(state.toString())
})

state.on('state_change', function (state) {
    if (stateCallbackUrl != null) {
        request({
            method: 'post',
            url: stateCallbackUrl,
            json: state
        }, function (err, resp, body) {
            if (err) {
                console.error(`${arm.config.name}: rosLib failed callback: ${err}`)
            }
        })
    }
})

state.on('state_change', function (state) {
    let aWss = expressWs.getWss('/listen')
    aWss.clients.forEach(function (client) {
        if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(state))
        }
    });
})

console.log(`All app routes: \n${JSON.stringify(app._router.stack, null, 4)}`)

app.listen(port, "0.0.0.0", () => console.log(`Example app listening on port ${port}!`))
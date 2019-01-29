/* const eventemitter2 = require('eventemitter2') */
const rosLib = require('roslib')

function init() {

    const LEFT_ARM_HOST = '10.10.1.16'
    const LEFT_ARM_PORT = 9090

    const TOUCH_DOWN = {
        'x': 0.225,
        'y': 0.0,
        'z': 0.1,
        'roll': 0.0,
        'pitch': 1.57,
        'yaw': 1.67,
    }

    const TOUCH_LEFT = {
        'x': 0.225,
        'y': -0.220,
        'z': 0.1,
        'roll': 0,
        'pitch': 1.55,
        'yaw': 1.63,
    }

    const TOUCH_RIGHT = {
        'x': 0.225,
        'y': 0.220,
        'z': 0.1,
        'roll': 0,
        'pitch': 1.55,
        'yaw': 1.63,
    }

    var ros = new rosLib.Ros({
        url: 'ws://10.10.1.16:9090'
    });

    // If there is an error on the backend, an 'error' emit will be emitted.
    ros.on('error', function (error) {
        console.log(error);
    });
    // Find out exactly when we made a connection.
    ros.on('connection', function () {
        console.log('Connection made!');

    });
    ros.on('close', function () {
        console.log('Connection closed.');

    });

    var actionClient = new rosLib.ActionClient({
        ros: ros,
        serverName: '/niryo_one/commander/robot_action',
        actionName: 'niryo_one_msgs/RobotMoveAction'
    });

    let counter = 10
    let goalPos = { ...TOUCH_LEFT }

    function move_pose(pos) {
        console.log('move_pose');
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

        // Create a goal.
        var goal = new rosLib.Goal({
            actionClient: actionClient,
            goalMessage: new rosLib.Message({ 'cmd': command })
        });

        goal.on('feedback', function (feedback) {
            console.log('Feedback: ' + feedback.sequence);
        });

        goal.on('result', function (result) {
            console.log('Final Result: ' + result.sequence);

            if (counter > 0) {
                --counter;
                console.log('counter: ' + counter);
                
                goalPos.y += 0.02;
                move_pose(goalPos);
            } else {
                console.log('Done');
            }
        });

        ros.on('connection', function () {
            console.log('Connected to websocket server.');
        });

        ros.on('error', function (error) {
            console.log('Error connecting to websocket server: ', error);
        });

        ros.on('close', function () {
            console.log('Connection to websocket server closed.');
        });
        goal.on('timeout', function () {
            console.log('Timeout!');
        });

        // Send the goal to the action server.
        goal.send(1000);

        console.log('move_pose: goal sent');
    }

    move_pose(TOUCH_LEFT);
}

init();
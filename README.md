# Robot Arm Controls with Python and MXNet


---------------------------


This is meant to run on a [jetson TX2 board](https://www.amazon.com/NVIDIA-945-82771-0000-000-Jetson-TX2-Development/dp/B06XPFH939/ref=sr_1_1?s=electronics&ie=UTF8&qid=1542768659&sr=1-1&keywords=jetson+tx2) connected to 
a [SainSmart 6 axes](https://www.amazon.com/SainSmart-Desktop-Grippers-Assembled-MEGA2560/dp/B00UMOSQCI) robot via i2c.


---------------------------


For terminal control
```python
$ python 
>>> from robot import Robot
>>> robot = Robot()
>>> robot.servos.move_servo_to_percent(0,0)
>>> robot.servos.move_servo_to_percent(0,100)
>>> robot.servos.move_servo_to_percent(4, 0)
>>> robot.servos.move_servo_to_percent(4, 100)
```


# Robot Arm Controls with Python and MXNet


==============================

This is meant to run on a jetson TX2 board connected to 
a SainSmart 6 axes robot via i2c.


==============================
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


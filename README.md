# 6-axis Robot Arm Controls with Python and MXNet


---------------------------


This is meant to run on a [jetson TX2 board](https://www.amazon.com/NVIDIA-945-82771-0000-000-Jetson-TX2-Development/dp/B06XPFH939/ref=sr_1_1?s=electronics&ie=UTF8&qid=1542768659&sr=1-1&keywords=jetson+tx2) connected to 
a [SainSmart 6 axes](https://www.amazon.com/SainSmart-Desktop-Grippers-Assembled-MEGA2560/dp/B00UMOSQCI) robot via i2c.


The robot has a webcam at its extremity and is centering itself on the highest scored person detected in the current frame.

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

----------------------------


Usage:

```
python demo_webcam_run.py --num-frames -1 
```

![demo](https://user-images.githubusercontent.com/3716307/48816323-94f51600-ecf6-11e8-8036-3f985de2ec7d.jpg)

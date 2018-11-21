import logging
import threading
import time

import Adafruit_PCA9685


class Servo:
    def __init__(self, busnum=1):

        self.pwm = Adafruit_PCA9685.PCA9685(busnum=busnum)
        self.servo_min = 150  # Min pulse length out of 4096
        self.servo_max = 600  # Max pulse length out of 4096
        self.amount = [50]*6
        
        # Set frequency to 60hz, good for servos.
        self.pwm.set_pwm_freq(60)

    def move_servo(self, channel, amount):
        if amount > self.servo_max or amount < self.servo_min:
            logging.error('Out of servo range, \
                  try entering a number from {0} to {1}, you entered \
                  {2}'.format(self.servo_min, self.servo_max, amount))
            return False

        self.pwm.set_pwm(channel, 0, amount)

        return True

    def move_servo_to_percent(self, channel, percent):
        value = int(((percent / 100.0) * (self.servo_max - self.servo_min)) + self.servo_min)

        logging.info("SERVO::Move channel {0} to {1} percent. Value of {2}"
                      .format(channel, percent, value))

        if self.move_servo(channel, value):
            self.amount[channel] = percent
        

class Robot:

    # Maximum ranges, for example to protect the robot from hurting itself
    ranges = [
        (10,  90), #0: base-left-right
        (10, 80), #1: close-far
        (0,  20),  #2: elongate
        (47, 47), #3: rotate axis
        (10, 90), #4: look up down
        (52, 52), #5: rotate camera
    ]
    
    multipliers = [0.5, 0.2, None, None, 0.1, None]
    
    LEFT_RIGHT = 0
    CLOSE_FAR = 1
    ELONGATE = 2
    ROTATE_AXIS = 3
    UP_DOWN = 4
    ROTATE_CAMERA = 5
    
    def __init__(self, commands_per_second=200., percent_per_cmd=0.1):

        self.servos = Servo()
        
        self.global_lock = {
            'lock':[None]*6
        }

        self.commands_per_second = commands_per_second
        self.percent_per_cmd = percent_per_cmd
        self.frequency = 1./self.commands_per_second
        self.sleep()

    def move_robot_tracking(self, increment, channel, final_value, lock):
        if self.global_lock['lock'][channel] is not lock:
            logging.info("Lock stolen on channel {}".format(channel))
            return
            # If a new command has been issued, stop current
            
        current_value = self.servos.amount[channel]
        new_value = current_value + increment

        if abs(final_value - current_value) > self.percent_per_cmd:
            # Execute next command
            self.servos.move_servo_to_percent(channel, new_value)
            threading.Timer(self.frequency, self.move_robot_tracking, [increment, channel, final_value, lock]).start()
            

    def center_robot(self, channel, delta):
        current_value = self.servos.amount[channel]
        min_value, max_value = self.ranges[channel]
        increment = self.percent_per_cmd

        if delta > 0:
            increment *= -1

        final_value = max(min(current_value - 0.1*delta*(max_value-min_value), max_value), min_value)

        lock = {}
        logging.info("Current value {}, moving to final value {} on channel {}".format(current_value, final_value, channel))
        self.global_lock['lock'][channel] = lock        
        self.move_robot_tracking(increment, channel, final_value, lock)

    def sleep(self):
        self.servos.move_servo_to_percent(Robot.LEFT_RIGHT, 50)
        self.servos.move_servo_to_percent(Robot.CLOSE_FAR, 50)
        self.servos.move_servo_to_percent(Robot.ELONGATE, 10)
        self.servos.move_servo_to_percent(Robot.ROTATE_AXIS, 47)
        self.servos.move_servo_to_percent(Robot.UP_DOWN, 60)
        self.servos.move_servo_to_percent(Robot.ROTATE_CAMERA, 52)

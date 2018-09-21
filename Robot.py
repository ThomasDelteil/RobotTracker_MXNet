from components import Report, Servo
import time
import threading 

class Robot:
    
    ranges = [
        (20, 70), #0: base-left-right
        (30, 70), #1: close-far
        (10, 20), #2: elongate
        (57, 57), #3: rotate axis
        (30, 90),#4: look up down
        (10, 10), #5: rotate camera
    ]
    
    multipliers = [30./100., 30./60., None, None, 19./50., None]
    
    LEFT_RIGHT = 0
    UP_DOWN = 4
    CLOSE_FAR = 1
    
    def __init__(self, frequency=0.02, cycle=0.9):
        report = Report()
        self.servo = Servo(report)

        config = {
            'report': report,
            'servo': self.servo,
        }
        
        self.global_lock = {
            'lock':[None]*6
        }
        self.frequency = frequency 
        self.cycle = cycle
        
        self.total_number = self.cycle/self.frequency
        self.sleep()

    def move_robot_tracking(self, i, channel, final_value, lock):
        if self.global_lock['lock'][channel] is not lock:
            print("Lock stolen")
            return
            # If a new command has been issued, stop current
            
        current_value = self.servo.amount[channel]
        new_value = current_value + (final_value - current_value) / (self.total_number-i + 1)
        self.servo.move_servo_to_percent(channel, new_value)

        if i < self.total_number and round(final_value*100) != round(current_value*100):
            # Execute next command
            threading.Timer(self.frequency, self.move_robot_tracking, [i+1, channel, final_value, lock]).start()
            

    def center_robot(self, channel, delta):
        multiplier = self.multipliers[channel]
        current_value = self.servo.amount[channel]
        min_value, max_value = self.ranges[channel]
        #delta = delta*self.multipliers[channel]
        print(min_value, max_value, multiplier)
        print(current_value, delta)
        print(delta*(max_value-min_value)/multiplier)
        if delta > 0:
            new_value = max(current_value - delta*(max_value-min_value)*multiplier, min_value)
        if delta < 0:
            new_value = min(current_value - delta*(max_value-min_value)*multiplier, max_value)
        lock = {}
        self.global_lock['lock'][channel] = lock        
        self.move_robot_tracking(0, channel, new_value, lock)

    def sleep(self):
        self.servo.move_servo_to_percent(0, 50)
        self.servo.move_servo_to_percent(1, 50)
        self.servo.move_servo_to_percent(2, 10)
        self.servo.move_servo_to_percent(3, 57)
        self.servo.move_servo_to_percent(4, 70)
        self.servo.move_servo_to_percent(5, 10)

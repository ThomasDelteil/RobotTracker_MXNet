# common imports
import time

import mxnet as mx
import numpy as np

from mtcnn import get_mtcnn

# Camera imports
from picamera import PiCamera
from PIL import Image
import io

# SSD imports
import gluoncv as gcv

from scipy import ndimage

from mxnet import nd
from gluoncv.model_zoo import get_model

#Robot imports
from Robot import Robot

import math

model = 'mtcnn'
resolution = (300, 220)
num = 10000

if model == 'mtcnn':
    detector = get_mtcnn()
    
    def get_bounding_boxes(image):
        return detector.detect_face(image)[0].tolist()
    
robot = Robot()

with PiCamera() as camera:
    camera.resolution = resolution
    print("Sleeping for a bit")
    time.sleep(4)
    print("Starting streaming images")
    stream = io.BytesIO()
    for i, _ in enumerate(camera.capture_continuous(stream, format='jpeg', burst=True)):
        tic = time.time()
        image = np.array(Image.open(stream))
        stream.truncate()
        stream.seek(0)
        stream.flush()
        output = detector.detect_face(image)
        if output is not None:
            output = output[0][0].tolist()
            if output[4] > 0.95:
                x1, y1, x2, y2, score = output
                x1 /= max(0, camera.resolution[0])
                x2 /= max(0, camera.resolution[0])
                y1 /= max(0, camera.resolution[1])
                y2 /= max(0, camera.resolution[1])

                area_ratio = (x2-x1)*(y2-y1) - 0.15
                clock_turn = (x2 + x1)/2 - 0.5
                high_low = (y2 + y1)/2 - 0.5

                robot.center_robot(robot.LEFT_RIGHT, clock_turn)
                robot.center_robot(robot.UP_DOWN, high_low)
                sign = -1 if area_ratio < 0 else 1
                robot.center_robot(robot.CLOSE_FAR, sign*math.sqrt(abs(area_ratio)))
        print("{:.2f}s".format(time.time()-tic), output is not None)
        #if i == num-1:
        #    break


    

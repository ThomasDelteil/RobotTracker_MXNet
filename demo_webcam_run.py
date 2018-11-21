import argparse
import logging
from math import exp as e
import math
import time
import threading 

import cv2
import gluoncv as gcv
import mxnet as mx
from mxnet import nd

from robot import Robot

logging.basicConfig(level=logging.INFO)

parser = argparse.ArgumentParser(description="Webcam object detection script",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)

parser.add_argument('--num-frames', type=int, default=200,
                    help='number of frames to run the demo for. -1 means infinite')


args = parser.parse_args()

def print_event(event, tic):
   print("{} lasted {:.4f}s".format(event, (time.time()-tic)))

# Preprocessing
MEAN = (0.485, 0.456, 0.406)
STD = (0.229, 0.224, 0.225)

# CV2 Frames
SHAPE=(480, 640)
HEIGHT = 300.
CAPTURE_INDEX = 1
INFINITE_FRAME = -1
WINDOW_NAME = 'image'
CV_WAIT_KEY = 25
COLOURS = [(0,255,0), (0,0,255), (255, 0, 0)]
NUM_FRAMES = args.num_frames

# Box detection
OBJECT_DETECTION_MODEL = 'ssd_512_mobilenet1.0_voc'
CLASS_HUMAN = 14
HEAD_RATIO = 0.99
SCORE_THRESHOLD = 0.5

# Exponential Decay
ALPHA = 3.5
MAX_LEN = 30
OUTLIER_THRESHOLD = 0.08
NO_TARGET_THRESHOLD = 20
KEEP_REMINDER_OUTLIER = 10

def preprocess(frame, new_height=HEIGHT):
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    old_height = frame.shape[0]
    old_width = frame.shape[1]
    r = new_height / old_height
    new_width = int(old_width * r)
    dim = (new_width, int(old_height))
    frame = cv2.resize(frame, dim)

    rgb_nd = nd.image.normalize(nd.image.to_tensor(nd.array(frame)), mean=MEAN, std=STD)
    return frame, rgb_nd.expand_dims(axis=0), r

def display_frame(frame, bb, hc, target, colours=COLOURS):
    index = 0
    for ((x1,y1,x2,y2),(x3,y3)) in zip(bb, hc):
         X1 = (max(0, int(x1)), max(0, int(y1)))
         X2 = (max(0, int(x2)), max(0, int(y2)))
         X3 = (max(0, int(x3)), max(0, int(y3)))
         cv2.rectangle(frame, X1, X2, colours[index], 1) # person bounding box
         cv2.circle(frame, X3, 5, colours[index], 5) # "Head"
         index = 1
         print(X1, X2)
    
    cv2.circle(frame, target, 5, colours[2], 5) # Robot target
    cv2.imshow(WINDOW_NAME, frame)
    cv2.waitKey(CV_WAIT_KEY)

def get_valid_boxes(class_IDs, scores, bounding_boxes, r):
    # Convert to numpy
    class_IDs = class_IDs[0].asnumpy()
    scores = scores[0].asnumpy()
    bounding_boxes = bounding_boxes[0].asnumpy()

    # Get the valid bounding box resized to proper ratio
    output_bb = []
    head_centers = []
    for c, s, bb in zip(class_IDs, scores, bounding_boxes):
        if c == CLASS_HUMAN and s > SCORE_THRESHOLD:
            output_bb.append((bb[0]/r, bb[1]/r, bb[2]/r, bb[3]/r))
            head_centers.append(((bb[2]+bb[0])/(2*r), (HEAD_RATIO*bb[1]+(1-HEAD_RATIO)*bb[3])/r))
    return output_bb, head_centers

def get_next_target(current_list, current_value, last_value, was_outlier):

    # Check if current value is outlier or not
    is_outlier = False
    if (abs(current_list[0][0] - current_value[0])/float(SHAPE[0]) > OUTLIER_THRESHOLD or 
        abs(current_list[0][1] - current_value[1])/float(SHAPE[1]) > OUTLIER_THRESHOLD):
        is_outlier = True
        print("It's an outlier!")

    # reset the target
    if (was_outlier and is_outlier): 
        current_list = [current_value]+current_list[:KEEP_REMINDER_OUTLIER]
        is_outlier = False
        print("Two outliers in a row, resetting the list!")

    # If too long, pop the last, add the newest one
    elif not is_outlier:
        current_list.insert(0, current_value)
        if len(current_list) > MAX_LEN:
            current_list.pop()

    # Exponential decay for averaging        
    norm = sum([e(ALPHA/(i+1)) for i in range(len(current_list))])
    x_target = sum([e(ALPHA/(i+1))*max(x,0) for i, (x, _) in enumerate(current_list)])/norm
    y_target = sum([e(ALPHA/(i+1))*max(y,0) for i, (_, y) in enumerate(current_list)])/norm

    return (current_list, (int(x_target), int(y_target)), is_outlier)

if __name__ == '__main__':

    # Start the robot
    robot = Robot()

    # Load the model
    ctx = mx.gpu()
    net = gcv.model_zoo.get_model(OBJECT_DETECTION_MODEL, pretrained=True, ctx=ctx)
    net.hybridize(static_shape=True, static_alloc=True)

    # Load the webcam handler
    cap = cv2.VideoCapture(CAPTURE_INDEX)
    time.sleep(1)  ### letting the camera autofocus
    window = cv2.namedWindow(WINDOW_NAME, cv2.WINDOW_NORMAL)

    # Main Processing Loop
    no_target_counter = 10000
    i = 0
    while i < NUM_FRAMES or NUM_FRAMES == INFINITE_FRAME:
        i += 1

        # Load frame from the camera
        tic_capture = time.time()
        ret, frame_read = cap.read()

        # Image pre-processing
        tic_processing = time.time()
        frame, rgb_nd, r = preprocess(frame_read)
        #print_event("Processing", tic_processing)

        # Run frame through network
        tic_network = time.time()
        class_IDs, scores, bounding_boxes = net(rgb_nd.as_in_context(ctx))
        #print_event("Network", tic_network)

        # Post processing
        bb, head_centers = get_valid_boxes(class_IDs, scores, bounding_boxes, r)

        ## Get the target for the robot
        if no_target_counter > NO_TARGET_THRESHOLD:
            current_target = (int(SHAPE[1]/2), int(SHAPE[0]/2))
            current_list = [current_target]
            is_outlier = True
            robot.sleep()

        if len(head_centers): 
            current_list, current_target, is_outlier = get_next_target(current_list, head_centers[0], current_target, is_outlier)
            no_target_counter = 0
        else:
            no_target_counter += 1

        # Display
        threading.Thread(target=display_frame, args=[frame_read, bb, head_centers, current_target]).start()

        # Move Robot
        (x1,y1) = current_target
        clock_turn = (x1 - SHAPE[1]/2.)/float(SHAPE[1])
        high_low = (y1 - SHAPE[0]/2.)/float(SHAPE[0])

        robot.center_robot(robot.LEFT_RIGHT, clock_turn)
        robot.center_robot(robot.UP_DOWN, 0.5*high_low)

        if len(bb):
            area_ratio = (bb[0][2]-bb[0][0])*(bb[0][3]-bb[0][1])/(SHAPE[0]*SHAPE[1]) - 0.5
            sign = -1 if area_ratio < 0 else 1
            robot.center_robot(robot.CLOSE_FAR, sign*math.sqrt(abs(area_ratio)))


        print_event("Total", tic_capture)
        print("=============")

    cap.release()

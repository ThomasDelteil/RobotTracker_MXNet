from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import time

import mxnet as mx
import numpy as np


# MTCNN imports
import sys
import os
from scipy import misc
import random

from easydict import EasyDict as edict
from ArcFace.mtcnn_detector import MtcnnDetector

from mxnet.contrib.onnx.onnx2mx.import_model import import_model



def get_mtcnn():
    # Download model
    for i in range(4):
        mx.test_utils.download(dirname='ArcFace/mtcnn-model', url='https://s3.amazonaws.com/onnx-model-zoo/arcface/mtcnn-model/det{}-0001.params'.format(i+1))
        mx.test_utils.download(dirname='ArcFace/mtcnn-model', url='https://s3.amazonaws.com/onnx-model-zoo/arcface/mtcnn-model/det{}-symbol.json'.format(i+1))

    # Determine and set context
    ctx = mx.cpu()
    det_threshold = [0.6,0.7,0.8]
    mtcnn_path = os.path.join(os.path.dirname('__file__'), 'ArcFace/mtcnn-model')
    detector = MtcnnDetector(model_folder=mtcnn_path, ctx=ctx, num_worker=1, accurate_landmark = False, threshold=det_threshold)
    return detector

from __future__ import print_function
import keras
import cv2
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
from datetime import datetime
from keras.models import load_model

from PIL import Image
import numpy as np
from skimage import transform

def load(filename):
   np_image = Image.open(filename)
   np_image = np.array(np_image).astype('float32')
   np_image = np_image/255
   #np_image = np_image.astype('int8')
   np_image = transform.resize(np_image, (28, 28, 1))
   np_image = np.expand_dims(np_image, axis=0)
   return np_image

  
#model = load_model('/home/vonfaust/data/accelerator/keras/mnist_cnn_model_int8_small.h5')
model = load_model('/home/vonfaust/data/accelerator/keras/mnist_cnn_model_float32_small.h5')

#model = load_model('/home/vonfaust/data/accelerator/keras/mnist_cnn_model_float32_ch_last.h5')
image = load("/home/vonfaust/data/accelerator/keras/mnist_dataset/testing/9/1005.png")
a = model.predict(image)
print(a)
print(np.argmax(a, axis = 1))



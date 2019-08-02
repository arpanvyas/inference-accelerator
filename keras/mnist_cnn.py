'''Trains a simple convnet on the MNIST dataset.
Gets to 99.25% test accuracy after 12 epochs
(there is still a lot of margin for parameter tuning).
16 seconds per epoch on a GRID K520 GPU.
'''

from __future__ import print_function
import keras
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
from datetime import datetime

batch_size = 128
num_classes = 10
epochs = 4

# input image dimensions
img_rows, img_cols = 28, 28

# the data, split between train and test sets
(X_train, Y_train), (X_test, Y_test) = mnist.load_data()

X_train = X_train[0:6000,:,:]
Y_train = Y_train[0:6000]
X_test = X_test[0:1200,:,:]
Y_test = Y_test[0:1200]

if K.image_data_format() == 'channels_first':
    X_train = X_train.reshape(X_train.shape[0], 1, img_rows, img_cols)
    X_test = X_test.reshape(X_test.shape[0], 1, img_rows, img_cols)
    input_shape = (1, img_rows, img_cols)
else:       #evaluates else as format is 'channels_last'
    X_train = X_train.reshape(X_train.shape[0], img_rows, img_cols, 1)
    X_test = X_test.reshape(X_test.shape[0], img_rows, img_cols, 1)
    input_shape = (img_rows, img_cols, 1)



#list_dtype = ['int8'] #['int8', 'int16', 'float16','float32']
list_dtype = ['float16'] #['int8', 'int16', 'float16','float32']



for np_dtype in list_dtype:

  x_train = X_train.astype(np_dtype)
  x_test = X_test.astype(np_dtype)
  x_train /= 255
  x_test /= 255
  print('x_train shape:', x_train.shape)
  print(x_train.shape[0], 'train samples')
  print(x_test.shape[0], 'test samples')
	
  print(x_train.shape[0], 'train samples')
  print(x_test.shape[0], 'test samples')
  print(x_test[0])
  #exit()

  # convert class vectors to binary class matrices
  y_train = keras.utils.to_categorical(Y_train, num_classes)
  y_test = keras.utils.to_categorical(Y_test, num_classes)

  model = Sequential()
  model.add(Conv2D(32, kernel_size=(3, 3),
                   activation='relu',
                   input_shape=input_shape))
  model.add(Conv2D(64, (3, 3), activation='relu'))
  model.add(MaxPooling2D(pool_size=(2, 2)))
  #model.add(Dropout(0.25))
  model.add(Flatten())
  model.add(Dense(128, activation='relu'))
  #model.add(Dropout(0.5))
  model.add(Dense(num_classes, activation='softmax'))

  model.compile(loss=keras.losses.categorical_crossentropy,
                optimizer=keras.optimizers.Adadelta(),
                metrics=['accuracy'])

  model.fit(x_train, y_train,
            batch_size=batch_size,
            epochs=epochs,
            verbose=1,
            validation_data=(x_test, y_test))


  tstart = datetime.now()
  score = model.evaluate(x_test, y_test, verbose=0)
  tend = datetime.now()

  telap = tend - tstart
  print("tend: " + str(tend))
  print("tstart: " + str(tstart))
  print("telap: " + str(telap))
  print("tper_img: " + str(telap/1200))


  
  model.save('/home/vonfaust/data/accelerator/keras/mnist_cnn_model_'+np_dtype+'.h5')

 # loss_accu = open("/home/arpan/Desktop/Inference Accelerator/HDL Model/Keras models/mnist_cnn_accu_loss.txt","a")
  #loss_accu.write(np_dtype+'; Epochs: 4; '+'Train Images: 12000; '+'Test Images: 1200; ' +'Optimizer: Adadelta; ' )
#  loss_accu.write("Accuracy: "+str(score[1])+"; ")
#  loss_accu.write("Categorical Crossentrpy Loss: "+str(score[0]))
#  loss_accu.write("\n")
#  loss_accu.close()


  print('Test loss:', score[0])
  print('Test accuracy:', score[1])

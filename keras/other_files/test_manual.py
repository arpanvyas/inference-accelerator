from __future__ import print_function
import keras
import numpy as np
import cv2
from keras.datasets import mnist
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
from keras.models import load_model
from keras.utils import plot_model

dtp = 'float32'


def conv2d(image,weights,bias,activation,pooling):
	kernel = weights.shape[0]
	kernel_offset = (kernel-1)/2 #assuming odd number
	channels = weights.shape[2]
	filters  = weights.shape[3]

	rows = image.shape[1]
	cols = image.shape[2]

	output = np.zeros([filters,rows-kernel+1,cols-kernel+1],dtype=dtp)

	for filt in range(0,filters):

		for ch in range(0,channels):

			filter1 = np.zeros([kernel,kernel],dtype=dtp)
			for i in range(0,kernel):
				for j in  range(0,kernel):
					filter1[i,j] = weights[i,j,ch,filt]

			for i in range(kernel_offset,rows-kernel_offset):
				for j in range(kernel_offset,cols-kernel_offset):
					val = 0
					for i1 in range(-kernel_offset,kernel_offset+1):
						for j1 in range(-kernel_offset,kernel_offset+1):
							val += image[ch,i+i1,j+j1]*filter1[i1+kernel_offset,j1+kernel_offset]

					output[filt,i-kernel_offset,j-kernel_offset] += val

		output[filt] += bias[filt]

	if(activation=='relu'):  
		for i in range(0,filters):
			for j in range(0,rows-kernel+1):
				for k in range(0,cols-kernel+1):
					if(output[i,j,k] < 0):
						output[i,j,k] = 0


	if(pooling=='maxpool'):
		output1 = np.zeros([filters,(rows-kernel+1)/2,(cols-kernel+1)/2],dtype=dtp)

		for i in range(0,filters):
			j1 = 0

			for j in range(0,rows-kernel+1,2):
				k1 = 0
				for k in range(0,cols-kernel+1,2):
					output1[i,j1,k1] = max(output[i,j,k], output[i,j+1,k], output[i,j,k+1], output[i,j+1,k+1] )
					k1 = k1+1
				j1 = j1+1
		output = output1

	return output


def dense(layer1,weights,bias):
	input_neu = weights.shape[0]
	output_neu = weights.shape[1]

	output = np.zeros([output_neu],dtype=dtp)

	for i in range(0,output_neu):
		for j in range(0,input_neu):
			output[i] += layer1[j]*weights[j,i]
		output[i]	+= bias[i]

	return output

def reshape_ch_first_to_last(inp):
    axis0 = inp.shape[0]
    axis1 = inp.shape[1]
    axis2 = inp.shape[2]

    out = np.zeros([axis1,axis2,axis0],dtype=dtp)

    for i in range(0,axis1):
        for j in range(0,axis2):
            for k in range(0,axis0):
                out[i,j,k] = inp[k,i,j]

    return out



def doall(img_path, weights, conf):

    prinfo = 0
    print(img_path)

    img = cv2.imread(img_path,2)
    
    img = img.astype(dtype=dtp)
    img = img/255
    
    img1 = np.zeros([1,28,28],dtype=dtp)
    img1[0,:,:] = img
    img = img1
    #print(img)
    
    
    conv2d_1 = conv2d(img,weights[0],weights[1],'relu','nopool')
    conv2d_2 = conv2d(conv2d_1,weights[2],weights[3],'relu','maxpool')
    #reshape2d_2 = np.moveaxis(conv2d_2,0,-1) #channel_last to channel_first
    #flatten2d_2 = np.reshape(conv2d_2,(9216))
    #flatten2d_2 = np.reshape(reshape2d_2,(9216))
    flatten2d_2 = np.reshape(conv2d_2,(9216))
    layer1 = dense(flatten2d_2,weights[4],weights[5])
    layer2 = dense(layer1,weights[6],weights[7])
    
    if(prinfo == 1):
        #print(img)
        print(img.shape)
        print(conv2d_1.shape)
        print(conv2d_2.shape)
        print(reshape2d_2.shape)
        print(flatten2d_2.shape)
        print(layer1.shape)
        #print(layer1)

    print(layer2)
    print(np.argmax(layer2))





main_directory = '/home/vonfaust/data/accelerator/keras/'
file = 'mnist_cnn_model_'+dtp+'_ch_last.h5'
path = main_directory + file
model = load_model(path)


weights = model.get_weights()
weights[4] = np.reshape(np.moveaxis(weights[4].reshape([12,12,64,128]),2,0),(9216,128))
conf = model.get_config()

#print(weights[0].shape)
#print(weights[1].shape)
#print(weights[2].shape)
#print(weights[3].shape)
#print(weights[4].shape)
#print(weights[5].shape)
#print(weights[6].shape)
#print(weights[7].shape)


doall(main_directory+"mnist_dataset/training/2/12501.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/7/4821.png",weights,conf)
#
#
#doall(main_directory+"mnist_dataset/testing/0/845.png",weights,conf)
#doall(main_directory+"mnist_dataset/testing/0/6651.png",weights,conf)
#doall(main_directory+"mnist_dataset/testing/0/592.png",weights,conf)
#doall(main_directory+"mnist_dataset/testing/0/6711.png",weights,conf)
#doall(main_directory+"mnist_dataset/testing/0/750.png",weights,conf)
#doall(main_directory+"mnist_dataset/testing/0/9911.png",weights,conf)
#doall(main_directory+"mnist_dataset/testing/0/993.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/0/997.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/0/1692.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/0/1692.png",weights,conf)

doall(main_directory+"mnist_dataset/testing/1/37.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/5943.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/4212.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/2.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/14.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/137.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/154.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/9946.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/7717.png",weights,conf)
doall(main_directory+"mnist_dataset/testing/1/818.png",weights,conf)

doall(main_directory+"mnist_dataset/testing/1/818.png",weights,conf)


#weights[2].shape == (3,3,32,64)
# img_r = conv2d_2*255
# img_r = img_r.astype('uint8')

# #cv2.waitKey(0)

# for i in range(0,64):
# 	cv2.imshow('window'+str(i),img_r[i])
# 	cv2.waitKey(0)

#print(weights[0].shape)
#print(weights[1].shape)
#print(weights[2].shape)
#print(weights[3].shape)
#print(weights[4].shape)
#print(weights[5].shape)
#print(weights[6].shape)
#print(weights[7].shape)

  


#print(weights[0].shape)
#print(weights[0][0][0][0][0])
#print(weights[0][0][0])






















##RECONSTRUCTION
# img_r = conv2d_1*255 
# #print(img_r)
# img_r = img_r
# img_r = img_r.astype('uint8')

# img = img*255
# img = img.astype('uint8')

# print(img_r.shape)
# print(img_r[0])
# print(filt)
# print(val+bias)

# for i in range(0,32):
# 	s1 = str(i)
# 	cv2.imshow('window'+s1,img_r[i ])
# 	cv2.waitKey(0)

from __future__ import print_function
import keras
from keras.models import Sequential
from keras.layers import Dense, Dropout, Flatten
from keras.layers import Conv2D, MaxPooling2D
from keras import backend as K
from keras.models import load_model
from keras.utils import plot_model
from keras.models import model_from_json
from mem_param import mem_param as mem
import math
import binary as b1



from mem_param import mem_param as mem

main_directory = '/home/vonfaust/data/accelerator/keras/'
file = 'mnist_cnn_model_int8.h5'
path = main_directory + file
model = load_model(path)

weights = model.get_weights()
conf = model.get_config()


mem_map = [] # [ ['0x000100','length_in_bytes','layer#_type_filt.filt#_ch.ch#_img.img#ch'], [], [] ]

def dump_conv(dumpfile,mem_map,mem_start,this_layer):

    progparam = []
   
    layer_num = this_layer['number']
    wt = this_layer['weight']
    use_bias = this_layer['use_bias']
    if(use_bias):
        bias = this_layer['bias']
    filters = this_layer['filters']
    input_shape = this_layer['shape']
    channels = input_shape[3]
    strides = this_layer['stride_shape']
    use_bias = this_layer['use_bias']
    kernel_size = this_layer['kernel_shape']
    kernel_h = kernel_size[0]
    kernel_w = kernel_size[1]
    padding = this_layer['pad_shape']
    activation = this_layer['activation']
    mem_ptr = mem_start

    for filt in range(0,filters):
        mem_idx0 = 0
	for ch in range(0,channels):
            mem_idx = 0
            for row in range(0,kernel_h):
                    for col in range(0,kernel_w):
                        dat = wt[row][col][ch][filt]*mem.scale
                        bina = b1.int2bin(dat,mem.frac_size,mem.word_size)
                        dumpfile.write(bina+'\n')
                        mem_idx += mem.word_per_byte
            memstr = 'layer'+str(layer_num)+'_conv_filt'+str(filt)+'_ch'+str(ch)+'_coeff'
            mem_map.append([mem_ptr,mem_idx,memstr])
            mem_ptr +=mem_idx
            


        if(use_bias):
            dat = bias[filt]*mem.scale
            bina = b1.int2bin(dat,mem.frac_size,mem.word_size)
            dumpfile.write(bina+'\n')
            mem_idx0 += mem.word_per_byte
            memstr = 'layer'+str(layer_num)+'_conv_filt'+str(filt)+'_ch'+str(ch)+'_bias'
            mem_map.append([mem_ptr,mem_idx0,memstr])
            mem_ptr += mem_idx0

    return mem_ptr
    
       
def dump_dense(dumpfile,mem_map,mem_start,this_layer):

    progparam = []
   
    layer_num = this_layer['number']
    wt = this_layer['weight']
    use_bias = this_layer['use_bias']
    if(use_bias):
        bias = this_layer['bias']
    shape = this_layer['shape']
    input_nodes = shape[0]
    output_nodes = shape[1]
    use_bias = this_layer['use_bias']
    activation = this_layer['activation']
    mem_ptr = mem_start

    for out in range(0,output_nodes):
        mem_idx0 = 0
        mem_idx = 0
        for inp in range(0,input_nodes):
            dat = wt[inp][out]*mem.scale
            bina = b1.int2bin(dat,mem.frac_size,mem.word_size)
            dumpfile.write(bina+'\n')
            mem_idx += mem.word_per_byte

        memstr = 'layer'+str(layer_num)+'_dense_outnode'+str(out)
        mem_map.append([mem_ptr,mem_idx,memstr])
        mem_ptr += mem_idx

        if(use_bias):
            dat = bias[out]*mem.scale
            bina = b1.int2bin(dat,mem.frac_size,mem.word_size)
            dumpfile.write(bina+'\n')
            mem_idx0 += mem.word_per_byte
            memstr = 'layer'+str(layer_num)+'_dense_outnode'+str(out)+'_bias'
            mem_map.append([mem_ptr,mem_idx0,memstr])
            mem_ptr +=mem_idx0

    return mem_ptr
    

#dumpfile = open("test","w")

#c1 = conf['layers'][0]['config']

#dump_conv(dumpfile,mem_map,0x0,c1,0,weights[0],weights[1])
#print(*mem_map,sep = "\n")

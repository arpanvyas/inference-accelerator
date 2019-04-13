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
import cv2
from mem_param import mem_param as mem


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
    

def dump_inp_img(dumpfile,this_inp):

    shape = this_inp.shape
    input_hei = shape[0]
    input_wid = shape[1]

    mem_idx = 0

    for h in range(0,input_hei):
        for w in range(0,input_wid):
            dat = this_inp[h][w]
            bina = b1.int2bin(dat,mem.frac_size,mem.word_size)
            dumpfile.write(bina+'\n')
            mem_idx += mem.word_per_byte

    return mem_idx
    
def model_to_ram(all_layers,mem_model_dump,mem_map_dump):
    
    mem_map_model = []
    mem_ptr = mem.ram_model_start
    
    mem_model_dump_file = open(mem_model_dump,"w")
    for this_layer in all_layers:
        if(this_layer['type'] == "Conv2D"):
            mem_ptr = dump_conv(mem_model_dump_file,mem_map_model,mem_ptr,this_layer)
        elif(this_layer['type'] == "Dense"):
            mem_ptr = dump_dense(mem_model_dump_file,mem_map_model,mem_ptr,this_layer)


    mem_map_model_file = open(mem_map_dump,"w")
    for item in mem_map_model:
        mem_map_model_file.write("%s\n" % item)


    mem_model_dump_file.close()
    mem_map_model_file.close()

    model_mem_size = mem_ptr - mem.ram_model_start 
    print("model mem size: ",str(model_mem_size))
    print("model allocated size: ",str(mem.model_allocation))
    if(model_mem_size > mem.model_allocation):
        print("Model memory consumption more than allocated")

    return mem_map_model


def img_to_ram(input_list_file,mem_inp_dump,mem_map_dump):
    ilf = open(input_list_file)
    input_list = ilf.read().splitlines()

    mem_map_input = []


    dumpfile = open(mem_inp_dump,"w")

    mem_ptr = mem.ram_input_start

    input_num = 0

    for item in input_list:
        img = cv2.imread(item,0)
        img = img.astype(float)
        img /= 255
        
        mem_idx = dump_inp_img(dumpfile,img)


        memstr = 'input'+str(input_num)

        mem_map_input.append([mem_ptr,mem_idx,memstr])
        mem_ptr += mem_idx
        input_num += 1


    mem_map_input_file = open(mem_map_dump,"w")
    for item in mem_map_input:
        mem_map_input_file.write("%s\n" % item)


    ilf.close()
    mem_map_input_file.close()
    dumpfile.close()
    

    input_mem_size = mem_ptr - mem.ram_input_start
    print("input mem size: ",str(input_mem_size))
    print("input allocated size: ",str(mem.input_allocation))
    if(input_mem_size > mem.input_allocation):
        print("Input memory consumption more than allocated")

    return mem_map_input

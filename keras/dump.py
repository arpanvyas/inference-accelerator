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
            memstr = 'layer'+str(layer_num)+'_conv_filt'+str(filt)+'_bias'
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

    print("--------------------------------------------------------------")
    model_mem_size = mem_ptr - mem.ram_model_start 
    print("Model Memory Size: ",str(model_mem_size))
    print("Model Allocated Memory size: ",str(mem.model_allocation))
    if(model_mem_size > mem.model_allocation):
        print("Model memory consumption more than allocated.")

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
    print("--------------------------------------------------------------")
    print("Input Memory Size: ",str(input_mem_size))
    print("Input Allocated Memory Size: ",str(mem.input_allocation))
    if(input_mem_size > mem.input_allocation):
        print("Input memory consumption more than allocated.")

    return mem_map_input


def interm_to_ram(all_layers,interm_map_dump,input_map,output_map,input_index):
    #find memlocn of input_index
    flag_ip = 0
    for i in range(0,len(input_map)):
        if(input_map[i][2] == "input"+str(input_index)):
            mem_input = input_map[i][0]
            mem_input_size = input_map[i][1]
            flag_ip = 1
            break

    #find memlocn of output_index
    flag_op = 0
    for i in range(0,len(output_map)):
        if("final_output_input"+str(input_index) in output_map[i][2]):
            mem_output = output_map[i][0]
            flag_op = 1
            break

    if(flag_ip == 0):
        print("Input Index: "+str(input_index)+" not found in input map.")
        return
    else:
        a = 0
        #print(mem_input)
        #print(mem_input_size)
        #print(i)
        #return

    if(flag_op == 0):
        print("Output Index: "+str(input_index)+" not found in output map.")
        return


    interm_map = []

    first_layer = all_layers[0]
    if(first_layer['type'] == "Conv2D"):
        ch_first    = first_layer['shape'][3]
        size_first  = first_layer['shape'][1]*first_layer['shape'][2]
        mem_ptr     = mem_input
        for c in range(0,ch_first):
            mem_idx     = size_first*mem.word_per_byte
            interm_map.append([mem_ptr, mem_idx, 'input_layer0_ch'+str(c)])
            mem_ptr    += mem_idx
    else:
        print("Conv2D as not first layer not supported.")
        return

    interm_mem_start    = mem.ram_buffer_start
    mem_ptr             = interm_mem_start

    l_idx = 1
    last_map = []

    for layer in all_layers[1:]:
        #print(layer['type'])

        if(layer['type'] == "Conv2D"):
            shape   = layer['shape']
            ch      = shape[3]
            hei     = shape[1]
            wid     = shape[2]

            #print('conv',hei,wid,hei*wid,hei*wid*2)

            for c in range(0,ch):
                mem_idx = 0
                mem_idx += hei*wid*mem.word_per_byte
                interm_map.append([mem_ptr,mem_idx,'input_layer'+str(l_idx)+"_ch"+str(c)])
                mem_ptr += mem_idx

        elif(layer['type'] == "Dense"):
            shape   = layer['shape']
            nod_inp = shape[0]
            nod_otp = shape[1]

            last_layer_type = all_layers[l_idx-1]['type']

            if(last_layer_type == "Flatten"):
                mem_ptr -= mem_idx_flat

            elif(last_layer_type == "Dense"): 
                a = 0

            else:
                print("No Flatten or Dense before Dense not supported.")
                return 0

            for nod in range(0,nod_inp):
                mem_idx = mem.word_per_byte
                interm_map.append([mem_ptr,mem_idx,'input_layer'+str(l_idx)+"_nod"+str(nod)])
                mem_ptr += mem_idx


            #print('dense',hei,wid,hei*wid,hei*wid*2)


        elif(layer['type'] == "MaxPooling2D"):
            shape   = layer['shape']
            ch      = shape[3]
            hei     = shape[1]
            wid     = shape[2]

            #print('maxpool',hei,wid,hei*wid,hei*wid*2)

            for c in range(0,ch):
                mem_idx = 0
                mem_idx += hei*wid*mem.word_per_byte
                interm_map.append([mem_ptr,mem_idx,'input_layer'+str(l_idx)+"_ch"+str(c)])
                mem_ptr += mem_idx

        elif(layer['type'] == "Flatten"):
            shape   = layer['shape']
            ch      = shape[3]
            hei     = shape[1]
            wid     = shape[2]

            #print('flatten',hei,wid,hei*wid,hei*wid*2)

            mem_flat_start  = mem_ptr
            mem_idx_flat    = 0


            for c in range(0,ch):
                mem_idx = 0
                mem_idx += hei*wid*mem.word_per_byte
                interm_map.append([mem_ptr,mem_idx,'input_layer'+str(l_idx)+"_ch"+str(c)])
                mem_ptr += mem_idx
                mem_idx_flat += mem_idx



        else:
            print("Layer "+layer['type']+" not supported.")

        l_idx += 1


    num_layers = len(all_layers)
    last_layer = all_layers[num_layers - 1]
    if(last_layer['type'] == "Dense"):
        opnu_last   = last_layer['shape'][1]
        size_first  = 1
        mem_ptr_out     = mem_output
        for c in range(0,opnu_last):
            mem_idx     = size_first*mem.word_per_byte
            interm_map.append([mem_ptr_out, mem_idx, 'output_layer'+str(num_layers-1)+'_nod'+str(c)])
            mem_ptr_out    += mem_idx
    else:
        print("Dense as not last layer not supported.")
        return





    #print(*interm_map,sep = "\n")

    interm_map_dump_file = open(interm_map_dump,"w")
    for item in interm_map:
        interm_map_dump_file.write("%s\n" % item)

    interm_map_dump_file.close()


    interp_mem_size = mem_ptr - mem.ram_buffer_start
    print("--------------------------------------------------------------")
    print("Interp Memory Size: ",str(interp_mem_size))
    print("Interp Allocated Memory Size: ",str(mem.buffer_allocation))
    if(interp_mem_size > mem.buffer_allocation):
        print("Interp memory consumption more than allocated.")




    return interm_map


def output_to_ram(all_layers,output_map_dump,input_index):
    last_layer_idx = len(all_layers) - 1
    last_layer     = all_layers[last_layer_idx]

    output_map       = []
    output_mem_start = mem.ram_output_start

    if(last_layer['type'] == "Dense"):
        a = 0
        outp_nodes = last_layer['shape'][1]
        mem_ptr          = output_mem_start
        mem_idx          = mem.word_per_byte

        for nod in range(0,outp_nodes):
            output_map.append([mem_ptr,mem_idx,'final_output_input'+str(input_index)+'_node'+str(nod)])
            mem_ptr = mem_ptr+mem_idx

    else:
        print("Layer except Dense not supported as last.")
        return






    output_map_dump_file = open(output_map_dump,"w")

    for item in output_map:
        output_map_dump_file.write("%s\n" % item)

    output_map_dump_file.close()

    output_mem_size = mem_ptr - mem.ram_output_start
    print("--------------------------------------------------------------")
    print("Output Memory Size: ",str(output_mem_size))
    print("Output Allocated Memory Size: ",str(mem.output_allocation))
    if(output_mem_size > mem.output_allocation):
        print("Output memory consumption more than allocated.")

    return output_map


def ram_dump(mem_model_dump,mem_inp_dump,ram_dump): #UNUSED


    mem_model_dump_file = open(mem_model_dump,"r")
    mem_model = mem_model_dump_file.readlines()

    mem_inp_dump_file = open(mem_inp_dump,"r")
    mem_inp = mem_inp_dump_file.readlines()


    ram_dump_file = open(ram_dump,"w")

    

    ram_dump_file.close()

    return 1


    

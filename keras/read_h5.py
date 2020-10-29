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
from model_param import model_param as mod
import binary as b1
import numpy as np
import dump as dump


def read_h5(h5_path):

    #should be a model file generated from model.save('path.h5') after trainingm
    #contains the model architecture as well as weights
    #main_directory = '/home/vonfaust/data/accelerator/keras/'
    #file = 'mnist_cnn_model_int8.h5'
    #path = main_directory + file
    model = load_model(h5_path)
    #plot_model(model, to_file='model.svg', show_shapes='True')

    #model.summary()

    #print(model)

    weights = model.get_weights()
    conf = model.get_config()


    my_conf = []
    if(conf['name'] != "sequential_1"):
        print("*E,Model type:",conf['name']," not supported. Only Sequential is supported")
        exit("Exiting")


    for layer in conf['layers']:

        layer_type = layer['class_name']
        flag = 0
        if(layer_type == "Conv2D"):
            flag = 1
        if(layer_type == "Dense"):
            flag = 1
        if(layer_type == "MaxPooling2D"):
            flag = 1
        if(layer_type == "Flatten"):
            flag = 1

        if(flag != 1):
            print("*E,Layer type:",layer_type," not supported")
            exit("Exiting")

    my_conf = conf['layers']


    #for wt in weights:
    #    print(wt)
    i= 0
    for wt in weights:
        #print(i,wt)
        i+=1

    ####debug
    #print((weights[4][:,3]*256).astype(int))
    #f = open("dense1_node3.txt","w")
    #for i in range(0,9216):
    #    f.write(str((weights[4][i,3]*256).astype(int))+"\n")
    #f.close()
    #print(weights[4][:,0])
    #print(weights[4][200][127])
    #print(weights[5])
    ####debug

    mem_map_model = []

    #dumpfile = open("test","w")
    #dumpfile = 0


    layer_num = 0
    wt_num = 0
    flag = 0

    this_layer = {}
    this_layer_all = []
    next_layer = {}
    next_layer_all = []

    for layer in conf['layers']:
        layer_type = layer['class_name']
        config = layer['config']

        this_layer = {}

        this_layer['number'] = layer_num
        this_layer['type'] = layer_type

        
        #1. Conv2D layer
        if(layer_type == "Conv2D"):
            filters = config['filters']
            this_layer['use_bias'] = config['use_bias']
            this_layer['activation'] = config['activation']
            this_layer['weight'] = weights[wt_num]
            if(this_layer['use_bias']):
                this_layer['bias'] = weights[wt_num+1]

            if(flag == 0):
                shape = config['batch_input_shape']
                hei = shape[1]
                wid = shape[2]
                chann = shape[3]
                k_shape = config['kernel_size']
                k_hei = k_shape[0]
                k_wid = k_shape[1]
                pad_shape = [0,0]
                pad_hei = pad_shape[0]
                pad_wid = pad_shape[1]
                stride_shape = config['strides']
                stride_hei = stride_shape[0]
                stride_wid = stride_shape[1]
                
                this_layer['shape'] = shape
                this_layer['filters'] = filters
                this_layer['kernel_shape'] = k_shape
                this_layer['stride_shape'] = stride_shape
                this_layer['pad_shape'] = pad_shape
                
            elif(flag == 1):
                this_layer['prev_type'] = next_layer['type']
                if(this_layer['prev_type'] == "Conv2D") :
                    
                    shape = next_layer['shape']
                    hei = shape[1]
                    wid = shape[2]
                    chann = shape[3]
                    k_shape = config['kernel_size']
                    k_hei = k_shape[0]
                    k_wid = k_shape[1]
                    pad_shape = [0,0]
                    pad_hei = pad_shape[0]
                    pad_wid = pad_shape[1]
                    stride_shape = config['strides']
                    stride_hei = stride_shape[0]
                    stride_wid = stride_shape[1]
                    

                    this_layer['shape'] = shape
                    this_layer['filters'] = filters
                    this_layer['kernel_shape'] = k_shape
                    this_layer['stride_shape'] = stride_shape
                    this_layer['pad_shape'] = pad_shape
                    


                elif(this_layer['prev_type'] == "Dense"):
                    exit("Conv after FC not supported")
                elif(this_layer['prev_type'] == "MaxPooling2D"):
                    exit("Conv after MaxPooling2D not supported")
                elif(this_layer['prev_type'] == "Flatten"):
                    exit("Conv after Flatten not supported")
                
            next_layer = {}
            next_layer['channels'] = filters
            next_layer['hei'] = (hei - k_hei + 2*pad_hei)/stride_hei + 1
            next_layer['wid'] = (wid - k_wid + 2*pad_wid)/stride_wid + 1
            next_layer['shape'] = [0,next_layer['hei'],next_layer['wid'], next_layer['channels']]
            
               
            if(this_layer['use_bias']):
                wt_num += 2
            else:
                wt_num += 1
                
        #2. Dense Layer
        elif(layer_type == "Dense"):
            
            this_layer['use_bias'] = config['use_bias']
            this_layer['activation'] = config['activation']
            if(this_layer['use_bias']):
                this_layer['bias'] = weights[wt_num+1]
            
            if(flag == 0):
                exit("Dense as first layer not YET supported")
            elif(flag == 1):
                this_layer['prev_type'] = next_layer['type']
                if(this_layer['prev_type'] == "Dense"):
                    this_layer['weight'] = weights[wt_num]
                    this_layer['output_nodes'] = config['units']
                    this_layer['input_nodes'] = int(next_layer['shape'])
                    this_layer['shape'] = [next_layer['shape'],config['units']]

                elif(this_layer['prev_type'] == "MaxPooling2D"):
                    exit("Dense after MaxPooling2D not YET supported")
                elif(this_layer['prev_type'] == "Conv"):
                    exit("Dense after Conv not YET supported")
                elif(this_layer['prev_type'] == "Flatten"):
                    this_layer['output_nodes'] = config['units']
                    this_layer['input_nodes'] = int(next_layer['shape'])
                    this_layer['shape'] = [next_layer['shape'],config['units']]
                    
                    if(mod.channel_last == 1):
                        print("Reading h5 weights after Flatten as channel_last")
                        #this_layer['weight'] = weights[wt_num]
                        #print(this_layer['output_nodes'],type(this_layer['output_nodes']))
                        reshaped_wt = weights[wt_num].reshape([next_layer['flat_hei'],next_layer['flat_wid'],next_layer['flat_ch'],this_layer['output_nodes']])
                        #print(this_layer['input_nodes'],type(this_layer['input_nodes']))
                        #print(this_layer['output_nodes'],type(this_layer['output_nodes']))
                        this_layer['weight'] = np.reshape(np.moveaxis(reshaped_wt,2,0),(this_layer['input_nodes'],this_layer['output_nodes']))
                        
                    else:
                        print("Reading h5 weights after Flatten as channel_first")
                        this_layer['weight'] = weights[wt_num]


            next_layer = {}
            next_layer['shape'] = this_layer['output_nodes']

        
            if(this_layer['use_bias']):
                wt_num += 2
            else:
                wt_num += 1
            
        #3. MaxPooling2D Layer
        elif(layer_type == "MaxPooling2D"):
            if(flag == 0):
                exit("MaxPooling2D as first layer not YET supported")
            elif(flag == 1):
                this_layer['prev_type'] = next_layer['type']
                if(this_layer['prev_type'] == "Conv2D"):
                    this_layer['shape'] = next_layer['shape']
                    this_layer['stride_shape'] = config['strides']
                    this_layer['padding'] = [0,0]
                    this_layer['pool_size'] = config['pool_size']
                
            
                elif(this_layer['prev_type'] == "Dense"):
                    exit("MaxPooling2D after Dense not YET supported")
                elif(this_layer['prev_type'] == "Flatten"):
                    exit("MaxPooling2D after Flatten not YET supported")
                elif(this_layer['prev_type'] == "MaxPooling2D"):
                    print("WARNING: MAX POOLING AFTER MAX POOLING MAY CAUSE ISSUES, from read_h5.py")                    
                    this_layer['shape'] = next_layer['shape']
                    this_layer['stride_shape'] = config['strides']
                    this_layer['padding'] = [0,0]
                    this_layer['pool_size'] = config['pool_size']

            next_layer = {}
            next_layer['channels'] = this_layer['shape'][3]
            next_layer['hei'] = this_layer['shape'][1]/this_layer['stride_shape'][0]
            next_layer['wid'] = this_layer['shape'][2]/this_layer['stride_shape'][1]
            next_layer['shape'] = [0,next_layer['hei'],next_layer['wid'],next_layer['channels']]

        #4. Flatten Layer
        elif(layer_type == "Flatten"):
            if(flag == 0):
                exit("Flatten as first layer not YET supported")
            elif(flag == 1):
                this_layer['prev_type'] = next_layer['type']
                if(this_layer['prev_type'] == "Conv2D"):
            
                    exit("Flatten after Conv2D not YET supported")
                elif(this_layer['prev_type'] == "Dense"):
                    exit("Flatten after Dense not YET supported")
                elif(this_layer['prev_type'] == "Flatten"):
                    exit("Flatten after Flatten not YET supported")
                elif(this_layer['prev_type'] == "MaxPooling2D"):
                    this_layer['shape'] = next_layer['shape']
                    inp_hei = next_layer['shape'][1]
                    inp_wid = next_layer['shape'][2]
                    inp_ch = next_layer['shape'][3]
                    this_layer['output_elements'] = inp_hei*inp_wid*inp_ch
            
            next_layer = {}
            next_layer['shape'] = this_layer['output_elements']
            next_layer['flat_wid'] = int(inp_wid)
            next_layer['flat_hei'] = int(inp_hei)
            next_layer['flat_ch'] = int(inp_ch)

        
        next_layer['type'] = layer_type
        next_layer['prev_number'] = layer_num
        
        this_layer['next_shape'] = next_layer['shape']


        this_layer_all.append(this_layer)
        next_layer_all.append(next_layer)

        #print(layer_type)
        layer_num+= 1
        if(layer_num > 0):
            flag = 1

    
    return this_layer_all
















if __name__ == "__main__":
    a = 0
    #print(this_layer_all[0])

    main_directory  = '/home/vonfaust/data/accelerator/keras/'
    h5_path = main_directory+'mnist_cnn_model_float32_ch_last.h5'

    this_layer_all = read_h5(h5_path)    



    for l in this_layer_all:
        empty = {}
        for k in l.keys():
            if(k == 'weight' or k == 'bias'):
                continue
            else:
                empty[k]=l[k]
        print(empty)



    #print(*next_layer_all,sep="\n")








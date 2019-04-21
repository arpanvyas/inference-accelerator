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
import binary as b1
import dump as dump
import read_h5 as rdh5
import reg_map as reg


main_directory  = '/home/vonfaust/data/accelerator/keras/'
hw_dir          = main_directory+'hw_related/'

##########################################################################
# I.    Read the model from Keras trained h5 file
##########################################################################

h5_path = main_directory+'mnist_cnn_model_int8.h5'
all_layers = rdh5.read_h5(h5_path)

#for l in all_layers:
#    print(l['type'])


##########################################################################
# II.   Get the list of inputs for inference
##########################################################################

input_list_file = 'input_list.txt'


##########################################################################
# III.  Create Memory Dumps and Maps for Model and Inputs
##########################################################################

#i.  Dump Model : Same for one Model
mem_model_dump  =   hw_dir+'model.dat'
model_map_dump  =   hw_dir+'model.map'

model_map       =   dump.model_to_ram(all_layers,mem_model_dump,model_map_dump)

#ii. Dump Input : Same for one set of inputs
input_file_list =   hw_dir+'input_list.txt'
mem_inp_dump    =   hw_dir+'input.dat'
inp_map_dump    =   hw_dir+'input.map'

input_map       =   dump.img_to_ram(input_file_list,mem_inp_dump,inp_map_dump)

#iii.Dump map for intermediate : Same for one input
interm_map_dump =   hw_dir+'interm.map'
input_index     =   5

interm_map      =   dump.interm_to_ram(all_layers,interm_map_dump,input_map,input_index)

#iv. Dump map for output : Same for one input, may be combined for multiple inputs
output_map_dump =   hw_dir+'output.map'
input_index     =   5

output_map      =   dump.output_to_ram(all_layers,output_map_dump,input_index)


print("--------------------------------------------------------------")

##########################################################################
#IV.    Create program to be loaded
##########################################################################
#           For each input
#             Do inference:
#               i.    Load Raw input from RAM to buffer
#               ii.   Load Layer 1 from RAM to buffer
#               iii.  Start Computation
#               iv.   Store Back Ouput of Layer 1 to RAM
#               v.    Repeat i-iv per layer
#               vi.   Store final output to RAM
#
##########################################################################

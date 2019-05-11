import re
import reg_map as reg
import binary as b1
from mem_param import mem_param as mem

def nl_to_code(nl_type):
    code = 0
    if(nl_type == "relu"):
        code = 0
    elif(nl_type == "arctan"):
        code = 1
    elif(nl_type == "sigmoid"):
        code = 2
    elif(nl_type == "linear"):
        code = 3
    elif(nl_type == "binary_step"):
        code = 4
    elif(nl_type == "leaky_relu"):
        code = 5
    elif(nl_type == "softmax"):
        code = 6
    else:
        print("NL Type:"+nl_type+" not recognised.")
        return

    return code


def write_cmd(addr, data):
    instr = ""
    addr_size = mem.addr_size
    data_size = mem.data_size
    if(not re.match('^[01]{'+  str(addr_size) +'}$',addr)):
        print("Address does not match required format")

    if(not re.match('^[01]{'+  str(data_size) +'}$',data)):
        print("Data does not match required format")        

    instr = "01"+str(addr)+str(data)
    return instr


def write_read_reg(regfile,regdict):

    #Format for regdict
    #   rdict['name'] = regname
    #   rdict['fields']['fieldname1'] = 'value1'
    #   rdict['fields']['fieldname2'] = 'value2'
    #   ...
    #   rdict['fields']['fieldnameN'] = 'valueN'
    #   rdict['sheetname'] = sheetname       

    regname = regdict['name']
    fieldnames = regdict['fields'].keys()
    sheetname = regdict['sheetname']

    reg_found = reg.regaddr(regfile,regname)

    data = ""
    addr = ""


    if(reg_found == 0):
        print("Regname: "+regname+" not found.")
        return
    else:
        #print("Regname: "+regname+" found.")
        regaddr = reg_found['regaddrint']

    addr = b1.int2bin(regaddr,0,mem.addr_size)
    regsheet = reg_found['sheetnum']
    #print(str(regaddr))

    #To check if all fields provided belong to the regname given
    for field in fieldnames:
        field_found = reg.fieldaddr(regfile,sheetname,field)

        if(field_found == 0):
            print("Fieldname: "+field+" not found.")
            return
        else:
            fld_reg_addr = field_found['regaddrint']
            #print("Fieldname: " + field+ " found.")
            #print("fld_reg_addr: " + str(fld_reg_addr) + "  " +str(regaddr))
            if(fld_reg_addr != regaddr):
                print("Regaddr does not match regname for field " + field)
                return


    flds = regfile[regsheet][regaddr]['fields']


    write_fld_dict = {}
    #write_fld_dict structure:
    #   write_fld_dict[startbit] = value 
    #       value is string of binary with len = fldlen
    #initialize write vals with defvals
    for strtbits in flds.keys():
        write_fld_dict[strtbits] = {}
        fldsize = flds[strtbits]['fieldsize']
        defval  = str(flds[strtbits]['defval'])
        write_fld_dict[strtbits]['fieldsize'] = fldsize
        if(not re.match('^[0-9A-Fa-f]{0,}$',defval)):
            defval_binary = b1.int2bin(0,0,fldsize)
        else:
            defval_binary = b1.int2bin(defval,0,fldsize)

        write_fld_dict[strtbits] = defval_binary

    #Overwrite defvals with actual values meant to be written
    for field in fieldnames:
        field_found = reg.fieldaddr(regfile,sheetname,field)
        strtbit     = field_found['startbit']
        fldlen      = field_found['length']
        wrval       = regdict['fields'][field]
        wrval_binary= b1.int2bin(wrval,0,fldlen)
        write_fld_dict[strtbit] = wrval_binary


    for key in sorted(write_fld_dict):
        data = write_fld_dict[key]+data

    if(len(data) < 16):
        zeropad_n = 16-len(data)
        zeropad =  "0" * zeropad_n 
        data = zeropad+data
    elif(len(data)>16):
        print("Length of data invalid: " + str(len(data)) )
        return


    #generate regname, data
    assembly = regname + ", " + str(hex(b1.bin2int(data,1)))

    return addr, data, assembly

def write_reg_cmd(regfile,regdict):
    addr,data,assembly = write_read_reg(regfile,regdict)
    #instr = write_cmd(addr,data)
    assembly = "write " + assembly
    return assembly

def read_reg_cmd(regfile,regdict):
    addr,data,assembly = write_read_reg(regfile,regdict)
    #instr = write_cmd(addr,data)
    assembly = "write " + assembly
    return assembly


def ram_to_buffer_instr(ram_start, ram_number,buffer_block, buffer_addr,regfile):
    instr = []
    ram_addr_binary = b1.int2bin(ram_start,0,32)

    ram_addr_lowerB  = ram_addr_binary[16:32]
    ram_addr_lowerD  = b1.bin2int(ram_addr_lowerB,1)

    ram_addr_upperB  = ram_addr_binary[0:16]
    ram_addr_upperD  = b1.bin2int(ram_addr_upperB,1)

    ram_num_binary  = b1.int2bin(ram_number,0,mem.ram_address_bits)
    ram_num_lowerB  = ram_num_binary[16:32]
    ram_num_lowerD  = b1.bin2int(ram_num_lowerB,1)

    ram_num_upperB  = ram_num_binary[0:16]
    ram_num_upperD  = b1.bin2int(ram_num_upperB,1)

    regdict = {'name':'REG_0002', 'fields':{}, 'sheetname' : "general"}
    regdict['fields'] = {'mem_load_start_upper': ram_addr_upperD } 
    instr.append(write_reg_cmd(regfile,regdict))

    regdict = {'name':'REG_0003', 'fields':{}, 'sheetname' : "general"}
    regdict['fields'] = {'mem_load_start_lower' : ram_addr_lowerD} 
    instr.append(write_reg_cmd(regfile,regdict))

    regdict = {'name':'REG_0004', 'fields':{}, 'sheetname' : "general"}
    regdict['fields'] = {'mem_load_words_upper': ram_num_upperD} 
    instr.append(write_reg_cmd(regfile,regdict))

    regdict = {'name':'REG_0005', 'fields':{}, 'sheetname' : "general"}
    regdict['fields'] = {'mem_load_words_lower' : ram_num_lowerD} 
    instr.append(write_reg_cmd(regfile,regdict))

    buffer_addr16 = buffer_block*pow(2,8)+buffer_addr

    regdict = {'name': 'REG_0006','fields':{'mem_load_buffer_addr':buffer_addr16}, 'sheetname' : "general"}
    instr.append(write_reg_cmd(regfile,regdict))

    regdict = {'name' : 'REG_0013', 'fields' : {'start_loading_buffer':1}, 'sheetname' : "general" }
    instr.append(write_reg_cmd(regfile,regdict))

    return instr


def buffer_to_ram_instr(ram_start, ram_number,buffer_block, buffer_addr,regfile):
    instr = []
    ram_addr_binary = b1.int2bin(ram_start,0,32)

    ram_addr_lowerB  = ram_addr_binary[16:32]
    ram_addr_lowerD  = b1.bin2int(ram_addr_lowerB,1)

    ram_addr_upperB  = ram_addr_binary[0:16]
    ram_addr_upperD  = b1.bin2int(ram_addr_upperB,1)

    ram_num_binary  = b1.int2bin(ram_number,0,mem.ram_address_bits)
    ram_num_lowerB  = ram_num_binary[16:32]
    ram_num_lowerD  = b1.bin2int(ram_num_lowerB,1)

    ram_num_upperB  = ram_num_binary[0:16]
    ram_num_upperD  = b1.bin2int(ram_num_upperB,1)

    regdict = {'name':'REG_0007', 'fields':{}, 'sheetname' : "general"}
    regdict['fields'] = {'mem_save_start_upper': ram_addr_upperD } 
    instr.append(write_reg_cmd(regfile,regdict))

    regdict = {'name':'REG_0008', 'fields':{}, 'sheetname' : "general"}
    regdict['fields'] = {'mem_save_start_lower' : ram_addr_lowerD} 
    instr.append(write_reg_cmd(regfile,regdict))

    regdict = {'name':'REG_0009', 'fields':{}, 'sheetname' : "general"}
    regdict['fields'] = {'mem_save_words_upper': ram_num_upperD} 
    instr.append(write_reg_cmd(regfile,regdict))

    regdict = {'name':'REG_0010', 'fields':{}, 'sheetname' : "general"}
    regdict['fields'] = {'mem_save_words_lower' : ram_num_lowerD} 
    instr.append(write_reg_cmd(regfile,regdict))

    buffer_addr16 = buffer_block*pow(2,8)+buffer_addr

    regdict = {'name': 'REG_0011','fields':{'mem_save_buffer_addr':buffer_addr16}, 'sheetname' : "general"}
    instr.append(write_reg_cmd(regfile,regdict))

    regdict = {'name' : 'REG_0013', 'fields' : {'start_saving_buffer':1}, 'sheetname' : "general" }
    instr.append(write_reg_cmd(regfile,regdict))

    return instr






def prog_conv(model_map,model_idx_start,interm_map,interm_idx_start,all_layers,layer_index,regfile):

    this_layer = all_layers[layer_index]
    layer_idx = this_layer['number']
    shape     = this_layer['shape']
    channels  = shape[3]
    filters   = this_layer['filters']
    kern_size = this_layer['kernel_shape'][0]*this_layer['kernel_shape'][1]
    use_bias  = this_layer['use_bias']
    #use_bias  = False
    activation= this_layer['activation']

    instr = []
    buffer_block    = 0

    #i.   Load Input

    interm_idx = interm_idx_start
    for ch in range(0,channels):
        buffer_addr      = ch%32

        if(interm_map[interm_idx][2] == "input_layer"+str(layer_idx)+"_ch"+str(ch)):
            ram_start   = interm_map[interm_idx][0]
            ram_number  = interm_map[interm_idx][1]
        else:
            print("program.py: Input parsing error in layer conv")
            return

        instr1 = ram_to_buffer_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)
        for item in instr1: instr.append(item)

        interm_idx += 1

    interm_idx_end = interm_idx

    #ii.  Load Model

    model_idx = model_idx_start

    for filt in range(0,filters):
        for ch in range(0,channels):
            buffer_addr = ch%32

            str_cmp = "layer"+str(layer_idx)+"_conv_filt"+str(filt)+"_ch"+str(ch)+"_coeff"
            if(model_map[model_idx][2] == str_cmp):
                ram_start   = model_map[model_idx][0]
                ram_number  = model_map[model_idx][1]
            else:
                print("program.py:nb Model parsing error in layer conv")
                print(model_map[model_idx][2] + " != "+ str_cmp)
                return

            instr1 = ram_to_buffer_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)
            for item in instr1: instr.append(item)

            model_idx += 1

        if(use_bias):
            buffer_addr = 33
            str_cmp = "layer"+str(layer_idx)+"_conv_filt"+str(filt)+"_bias"
            if(model_map[model_idx][2] == str_cmp):
                ram_start   = model_map[model_idx][0]
                ram_number  = model_map[model_idx][1]
            else:
                print("program.py:b Model parsing error in layer conv")
                print(model_map[model_idx][2] + " != "+ str_cmp)
                return

            instr1 = ram_to_buffer_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)
            for item in instr1: instr.append(item)

            model_idx += 1

    model_idx_end = model_idx

    #iii.Set Configs
    inp_hei = shape[1]
    inp_wid = shape[2]
    inp_ch  = shape[3]

    stride_hz = this_layer['stride_shape'][0]
    stride_vrt = this_layer['stride_shape'][1]

    kern_shape = this_layer['kernel_shape']
    filt_hei = kern_shape[0]
    filt_wid = kern_shape[1]
    filters  = this_layer['filters']


    #iii.a Write Layer type

    regdict = {'name':'REG_0001','fields':{'layer_type':5}, 'sheetname' : "general"} #5 = conv+nl
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'NL_0004','fields':{'nl_type':nl_to_code(activation) }, 'sheetname' : "nl"}
    instr.append(write_reg_cmd(regfile,regdict))

    #iii.a. Write Input Shape
    regdict = {'name':'CONV_0001','fields':{'data_wid':inp_wid}, 'sheetname' : "conv"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'CONV_0002','fields':{'data_hei':inp_hei}, 'sheetname' : "conv"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'CONV_0003','fields':{'data_ch':inp_ch}, 'sheetname' : "conv"}
    instr.append(write_reg_cmd(regfile,regdict))


    #iii.b. Write Kernel Shape
    regdict = {'name':'CONV_0004','fields':{'filter_wid':filt_wid}, 'sheetname' : "conv"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'CONV_0005','fields':{'filter_hei':filt_hei}, 'sheetname' : "conv"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'CONV_0007','fields':{'filter_num':filters}, 'sheetname' : "conv"}
    instr.append(write_reg_cmd(regfile,regdict))

    #iii.d. Write Stride
    regdict = {'name':'CONV_0008','fields':{'stride_horiz':stride_hz,'stride_vert':stride_vrt}, 'sheetname' : "conv"}
    instr.append(write_reg_cmd(regfile,regdict))


    #iii.d. Issue start
    regdict = {'name':'REG_0013','fields':{'start':1}, 'sheetname' : "general"}
    instr.append(write_reg_cmd(regfile,regdict))

    #iv. Save Output

    next_shape     = this_layer['next_shape']
    channels_next  = next_shape[3]
    buffer_block   = 1

    output_idx = 0

    for ch in range(0,channels_next):
        buffer_addr      = ch%32

        if(interm_map[interm_idx][2] == "input_layer"+str(layer_idx+1)+"_ch"+str(ch)):
            ram_start   = interm_map[interm_idx][0]
            ram_number  = interm_map[interm_idx][1]
        else:
            print("program.py: Input parsing error in layer conv")
            return

        instr1 = buffer_to_ram_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)
        for item in instr1: instr.append(item)

        interm_idx += 1

    return instr,model_idx_end,interm_idx_end

def prog_maxpool(interm_map,interm_idx_start,all_layers,layer_index,regfile):

    this_layer = all_layers[layer_index]
    layer_idx = this_layer['number']
    shape     = this_layer['shape']
    channels  = shape[3]

    instr = []
    buffer_block    = 0

    #i.   Load Input

    interm_idx = interm_idx_start
    for ch in range(0,channels):
        buffer_addr      = ch%32

        if(interm_map[interm_idx][2] == "input_layer"+str(layer_idx)+"_ch"+str(ch)):
            ram_start   = interm_map[interm_idx][0]
            ram_number  = interm_map[interm_idx][1]
        else:
            print("program.py: Input parsing error in layer pool")
            return

        instr1 = ram_to_buffer_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)
        for item in instr1: instr.append(item)

        interm_idx += 1

    interm_idx_end = interm_idx   

    #Set Pooling Config
    inp_hei = shape[1]
    inp_wid = shape[2]
    inp_ch  = shape[3]

    stride_hz = this_layer['stride_shape'][0]
    stride_vrt = this_layer['stride_shape'][1]

    pool_shape = this_layer['pool_size']
    pool_hz    = pool_shape[0]
    pool_vrt   = pool_shape[1]


    regdict = {'name':'REG_0001','fields':{'layer_type':3}, 'sheetname' : "general"} #3 = pool
    instr.append(write_reg_cmd(regfile,regdict))


    #iii.a. Write Input Shape
    regdict = {'name':'POOL_0001','fields':{'data_wid':inp_wid}, 'sheetname' : "pool"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'POOL_0002','fields':{'data_hei':inp_hei}, 'sheetname' : "pool"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'POOL_0003','fields':{'data_ch':inp_ch}, 'sheetname' : "pool"}
    instr.append(write_reg_cmd(regfile,regdict))

    if(this_layer['type'] == "MaxPooling2D"):
        regdict = {'name':'POOL_0004','fields':{'pool_type':0}, 'sheetname' : "pool"} #0 = Maxpooling
        instr.append(write_reg_cmd(regfile,regdict))
    else:
        print("Pooling type not determined")
        return


    #iii.b. Write Pool Shape
    regdict = {'name':'POOL_0005','fields':{'pool_horiz':pool_hz}, 'sheetname' : "pool"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'POOL_0006','fields':{'pool_vert':pool_vrt}, 'sheetname' : "pool"}
    instr.append(write_reg_cmd(regfile,regdict))

    #iii.d. Write Stride
    regdict = {'name':'POOL_0007','fields':{'pool_horiz_stride':stride_vrt}, 'sheetname' : "pool"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'POOL_0008','fields':{'pool_vert_stride':stride_hz}, 'sheetname' : "pool"}
    instr.append(write_reg_cmd(regfile,regdict))


    #iii.d. Issue start
    regdict = {'name':'REG_0013','fields':{'start':1}, 'sheetname' : "general"}
    instr.append(write_reg_cmd(regfile,regdict))

    #iv. Save Output
    next_shape     = this_layer['next_shape']
    channels_next  = next_shape[3]
    buffer_block   = 1

    output_idx = 0

    for ch in range(0,channels_next):
        buffer_addr      = ch%32

        if(interm_map[interm_idx][2] == "input_layer"+str(layer_idx+1)+"_ch"+str(ch)):
            ram_start   = interm_map[interm_idx][0]
            ram_number  = interm_map[interm_idx][1]
        else:
            print("program.py: Input parsing error in layer pool")
            return

        instr1 = buffer_to_ram_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)
        for item in instr1: instr.append(item)

        interm_idx += 1

    return instr,interm_idx_end



def prog_dense(model_map,model_idx_start,interm_map,interm_idx_start, all_layers, layer_index, regfile):

    print("Program Dense, layer_idx :"+str(layer_index))

    this_layer = all_layers[layer_index]
    layer_idx = this_layer['number']
    shape     = this_layer['shape']
    input_nodes = shape[0]
    output_nodes = shape[1]
    use_bias = this_layer['use_bias']
    #use_bias = False
    activation = this_layer['activation']

    instr = []
    buffer_block = 0

    #i. Load Input
    interm_idx = interm_idx_start
    for ipnu in range(0,input_nodes):
        #buffer_addr = opnu%32
        buffer_addr = 32 #input (i.e. vector V stored in buffer 32)

        if(interm_map[interm_idx][2] == "input_layer"+str(layer_idx)+"_nod"+str(ipnu)):
            ram_start   = interm_map[interm_idx][0]
            ram_number  = interm_map[interm_idx][1]
        else:
            print("program.py: Input parsing error in layer dense")
            print(interm_map[interm_idx][2] + " != " + "input_layer"+str(layer_idx)+"_nod"+str(ipnu))
            return

        instr1 = ram_to_buffer_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)

        for item in instr1: instr.append(item)

        interm_idx += 1

    interm_idx_end = interm_idx

    #ii. Load Model

    model_idx = model_idx_start

    for opnu in range(0,output_nodes):
        buffer_addr = opnu%32

        str_cmp = "layer"+str(layer_idx)+"_dense_outnode"+str(opnu)
        if(model_map[model_idx][2] == str_cmp):
            ram_start = model_map[model_idx][0]
            ram_number = model_map[model_idx][1]
        else:
            print("program.py: Model parsing error in layer dense")
            return

        instr = ram_to_buffer_instr(ram_start, ram_number, buffer_block,buffer_addr,regfile)
        for item in instr1: instr.append(item)

        model_idx += 1

        if(use_bias):
            buffer_addr = 33
            str_cmp = "layer"+str(layer_idx)+"_dense_outnode"+str(opnu)+"_bias"
            if(model_map[model_idx][2] == str_cmp):
                ram_start  = model_map[model_idx][0]
                ram_number = model_map[model_idx][1]
            else:
                print("program.py: Model parsing error in layer dense")
                return

            instr1 = ram_to_buffer_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)
            for item in instr1: instr.append(item)

            model_idx += 1
    
    model_idx_end = model_idx

    #iii. Set Configs

    #iii.a Write Layer type
    regdict = {'name':'REG_0001','fields':{'layer_type':8}, 'sheetname' : "general"} #8 = FC + NL 
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'NL_0004','fields':{'nl_type':nl_to_code(activation) }, 'sheetname' : "nl"}
    instr.append(write_reg_cmd(regfile,regdict))

    #iii.b Write input and output shape
    regdict = {'name':'FC_0001','fields':{'input_data_type':1}, 'sheetname' : "fc"} #Linear
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'FC_0008','fields':{'input_data_length':input_nodes}, 'sheetname' : "fc"}
    instr.append(write_reg_cmd(regfile,regdict))
    regdict = {'name':'FC_0009','fields':{'output_data_length':output_nodes}, 'sheetname' : "fc"}
    instr.append(write_reg_cmd(regfile,regdict))


    #iii.c Issue Start
    regdict = {'name':'REG_0013','fields':{'start':1}, 'sheetname' : "general"}
    instr.append(write_reg_cmd(regfile,regdict))

    #iv Save Output
    next_shape = this_layer['next_shape']
    nodes_next = next_shape
    buffer_block = 1

    output_idx = 0

    for node in range(0,nodes_next):
        buffer_addr = node%32

        if(interm_map[interm_idx][2] == "input_layer"+str(layer_idx+1)+"_nod"+str(node)): #when not last layer
            ram_start = interm_map[interm_idx][0]
            ram_number = interm_map[interm_idx][1]
        elif(interm_map[interm_idx][2] == "output_layer"+str(layer_idx)+"_nod"+str(node)): #when last layer
            ram_start = interm_map[interm_idx][0]
            ram_number = interm_map[interm_idx][1]
        else:
            print("program.py: Input parsing error in layer dense")
            return

        instrn1 = buffer_to_ram_instr(ram_start,ram_number,buffer_block,buffer_addr,regfile)
        for item in instr1: instr.append(item)

        interm_idx += 1


    return instr,model_idx_end,interm_idx_end



def prog_all(model_map,model_idx_start,interm_map,interm_idx_start,all_layers,regfile,assembly_dump):

    instr = []

    #model_idx_carry = model_idx_start
    #interm_idx_carry = interm_idx_start

    model_idx_carry = 0
    interm_idx_carry = 0

    print("model_idx_start:"+str(model_idx_carry))
    print("interm_idx_start:"+str(interm_idx_carry))

    for layer in all_layers:
        layer_index = layer['number']
        layer_type  = layer['type']

        if(layer_type == "Conv2D"):
            instr_this,model_idx_carry,interm_idx_carry = prog_conv(model_map,model_idx_carry,interm_map,interm_idx_carry, all_layers,layer_index,regfile)
        elif(layer_type == "MaxPooling2D"):
            instr_this,interm_idx_carry = prog_maxpool(interm_map,interm_idx_carry,all_layers,layer_index,regfile)
        elif(layer_type == "Flatten"):
            a = 0
            output_elements = layer['output_elements']
            layer_idx = layer['number']
            while( "input_layer"+str(layer_idx) in interm_map[interm_idx_carry][2] ):
                interm_idx_carry += 1

        elif(layer_type == "Dense"):
            instr_this,model_idx_carry,interm_idx_carry = prog_dense(model_map,model_idx_carry,interm_map,interm_idx_carry,all_layers,layer_index,regfile)
        else:
            print("program.py: prog_all(), layer type:"+str(layer_type)+" not found")

        for item in instr_this: instr.append(item)

    dumpfile = open(assembly_dump,"w")

    for item in instr:
        dumpfile.write(item+'\n')

    dumpfile.close()

    return instr



if __name__ == "__main__":
    write_cmd("00110110011000","0011001100110001")

    regfile = reg.regmap("../utils/register_set.ods")


    #wr_dict = { 'name': 'REG_0001' , 'fields' : {'store_to': 1, 'layer_type' : 7}}
    wr_dict = { 'name': 'REG_0013'}
    wr_dict['fields'] = {}
    wr_dict['fields']['start'] = 1
    wr_dict['fields']['abrupt_end'] = 1
    wr_dict['fields']['digital_reset'] = 1
    wr_dict['fields']['start_loading_buffer'] = 1
    wr_dict['fields']['flush_buff1_to_ext_mem'] = 1
    wr_dict['sheetname'] = "general"


    #print(regfile[0][18]['fields'][0]['name'])

    addr, data = write_read_reg(regfile,wr_dict)

    #instr = write_cmd(addr,data)

    instr = ram_to_buffer_instr(2012,1000,1,14,regfile)
    for ins in instr:   print(ins[0:2],ins[2:16],ins[16:32])

    print("HOOO")

    instr = buffer_to_ram_instr(2012,1000,1,14,regfile)
    for ins in instr:   print(ins[0:2],ins[2:16],ins[16:32])




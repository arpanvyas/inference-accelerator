class mem_param:
    word_size = 16
    frac_size = 8
    word_per_byte = word_size/8
    
    max_inp_hei = 128
    max_inp_wid = 128
    max_inp_size = max_inp_wid*max_inp_hei
    max_inp_ch  = 128
    
    max_flt_hei = 3
    max_flt_wid = 3
    max_flt_size = max_flt_hei*max_flt_wid
    max_flt_num = max_inp_ch
    
    
    buffer_num = 32
    buffer_block_num = 2
    buffer_width = word_size
    
    buffer_depth = (max_inp_size*(max_inp_ch/buffer_num) + max_flt_size*(max_inp_ch/buffer_num)*max_flt_num) #in number of widths
    
    buffer_byte_size = buffer_depth*buffer_width/8 
    buffer_block_byte_size = buffer_byte_size*buffer_num
    buffer_total_byte_size = buffer_block_byte_size*buffer_block_num
    
    
    pe_num = buffer_num
    pe_conv_num = buffer_num
    pe_conv_fifo_num = max_flt_hei - 1
    pe_conv_fifo_size = pe_conv_fifo_num * max_inp_wid * word_size
    pe_fifo_size = pe_conv_fifo_size*pe_conv_num
    pe_fifo_byte_size = pe_fifo_size/8
    pe_array_fifo_size = pe_fifo_size*pe_num
    pe_array_fifo_byte_size = pe_array_fifo_size/8
    
    
    
    #Byte addressable RAM
    ram_memory_start    = 0x00000000
    ram_memory_end      = 0x003fffff
    ram_allocation      = ram_memory_end - ram_memory_start + 1
    model_allocation    = ram_allocation/2
    input_allocation    = ram_allocation/8
    output_allocation   = ram_allocation/8
    buffer_allocation   = ram_allocation/8
    config_allocation   = ram_allocation/8
    ram_model_start     = ram_memory_start
    ram_model_end       = ram_model_start+model_allocation-1
    ram_input_start     = ram_model_end+1
    ram_input_end       = ram_input_start+input_allocation-1
    ram_output_start    = ram_input_end+1
    ram_output_end      = ram_output_start+output_allocation-1
    ram_config_start    = ram_output_end+1
    ram_config_end      = ram_config_start+config_allocation-1
    ram_buffer_start    = ram_config_end + 1
    ram_buffer_end      = ram_buffer_start+buffer_allocation-1



    #scaling factor
    scale = 16


if __name__ == "__main__":
   # print(str(buffer_byte_size/1024)+"KB")
   # print(str(buffer_block_byte_size/1024)+"KB")
   # print(str(buffer_total_byte_size/1024)+"KB")
   # print(str(pe_fifo_byte_size)+"B")
    print(hex(ram_allocation))
    print(hex(ram_model_start))
    print(hex(ram_model_end))
    print(hex(ram_input_start))
    print(hex(ram_input_end))
    print(hex(ram_output_start))
    print(hex(ram_output_end))
    print(hex(ram_config_start))
    print(hex(ram_config_end))
    print(hex(ram_buffer_start))
    print(hex(ram_buffer_end))




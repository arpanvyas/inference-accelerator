//
//        MEM_SAVE : begin
//            busy         = 1;
//
//            intf_buf1.mode = 0;
//            intf_buf2.mode = 0;
//
//            intf_extmem.wr_data = intf_buf1.m0_r_data;
//
//            if(mem_save_idx < mem_save_words) begin
//
//
//                intf_buf1.m0_r_en   = dec_to_hot(mem_save_buffer_addr);
//                intf_buf1.m0_r_addr = buf1_rd_addr[mem_save_buffer_addr];
//
//                next_buf1_rd_addr[mem_save_buffer_addr]  =  buf1_rd_addr[mem_save_buffer_addr] + 1;
//
//
//                next_mem_save_idx   = mem_save_idx + 1;
//
//            end else begin
//
//                next_state   = IDLE;
//                done_executing  = 1;
//                next_mem_save_idx = 0;
//            end
//
//            if(prev_state == state) begin
//                intf_extmem.we = 1;
//                intf_extmem.wr_addr = mem_save_start + mem_save_idx - 1;
//            end
//
//
//        end
//
//
//interface interface_pe_array_ctrl;
//
//logic   [`N_PE-1:0]				    shifting_line   [`N_PE-1:0];
//logic 	[`N_PE-1:0]					shifting_filter [`N_PE-1:0];
//logic 	[`N_PE-1:0] 				mac_enable [`N_PE-1:0];	 
//logic 								line_buffer_reset;
//logic 	[`ADDR_FIFO-1:0]			row_length;
//logic	[`N_PE-1:0]					adder_enable;
//logic								final_filter_bank;
//logic								shifting_line_pool;
//logic								line_buffer_reset_pool;
//logic   [`ADDR_FIFO-1:0]			row_length_pool;	
//logic	[`WID_PE_BITS*`N_PE-1:0]	input_bus1_PEA;
//logic	[`WID_PE_BITS*`N_PE-1:0]	input_bus2_PEA;
//logic	[`WID_PE_BITS*`N_PE-1:0]	output_bus1_PEA;
//
//logic   [2:0]                       pool_nl;
//logic   [2:0]                       nl_type;
//logic                               nl_enable;
//logic                               pool_enable;
//
//
//endinterface

`include "header.vh"

interface interface_pe_array;


logic   [`N_PE-1:0]				    shifting_line [`N_PE-1:0];
logic 	[`N_PE-1:0]					shifting_filter [`N_PE-1:0];
logic 	[`N_PE-1:0]					mac_enable [`N_PE-1:0];	 
logic   [`N_PE-1:0]                 nl_enable;
logic   [`N_PE-1:0]                 feedback_enable;

logic 								line_buffer_reset;
logic 	[`ADDR_FIFO-1:0]			row_length;
logic	[`N_PE-1:0]					adder_enable;
logic								final_filter_bank;
logic								shifting_line_pool;
logic								line_buffer_reset_pool;
logic   [`ADDR_FIFO-1:0]			row_length_pool;	
logic	[`WID_PE_BITS*`N_PE-1:0]	input_bus1_PEA;
logic	[`WID_PE_BITS*`N_PE-1:0]	input_bus2_PEA;
logic	[`WID_PE_BITS*`N_PE-1:0]	output_bus1_PEA;

logic   [2:0]                       pool_nl;
logic   [2:0]                       nl_type;
logic                               pool_enable;


endinterface

interface interface_pe_array_ctrl;

logic   [`N_PE-1:0]				    shifting_line   [`N_PE-1:0];
logic 	[`N_PE-1:0]					shifting_filter [`N_PE-1:0];
logic   [`N_PE-1:0]					mac_enable [`N_PE-1:0];	 
logic   [`N_PE-1:0]                 nl_enable;
logic   [`N_PE-1:0]                 feedback_enable;

logic 								line_buffer_reset;
logic 	[`ADDR_FIFO-1:0]			row_length;
logic	[`N_PE-1:0]					adder_enable;
logic								final_filter_bank;
logic								shifting_line_pool;
logic								line_buffer_reset_pool;
logic   [`ADDR_FIFO-1:0]			row_length_pool;	
logic	[`WID_PE_BITS*`N_PE-1:0]	input_bus1_PEA;
logic	[`WID_PE_BITS*`N_PE-1:0]	input_bus2_PEA;
logic	[`WID_PE_BITS*`N_PE-1:0]	output_bus1_PEA;

logic   [2:0]                       pool_nl;
logic   [15:0]                      nl_type;
logic                               pool_enable;


endinterface

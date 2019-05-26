`include "header.vh"

interface interface_buffer;


logic									mode;
logic	    [`N_PE-1:0] 				m0_r_en;
logic	    [`ADDR_RAM-1:0]			    m0_r_addr;
logic		[`WID_RAM-1:0]		        m0_r_data;
logic	    [`N_PE-1:0]					m0_w_en;
logic	    [`ADDR_RAM-1:0]			    m0_w_addr;
logic	    [`WID_RAM-1:0]				m0_w_data;

logic									m1_r_en;
logic	    [`ADDR_RAM-1:0]			    m1_r_addr;
logic       [`WID_PE_BITS*`N_PE-1:0]    m1_output_bus;
logic    								m1_w_en;
logic	    [`ADDR_RAM-1:0]			    m1_w_addr;
logic	    [`WID_PE_BITS*`N_PE-1:0]    m1_input_bus;



endinterface

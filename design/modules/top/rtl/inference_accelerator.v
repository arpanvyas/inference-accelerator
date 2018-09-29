`include "header.vh"
module inference_accelerator(
    input 								rst,
    input 								clk,
    input								host_start,
    input	[`ADDR_EXT_RAM-1:0]			ext_ram_start_addr,				
	output	[`N_PE-1:0]					mem_r_en,
	output	[`ADDR_RAM-1:0]				mem_r_addr,
	input		[`WID_RAM-1:0]			mem_r_data,
	output	[`N_PE-1:0]					mem_w_en,
	output	[`ADDR_RAM-1:0]				mem_w_addr,
	output	[`WID_RAM-1:0]				mem_w_data,
	output	[`CONTR_STATES_BITS-1:0]	internal_state,
	output								done
);


//External Memory Signals
	wire	[`N_PE-1:0]					mem_r_en;
	wire	[`ADDR_RAM-1:0]				mem_r_addr;
	wire	[`WID_RAM-1:0]				mem_r_data;
	wire	[`N_PE-1:0]					mem_w_en;
	wire	[`ADDR_RAM-1:0]				mem_w_addr;
	wire	[`WID_RAM-1:0]				mem_w_data;

//Controller
	wire	[`CONTR_STATES_BITS-1:0]	internal_state;
	wire								done;

//PE Array signals
	wire								pea_shifting_line;
	wire	 							pea_line_buffer_reset;
	wire 	[`ADDR_FIFO-1:0]			pea_row_length;
	wire	[`N_PE-1:0]					pea_shifting_filter;
	wire	 							pea_mac_enable;
	wire								pea_adder_enable;
	wire								pea_final_filter_bank;
	wire	[2:0]						pea_pool_nl;
	wire								pea_pool_enable;
	wire								pea_shifting_line_pool;
	wire								pea_line_buffer_reset_pool;
	wire	[`ADDR_FIFO-1:0]			pea_row_length_pool;
	wire	[2:0]						pea_nl_type;
	wire								pea_nl_enable;	 
	wire	[`WID_PE_BITS*`N_PE-1:0]	pea_input_bus1_PEA;
	wire	[`WID_PE_BITS*`N_PE-1:0]	pea_input_bus2_PEA;
	wire	[`WID_PE_BITS*`N_PE-1:0]	pea_output_bus1_PEA;
	
//first buffer 
	wire	[1:0]						f_mode;
	wire	[`N_PE-1:0]					f_m0_r_en;
	wire	[`ADDR_RAM-1:0]				f_m0_r_addr;
	wire	[`WID_RAM-1:0]				f_m0_r_data;
	wire	[`N_PE-1:0]					f_m0_w_en;
	wire	[`ADDR_RAM-1:0]				f_m0_w_addr;
	wire	[`WID_RAM-1:0]				f_m0_w_data;
	
	wire								f_m1_r_en;
	wire	[`ADDR_RAM-1:0]				f_m1_r_addr;
    wire	[`WID_PE_BITS*`N_PE-1:0]	f_m1_output_bus;
	wire								f_m1_w_en;
	wire	[`ADDR_RAM-1:0]				f_m1_w_addr;
	wire	[`WID_PE_BITS*`N_PE-1:0] 	f_m1_input_bus;

//second buffer 
	wire	[1:0]						s_mode;
	wire	[`N_PE-1:0]					s_m0_r_en;
	wire	[`ADDR_RAM-1:0]				s_m0_r_addr;
	wire	[`WID_RAM-1:0]				s_m0_r_data;
	wire	[`N_PE-1:0]					s_m0_w_en;
	wire	[`ADDR_RAM-1:0]				s_m0_w_addr;
	wire	[`WID_RAM-1:0]				s_m0_w_data;
	
	wire								s_m1_r_en;
	wire	[`ADDR_RAM-1:0]				s_m1_r_addr;
	wire	[`WID_PE_BITS*`N_PE-1:0]	s_m1_output_bus;
	wire								s_m1_w_en;
	wire	[`ADDR_RAM-1:0]				s_m1_w_addr;
	wire	[`WID_PE_BITS*`N_PE-1:0]	s_m1_input_bus;



PE_array PE_array_module(
	.shifting_line(pea_shifting_line),
	.line_buffer_reset(pea_line_buffer_reset),
	.row_length(pea_row_length),
	.shifting_filter(pea_shifting_filter),
	.mac_enable(pea_mac_enable),
	.adder_enable(pea_adder_enable),
	.final_filter_bank(pea_final_filter_bank),
	.pool_nl(pea_pool_nl),
	.pool_ebable(pea_pool_enable),
	.shifting_line_pool(pea_shifting_line_pool),
	.line_buffer_reset_pool(pea_line_buffer_reset_pool),
	.row_length_pool(pea_row_length_pool),
	.nl_type(pea_nl_type),
	.nl_enable(pea_nl_enable),
	.input_bus1_PEA(pea_input_bus1_PEA),
	.input_bus2_PEA(pea_input_bus2_PEA),
	.output_bus1_PEA(pea_output_bus1_PEA) 
	);

memory_buffer first_buffer_module(
	.rst(rst),
	.clk(clk),
	.mode(f_mode),
	.m0_r_en(f_m0_r_en),
	.m0_r_addr(f_m0_r_addr),
	.m0_r_data(f_m0_r_data),
	.m0_w_en(f_m0_w_en),
	.m0_w_addr(f_m0_w_addr),
	.m0_w_data(f_m0_w_data),
	
	.m1_r_en(f_m1_r_en),
	.m1_r_addr(f_m1_r_addr),
	.m1_output_bus(f_m1_output_bus),
	.m1_w_en(f_m1_w_en),
	.m1_w_addr(f_m1_w_addr),
	.m1_input_bus(f_m1_input_bus)
);

memory_buffer second_buffer_module(
	.rst(rst),
	.clk(clk),
	.mode(s_mode),
	.m0_r_en(s_m0_r_en),
	.m0_r_addr(s_m0_r_addr),
	.m0_r_data(s_m0_r_data),
	.m0_w_en(s_m0_w_en),
	.m0_w_addr(s_m0_w_addr),
	.m0_w_data(s_m0_w_data),
	
	.m1_r_en(s_m1_r_en),
	.m1_r_addr(s_m1_r_addr),
	.m1_output_bus(s_m1_output_bus),
	.m1_w_en(s_m1_w_en),
	.m1_w_addr(s_m1_w_addr),
	.m1_input_bus(s_m1_input_bus)
);		

//contr contr(
//	.rst(rst),
//	.clk(clk),
//	.host_start(host_start),
//	.ext_ram_start_addr(ext_ram_start_addr),
//	.mem_r_en(mem_r_en),
//	.mem_r_addr(mem_r_addr),
//	.mem_r_data(mem_r_data),
//	.mem_w_en(mem_w_en),
//	.mem_w_addr(mem_w_addr),
//	.mem_w_data(mem_w_data)
//	);

controller controller_module(
//External Memory Signals
	.mem_r_en(mem_r_en),
	.mem_r_addr(mem_r_addr),
	.mem_r_data(mem_r_data),
	.mem_w_en(mem_w_en),
	.mem_w_addr(mem_w_addr),
	.mem_w_data(mem_w_data),

//Host
	.state(internal_state),
	.done(done),
	.host_start(host_start),
	.ext_ram_start_addr(ext_ram_start_addr),

//PE Array
	.pea_shifting_line(pea_shifting_line),
	.pea_line_buffer_reset(pea_line_buffer_reset),
	.pea_row_length(pea_row_length),
	.pea_shifting_filter(pea_shifting_filter),
	.pea_mac_enable(pea_mac_enable),
	.pea_adder_enable(pea_adder_enable),
	.pea_final_filter_bank(pea_final_filter_bank),
	.pea_pool_nl(pea_pool_nl),
	.pea_pool_ebable(pea_pool_enable),
	.pea_shifting_line_pool(pea_shifting_line_pool),
	.pea_line_buffer_reset_pool(pea_line_buffer_reset_pool),
	.pea_row_length_pool(pea_row_length_pool),
	.pea_nl_type(pea_nl_type),
	.pea_nl_enable(pea_nl_enable),	
	.pea_input_bus1_PEA(pea_input_bus1_PEA),
	.pea_input_bus2_PEA(pea_input_bus2_PEA),
	.pea_output_bus1_PEA(pea_output_bus1_PEA),
	
//First Buffer 
	.mode(f_mode),
	.m0_r_en(f_m0_r_en),
	.m0_r_addr(f_m0_r_addr),
	.m0_r_data(f_m0_r_data),
	.m0_w_en(f_m0_w_en),
	.m0_w_addr(f_m0_w_addr),
	.m0_w_data(f_m0_w_data),
	
	.m1_r_en(f_m1_r_en),
	.m1_r_addr(f_m1_r_addr),
	.m1_output_bus(f_m1_output_bus),
	.m1_w_en(f_m1_w_en),
	.m1_w_addr(f_m1_w_addr),
	.m1_input_bus(f_m1_input_bus),

//Second Buffer 
	.mode(s_mode),
	.m0_r_en(s_m0_r_en),
	.m0_r_addr(s_m0_r_addr),
	.m0_r_data(s_m0_r_data),
	.m0_w_en(s_m0_w_en),
	.m0_w_addr(s_m0_w_addr),
	.m0_w_data(s_m0_w_data),
	
	.m1_r_en(s_m1_r_en),
	.m1_r_addr(s_m1_r_addr),
	.m1_output_bus(s_m1_output_bus),
	.m1_w_en(s_m1_w_en),
	.m1_w_addr(s_m1_w_addr),
	.m1_input_bus(s_m1_input_bus)

);




endmodule

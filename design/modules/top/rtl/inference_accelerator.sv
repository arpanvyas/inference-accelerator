`include "header.vh"
module inference_accelerator (

    input logic clk,
    input logic rst,

    //SPI Slave Signals
    input  SCLK,
    input  MOSI,
    input  SS,
    output MISO,

    //External Memory Interfacing : Assuming DMA
    output   logic			    we_extmem,
    output   logic			    re_extmem,
    output   logic	[23:0]		rd_addr_extmem,
    output   logic	[23:0]		wr_addr_extmem,
    output   logic	[31:0]		data_wr_extmem,
    input   logic	[31:0]		data_rd_extmem

);


//INSTANTIATING controller_inst

logic			SCLK;
logic			MOSI;
logic			SS;
logic			MISO;

	
//first buffer 
logic	[1:0]						f_mode;
logic	[`N_PE-1:0]					f_m0_r_en;
logic	[`ADDR_RAM-1:0]				f_m0_r_addr;
logic	[`WID_RAM-1:0]				f_m0_r_data;
logic	[`N_PE-1:0]					f_m0_w_en;
logic	[`ADDR_RAM-1:0]				f_m0_w_addr;
logic	[`WID_RAM-1:0]				f_m0_w_data;
	
logic								f_m1_r_en;
logic	[`ADDR_RAM-1:0]				f_m1_r_addr;
logic	[`WID_PE_BITS*`N_PE-1:0]	f_m1_output_bus;
logic								f_m1_w_en;
logic	[`ADDR_RAM-1:0]				f_m1_w_addr;
logic	[`WID_PE_BITS*`N_PE-1:0] 	f_m1_input_bus;

//second buffer 
logic	[1:0]						s_mode;
logic	[`N_PE-1:0]					s_m0_r_en;
logic	[`ADDR_RAM-1:0]				s_m0_r_addr;
logic	[`WID_RAM-1:0]				s_m0_r_data;
logic	[`N_PE-1:0]					s_m0_w_en;
logic	[`ADDR_RAM-1:0]				s_m0_w_addr;
logic	[`WID_RAM-1:0]				s_m0_w_data;
	
logic								s_m1_r_en;
logic	[`ADDR_RAM-1:0]				s_m1_r_addr;
logic	[`WID_PE_BITS*`N_PE-1:0]	s_m1_output_bus;
logic								s_m1_w_en;
logic	[`ADDR_RAM-1:0]				s_m1_w_addr;
logic	[`WID_PE_BITS*`N_PE-1:0]	s_m1_input_bus;


controller controller_inst (
	.clk(clk),
	.rst(rst),
	.SCLK(SCLK),
	.MOSI(MOSI),
	.SS(SS),
	.MISO(MISO),

	
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



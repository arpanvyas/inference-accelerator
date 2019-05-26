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
    interface_extmem    intf_extmem

);


//INSTANTIATING controller_inst

logic			SCLK;
logic			MOSI;
logic			SS;
logic			MISO;


interface_buffer intf_buf1();
interface_buffer intf_buf2();
interface_pe_array intf_pea();

controller controller_inst (
	.clk(clk),
	.rst(rst),
	.SCLK(SCLK),
	.MOSI(MOSI),
	.SS(SS),
	.MISO(MISO),

    //External Memory
    .intf_extmem(intf_extmem),
	
    //First Buffer 
    .intf_buf1(intf_buf1),

    //Second Buffer 
    .intf_buf2(intf_buf2),

    //PE Array
    .intf_pea(intf_pea)

);
memory_buffer first_buffer_inst(
	.rst(rst),
	.clk(clk),
    .intf_buf(intf_buf1)
);

memory_buffer second_buffer_inst(
	.rst(rst),
	.clk(clk),
    .intf_buf(intf_buf2)
);		

PE_array pe_array_inst(
    .rst(rst),
    .clk(clk),
    .intf_pea(intf_pea)

);


endmodule

`include "header.vh"

module host (

    input logic clk,
    input logic rst,

);


//INSTANTIATING external_memory_inst

logic			we_extmem;
logic			re_extmem;
logic	[23:0]		rd_addr_extmem;
logic	[23:0]		wr_addr_extmem;
logic	[31:0]		data_wr_extmem;
logic	[31:0]		data_rd_extmem;

external_memory external_memory_inst (
	.clk(clk),
	.we(we_extmem),
	.re(re_extmem),
	.rd_addr(rd_addr_extmem),
	.wr_addr(wr_addr_extmem),
	.data_in(data_wr_extmem),
	.data_out(data_rd_extmem)
);

//INSTANTIATING inference_accelerator_inst

logic			SCLK;
logic			MOSI;
logic			SS;
logic			MISO;

inference_accelerator inference_accelerator_inst (
	.clk(clk),
	.rst(rst),
	.SCLK(SCLK),
	.MOSI(MOSI),
	.SS(SS),
	.MISO(MISO),
    .we_extmem(we_extmem),
	.re_extmem(re_extmem),
	.rd_addr_extmem(rd_addr_extmem),
	.wr_addr_extmem(wr_addr_extmem),
	.data_wr_extmem(data_wr_extmem),
	.data_rd_extmem(data_rd_extmem)
);


`include "header.vh"

module host (

    input logic clk,
    input logic rst

);


//INSTANTIATING external_memory_inst
interface_extmem intf_extmem();


external_memory external_memory_inst (
	.clk(clk),
    .intf_extmem(intf_extmem)
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

    .intf_extmem(intf_extmem)
);


endmodule

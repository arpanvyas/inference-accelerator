`include "header.vh"
module filter_buffer(
    input			rst,
    input			clk,
	 input			shifting,
    input			[`WID_FILTER-1:0] inp,
    output			[`WID_FILTER-1:0] out1,
    output			[`WID_FILTER-1:0] out2,
    output			[`WID_FILTER-1:0] out3,
    output			[`WID_FILTER-1:0] out4,
    output			[`WID_FILTER-1:0] out5,
    output			[`WID_FILTER-1:0] out6,
    output			[`WID_FILTER-1:0] out7,
    output			[`WID_FILTER-1:0] out8,
    output			[`WID_FILTER-1:0] out9
    );


shift_register9 shift_register9_module 
(
	.rst			(rst),
	.clk			(clk),
	.shifting		(shifting),
	.inp_sr			(inp),
	.out_1			(out1),
	.out_2			(out2),
	.out_3			(out3),
	.out_4			(out4),
	.out_5			(out5),
	.out_6			(out6),
	.out_7			(out7),
	.out_8			(out8),
	.out_9			(out9)
);

endmodule

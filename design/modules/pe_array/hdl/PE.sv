`include "header.vh"
module PE(
    input rst,
    input clk,
    input logic [`N_PE-1:0]  shifting_line,
	input logic [`N_PE-1:0]  shifting_filter,
	input logic [`N_PE-1:0]  mac_enable,
    input logic              nl_enable,
    input logic              feedback_enable,

	input line_buffer_reset,
	input [`ADDR_FIFO-1:0]	row_length,
	input adder_enable,
	input final_filter_bank,								//0 for intermediate filter banks, 1 for final bank
    input [2:0]							pool_nl,		//state reg
    input								pool_enable,
    input								shifting_line_pool,
    input								line_buffer_reset_pool,
    input [`ADDR_FIFO-1:0]				row_length_pool,
    input [2:0]							nl_type,
    input [`WID_PE_BITS*`N_PE-1:0]		input_bus1_PE,	//line inputs to all the convolvers = 32*16b
    input [`WID_PE_BITS-1:0]			input_2_PE,		//feedback input for the Single PE
    output[`WID_PE_BITS:0]				output_1_PE		//Single PE output
    );

wire	[`WID_PE_BITS-1:0]		input_channels		[`N_PE-1:0];
`UNPACK_ARRAY(`WID_PE_BITS,`N_PE,input_channels,input_bus1_PE)
wire	[`WID_PE_BITS-1:0]		output_mac			[`N_PE-1:0];
wire	[`WID_PE_BITS*`N_PE-1:0]	output_mac_packed;
`PACK_ARRAY(`WID_PE_BITS,`N_PE, output_mac, output_mac_packed)
wire							adder_enable;
reg		[`WID_PE_BITS-1:0]		interm_add;



genvar i;
generate for(i=0 ; i<`N_CONV ; i=i+1)
begin
convolver convolver_module
	(
		.rst						(rst),
		.clk						(clk),
		.shifting_line				(shifting_line[i]),
		.input_line					(input_channels[i]),
		.shifting_filter			(shifting_filter[i]),
		.line_buffer_reset			(line_buffer_reset),
		.row_length					(row_length),
		.input_filter				(input_channels[i]),
		.mac_enable					(mac_enable[i]),
		.output_mac					(output_mac[i])
	);
end
endgenerate

adder_tree	adder_tree_module
(
		.rst						(rst),
		.clk						(clk),
		.output_mac_packed			(output_mac_packed),
		.adder_enable				(adder_enable),
		.adder_tree_out				(adder_tree_out)
);

wire [`WID_PE_BITS-1:0] in_nl_data,out_nl_data;
assign in_nl_data = adder_tree_out;

non_linearity	non_linearity_module
(
		.rst						(rst),
		.clk						(clk),
		.nl_enable					(nl_enable),
		.nl_type					(nl_type),
		.in_nl_data					(in_nl_data),
		.out_nl_data				(out_nl_data)
);

wire [`WID_PE_BITS-1:0] in_pool_data;
assign in_pool_data = out_nl_data;

pooling	pooling_module
(
    .rst							(rst),
    .clk							(clk),
    .pool_enable					(pool_enable),
    .in_pool_data				 	(in_pool_data),
    .shifting_line					(shifting_line_pool),
	.line_buffer_reset				(line_buffer_reset_pool),
	.row_length						(row_length_pool),
    .out_pool_data					(out_pool_data)
);
assign output_1_PE = out_pool_data;

endmodule
























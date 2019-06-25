`include "header.vh"
//The module takes 9+9 inputs and finds the dot product in 3 cycles
//Can be optimised in terms of computations
module mac(
   input											rst,
   input											clk,
	input											enable,
   input  signed				[`WID_LINE-1:0] 		input_line_1,
   input  signed				[`WID_LINE-1:0] 		input_line_2,
   input  signed				[`WID_LINE-1:0] 		input_line_3,
   input  signed				[`WID_LINE-1:0] 		input_line_4,
   input  signed				[`WID_LINE-1:0] 		input_line_5,
   input  signed		 		[`WID_LINE-1:0] 		input_line_6,
   input  signed				[`WID_LINE-1:0] 		input_line_7,
	input signed				[`WID_LINE-1:0] 		input_line_8,
	input signed				[`WID_LINE-1:0] 		input_line_9,
	input signed				[`WID_FILTER-1:0]		input_filter_1,
	input signed				[`WID_FILTER-1:0]		input_filter_2,
	input signed				[`WID_FILTER-1:0]		input_filter_3,
	input signed				[`WID_FILTER-1:0]		input_filter_4,
	input signed				[`WID_FILTER-1:0]		input_filter_5,
	input signed				[`WID_FILTER-1:0]		input_filter_6,
	input signed				[`WID_FILTER-1:0]		input_filter_7,
	input signed				[`WID_FILTER-1:0]		input_filter_8,
	input signed				[`WID_FILTER-1:0]		input_filter_9,
	output	reg	signed [`WID_MAC_OUT-1:0]	output_mac,
    interface_regfile                       regfile
    );

reg signed	[`WID_MAC_MULT-1:0]	m1,m2,m3,m4,m5,m6,m7,m8,m9;
reg	signed  [`WID_MAC_OUT-1:0]	a1,a2,a3;

logic   [15:0]  scale;
assign scale = regfile.general__scale;


always@(posedge clk, posedge rst)
begin

	if(rst) begin
		a1				<= 0;
		a2				<= 0;
		output_mac	<= 0;
	end else begin
		m1	<= input_line_1*input_filter_1 >>> scale;
		m2	<= input_line_2*input_filter_2 >>> scale;
		m3	<= input_line_3*input_filter_3 >>> scale;
		m4	<= input_line_4*input_filter_4 >>> scale;
		m5	<= input_line_5*input_filter_5 >>> scale;
		m6	<= input_line_6*input_filter_6 >>> scale;
		m7	<= input_line_7*input_filter_7 >>> scale;
		m8	<= input_line_8*input_filter_8 >>> scale;
		m9	<= input_line_9*input_filter_9 >>> scale;
		a1	<= m1+m2+m3+m4;
		a2	<= m5+m6+m7+m8;	
		a3  <= m9;
		if(enable) begin
			output_mac	<=	a1+a2+a3;
		end else begin
			output_mac	<= 0;
		end
	end

end




endmodule

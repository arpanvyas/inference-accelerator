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


always@(posedge clk, posedge rst)
begin

	if(rst) begin
		a1				<= #1 0;
		a2				<= #1 0;
		output_mac	<= #1 0;
	end else begin
        m1	<= #1 (input_line_1*input_filter_1) / (2**`SCALE);
		m2	<= #1 (input_line_2*input_filter_2) / (2**`SCALE);
		m3	<= #1 (input_line_3*input_filter_3) / (2**`SCALE);
		m4	<= #1 (input_line_4*input_filter_4) / (2**`SCALE);
		m5	<= #1 (input_line_5*input_filter_5) / (2**`SCALE);
		m6	<= #1 (input_line_6*input_filter_6) / (2**`SCALE);
		m7	<= #1 (input_line_7*input_filter_7) / (2**`SCALE);
		m8	<= #1 (input_line_8*input_filter_8) / (2**`SCALE);
		m9	<= #1 (input_line_9*input_filter_9) / (2**`SCALE);
		a1	<= #1 m1+m2+m3+m4;
		a2	<= #1 m5+m6+m7+m8;	
		a3  <= #1 m9;
		if(enable) begin
			output_mac	<=  #1	a1+a2+a3;
		end else begin
			output_mac	<= #1 0;
		end
	end

end




endmodule

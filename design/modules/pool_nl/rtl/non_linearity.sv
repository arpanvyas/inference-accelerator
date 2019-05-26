`include "header.vh"
module non_linearity(
    input		rst,
    input		clk,
	input		nl_enable, 
	input[2:0]	nl_type, 
	input		[`WID_PE_BITS-1:0]		in_nl_data,
	output reg	[`WID_PE_BITS-1:0]	out_nl_data
    );
	  

reg[`WID_PE_BITS-1:0]	nl_type_rl_in,nl_type_rl_out;

//nl_type
//	0 : none
//	1 : relu

always @(posedge clk or posedge rst) begin
	if (rst) begin
		out_nl_data	<= 0;
		nl_type_rl_in	<= 0;
	end	else begin
		out_nl_data		<= in_nl_data;
		nl_type_rl_in	<= in_nl_data;
		if (nl_enable) begin

			case (nl_type)
				0: begin
					out_nl_data		<= in_nl_data;

				end			
				1: begin
					nl_type_rl_in	<= in_nl_data;
					out_nl_data		<= (nl_type_rl_in>0) ? nl_type_rl_in: 0;
				end
				default: begin
					out_nl_data		<= in_nl_data;
				end
			endcase
		end

	end

end




endmodule


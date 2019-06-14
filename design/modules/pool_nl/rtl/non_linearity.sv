`include "header.vh"
module non_linearity(
    input		rst,
    input		clk,
	input		nl_enable, 
	input[15:0]	nl_type, 
	input logic signed		[`WID_PE_BITS-1:0]		in_nl_data,
	output logic signed	[`WID_PE_BITS-1:0]	out_nl_data
    );
	  

reg[`WID_PE_BITS-1:0]	nl_type_rl_in,nl_type_rl_out;


always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		out_nl_data	<= 0;
		nl_type_rl_in	<= 0;
	end	else begin
		out_nl_data		<= in_nl_data;
		nl_type_rl_in	<= in_nl_data;
		if (nl_enable) begin

			case (nl_type)

				16'h0000: begin //RELU
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


`include "header.vh"
module non_linearity(
    input		rst,
    input		clk,
	input		nl_enable, 
	input[15:0]	nl_type, 
	input logic signed		[`WID_PE_BITS-1:0]		in_nl_data,
	output logic signed	[`WID_PE_BITS-1:0]	out_nl_data,
    interface_regfile       regfile
    );
	  
always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
		out_nl_data	    <= #1 0;
	end	else begin
		if (nl_enable) begin
			case (regfile.nl__nl_type)
				16'h0000: begin //RELU
					out_nl_data		<= #1 (in_nl_data>0) ? in_nl_data: 0;
				end
				default: begin
					out_nl_data		<= #1 in_nl_data;
				end
			endcase
        end else begin
            out_nl_data <= #1 in_nl_data;
        end

	end

end




endmodule


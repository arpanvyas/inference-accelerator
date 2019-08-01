`include "header.vh"
module shift_register2(
    input									rst,
    input 									clk,
    input 									shifting,
    input 			[`WID_FIFO-1:0]	inp_sr,
    output	reg	[`WID_FIFO-1:0]	out_1,
    output	reg	[`WID_FIFO-1:0]	out_2
    );



always@(posedge clk, posedge rst)
begin
	
	if(rst) begin
	out_1	<= #1 0;
	out_2	<= #1 0;
	end else begin
		if(shifting) begin
			out_1	<= #1 inp_sr;
			out_2   <= #1 out_1;

		end else begin
			out_1	<= #1 out_1;
			out_2	<= #1 out_2;
		end
	end

end




endmodule

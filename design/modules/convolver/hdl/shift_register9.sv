`include "header.vh"
module shift_register9
(
    input									rst,
    input 									clk,
    input 									shifting,
    input 			[`WID_FILTER-1:0]	inp_sr,
    output	reg	[`WID_FILTER-1:0]	out_1,
    output	reg	[`WID_FILTER-1:0]	out_2,
    output	reg	[`WID_FILTER-1:0]	out_3,
    output	reg	[`WID_FILTER-1:0]	out_4,
    output	reg	[`WID_FILTER-1:0]	out_5,
    output	reg	[`WID_FILTER-1:0]	out_6,
    output	reg	[`WID_FILTER-1:0]	out_7,
    output	reg	[`WID_FILTER-1:0]	out_8,
    output	reg	[`WID_FILTER-1:0]	out_9
    );



always@(posedge clk, posedge rst)
begin
	
	if(rst) begin
	out_1	<= #1 0;	out_2	<= #1 0;	out_3	<= #1 0;
	out_4	<= #1 0;	out_5	<= #1 0;	out_6	<= #1 0;
	out_7	<= #1 0;	out_8	<= #1 0;	out_9	<= #1 0;
	end else begin
		if(shifting) begin
			out_1	<= #1 inp_sr;	out_2   <= #1 out_1;	out_3	<= #1 out_2;
			out_4	<= #1 out_3;	out_5	<= #1 out_4;	out_6	<= #1 out_5;
			out_7	<= #1 out_6;	out_8	<= #1 out_7;	out_9	<= #1 out_8;
		end else begin
			out_1	<= #1 out_1;	out_2   <= #1 out_2;	out_3   <= #1 out_3;
			out_4	<= #1 out_4;	out_5	<= #1 out_5;	out_6	<= #1 out_6;
			out_7	<= #1 out_7;	out_8	<= #1 out_8;	out_9	<= #1 out_9;
		end
	end

end

endmodule

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
	out_1	<= 0;	out_2	<= 0;	out_3	<= 0;
	out_4	<= 0;	out_5	<= 0;	out_6	<= 0;
	out_7	<= 0;	out_8	<= 0;	out_9	<= 0;
	end else begin
		if(shifting) begin
			out_1	<= inp_sr;	out_2 <=	out_1;	out_3	<= out_2;
			out_4	<= out_3;	out_5	<= out_4;	out_6	<= out_5;
			out_7	<= out_6;	out_8	<= out_7;	out_9	<= out_8;
		end else begin
			out_1	<= out_1;	out_2 <=	out_2;	out_3	<= out_3;
			out_4	<= out_4;	out_5	<= out_5;	out_6	<= out_6;
			out_7	<= out_7;	out_8	<= out_8;	out_9	<= out_9;
		end
	end

end

endmodule

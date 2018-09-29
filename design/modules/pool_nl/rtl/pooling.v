`include "header.vh"
module pooling(
    input	rst,
    input	clk,
    input	pool_enable,
    input	[`WID_PE_BITS-1:0] in_pool_data,
    input	shifting_line,
	input	line_buffer_reset,
	input	[`ADDR_FIFO-1:0]	row_length,
    output reg	[`WID_PE_BITS-1:0]	out_pool_data
    );
wire signed [`WID_PE_BITS-1:0]	out1,out2,out3,out4;
reg signed [`WID_PE_BITS-1:0]	max1,max2;

line_buffer_pool line_buffer_pool_module(
	.clk(clk),
	.rst(rst),
    .shifting(shifting_line),
	.line_buffer_reset(line_buffer_reset),
    .inp(in_pool_data),
    .row_length(row_length),
    .out1(out1),
    .out2(out2),
   	.out3(out3),
    .out4(out4)
);



always@(posedge clk, posedge rst) begin
	if(rst) begin
		out_pool_data <= 0;
	end else begin
		if(pool_enable) begin
			max1			<= (out1>out2) ? out1: out2;
			max2			<= (out3>out4) ? out3: out4;
			out_pool_data	<= (max1>max2) ? max1: max2;
		end
	end
end




endmodule


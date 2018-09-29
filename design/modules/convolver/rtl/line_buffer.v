`include "header.vh"
module line_buffer(
    input			rst,
    input			clk,
	 input			shifting,
	 input			line_buffer_reset,
    input			[`WID_LINE-1:0] inp,
    input			[`ADDR_FIFO-1:0] row_length,
    output			[`WID_LINE-1:0] out1,
    output			[`WID_LINE-1:0] out2,
    output			[`WID_LINE-1:0] out3,
    output			[`WID_LINE-1:0] out4,
    output			[`WID_LINE-1:0] out5,
    output			[`WID_LINE-1:0] out6,
    output			[`WID_LINE-1:0] out7,
    output			[`WID_LINE-1:0] out8,
    output			[`WID_LINE-1:0] out9
    );
	 
wire	[`WID_LINE-1:0]	line_fifo1_out;
wire	[`WID_LINE-1:0]	line_fifo2_out;

shift_register3 shift_register3_module1 
(
    .rst	(rst),
    .clk	(clk),
    .shifting	(shifting),
    .inp_sr	(inp),
    .out_1	(out1),
    .out_2	(out2),
    .out_3	(out3)
    ); 

line_fifo line_fifo_module1 
	(
		.rst			(rst),
		.clk			(clk),
		.row_length	(row_length),
		.shifting	(shifting),
		.fifo_reset	(line_buffer_reset),
		.wr_data_i	(out3),
		.rd_data_o	(line_fifo1_out)
	);
	
	
shift_register3 shift_register3_module2 
(
    .rst	(rst),
    .clk	(clk),
    .shifting	(shifting),
    .inp_sr	(line_fifo1_out),
    .out_1	(out4),
    .out_2	(out5),
    .out_3	(out6)
    ); 

line_fifo line_fifo_module2 
	(
		.rst			(rst),
		.clk			(clk),
		.row_length	(row_length),
		.shifting	(shifting),
		.fifo_reset	(line_buffer_reset),
		.wr_data_i	(out6),
		.rd_data_o	(line_fifo2_out)
	);

shift_register3 shift_register3_module3 
(
    .rst			(rst),
    .clk			(clk),
    .shifting	(shifting),
    .inp_sr		(line_fifo2_out),
    .out_1		(out7),
    .out_2		(out8),
    .out_3		(out9)
    ); 

endmodule

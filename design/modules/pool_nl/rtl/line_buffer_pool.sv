`include "header.vh"
module line_buffer_pool(
    input			rst,
    input			clk,
	input			shifting,
	input			line_buffer_reset,
    input			[`WID_LINE-1:0] inp,
    input			[`ADDR_FIFO-1:0] row_length,
    output			[`WID_LINE-1:0] out1,
    output			[`WID_LINE-1:0] out2,
    output			[`WID_LINE-1:0] out3,
    output			[`WID_LINE-1:0] out4
    ); 
	 
wire	[`WID_LINE-1:0]	line_fifo1_out;

shift_register2 shift_register2_module1 
(
    .rst        (rst),
    .clk        (clk),
    .shifting   (shifting),
    .inp_sr     (inp),
    .out_1      (out1),
    .out_2      (out2)
    ); 

line_fifo line_fifo_module1 
	(
		.rst              (rst),
		.clk              (clk),
		.row_length       (row_length),
		.shifting         (shifting),
		.fifo_reset       (line_buffer_reset),
		.wr_data_i        (out2),
		.rd_data_o        (line_fifo1_out)
	);
		
shift_register2 shift_register2_module2 
(
    .rst        (rst),
    .clk        (clk),
    .shifting	(shifting),
    .inp_sr     (line_fifo1_out),
    .out_1      (out3),
    .out_2      (out4)
    ); 


endmodule

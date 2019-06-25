`include "header.vh"
module convolver(
    input							rst,
    input							clk,
    input							shifting_line,
    input							line_buffer_reset,
    input		[`ADDR_FIFO-1:0]	row_length,
    input		[`WID_LINE-1:0]		input_line,
    input							shifting_filter,	
    input		[`WID_FILTER-1:0]	input_filter,	
    input							mac_enable,
    output signed[`WID_MAC_OUT-1:0]	output_mac,
    interface_regfile               regfile
);

wire signed [`WID_FILTER-1:0]	out_filter_1;
wire signed [`WID_FILTER-1:0]	out_filter_2;
wire signed [`WID_FILTER-1:0]	out_filter_3;
wire signed [`WID_FILTER-1:0]	out_filter_4;
wire signed [`WID_FILTER-1:0]	out_filter_5;
wire signed [`WID_FILTER-1:0]	out_filter_6;
wire signed [`WID_FILTER-1:0]	out_filter_7;
wire signed [`WID_FILTER-1:0]	out_filter_8;
wire signed [`WID_FILTER-1:0]	out_filter_9;

wire signed [`WID_LINE-1:0]	out_line_1;
wire signed [`WID_LINE-1:0] 	out_line_2;
wire signed [`WID_LINE-1:0]	out_line_3;
wire signed [`WID_LINE-1:0] 	out_line_4;
wire signed [`WID_LINE-1:0] 	out_line_5;
wire signed [`WID_LINE-1:0] 	out_line_6;
wire signed [`WID_LINE-1:0] 	out_line_7;
wire signed [`WID_LINE-1:0] 	out_line_8;
wire signed [`WID_LINE-1:0] 	out_line_9;




line_buffer line_buffer_module 
(
    .rst				(rst),
    .clk				(clk),
    .shifting			(shifting_line),
    .line_buffer_reset	(line_buffer_reset),
    .inp				(input_line),
    .row_length			(row_length),
    .out1				(out_line_1),
    .out2				(out_line_2),
    .out3				(out_line_3),
    .out4				(out_line_4),
    .out5				(out_line_5),
    .out6				(out_line_6),
    .out7				(out_line_7),
    .out8				(out_line_8),
    .out9				(out_line_9)
); 

filter_buffer filter_buffer_module 
(
    .rst				(rst),
    .clk				(clk),
    .shifting			(shifting_filter),
    .inp				(input_filter),
    .out1				(out_filter_1),
    .out2				(out_filter_2),
    .out3				(out_filter_3),
    .out4				(out_filter_4),
    .out5				(out_filter_5),
    .out6				(out_filter_6),
    .out7				(out_filter_7),
    .out8				(out_filter_8),
    .out9				(out_filter_9)
);

mac mac_module 
(
    .rst				(rst),
    .clk				(clk),
    .enable				(mac_enable),
    .input_filter_1		(out_filter_1),
    .input_filter_2		(out_filter_2),
    .input_filter_3		(out_filter_3),
    .input_filter_4		(out_filter_4),
    .input_filter_5		(out_filter_5),
    .input_filter_6		(out_filter_6),
    .input_filter_7		(out_filter_7),
    .input_filter_8		(out_filter_8),
    .input_filter_9		(out_filter_9),
    .input_line_1		(out_line_1),
    .input_line_2		(out_line_2),
    .input_line_3		(out_line_3),
    .input_line_4		(out_line_4),
    .input_line_5		(out_line_5),
    .input_line_6		(out_line_6),
    .input_line_7		(out_line_7),
    .input_line_8		(out_line_8),
    .input_line_9		(out_line_9),
    .output_mac			(output_mac),
    .regfile            (regfile)
);
endmodule

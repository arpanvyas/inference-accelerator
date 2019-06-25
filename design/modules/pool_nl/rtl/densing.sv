`include "header.vh"
module densing(
    input	                        rst,
    input	                        clk,
    input	                        shifting_line,
    input	                        line_buffer_reset,
    input	[`ADDR_FIFO-1:0]	    row_length,
    input	[`WID_PE_BITS-1:0]      input_line,
    input						    shifting_filter,	
    input	[`WID_FILTER-1:0]	    input_filter,	
    input   [7:0]                   dense_valid,
    output reg	[`WID_PE_BITS-1:0]	out_dense_data,
    interface_regfile               regfile
);




logic signed [`WID_LINE-1:0]	out_line_1;
logic signed [`WID_LINE-1:0] 	out_line_2;
logic signed [`WID_LINE-1:0]	out_line_3;
logic signed [`WID_LINE-1:0] 	out_line_4;
logic signed [`WID_LINE-1:0] 	out_line_5;
logic signed [`WID_LINE-1:0] 	out_line_6;
logic signed [`WID_LINE-1:0] 	out_line_7;
logic signed [`WID_LINE-1:0] 	out_line_8;
logic signed [`WID_LINE-1:0] 	out_line_9;


wire signed [`WID_FILTER-1:0]	out_filter_1, out_filter_clean_1;
wire signed [`WID_FILTER-1:0]	out_filter_2, out_filter_clean_2;
wire signed [`WID_FILTER-1:0]	out_filter_3, out_filter_clean_3;
wire signed [`WID_FILTER-1:0]	out_filter_4, out_filter_clean_4;
wire signed [`WID_FILTER-1:0]	out_filter_5, out_filter_clean_5;
wire signed [`WID_FILTER-1:0]	out_filter_6, out_filter_clean_6;
wire signed [`WID_FILTER-1:0]	out_filter_7, out_filter_clean_7;
wire signed [`WID_FILTER-1:0]	out_filter_8, out_filter_clean_8;
wire signed [`WID_FILTER-1:0]	out_filter_9, out_filter_clean_9;



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

assign out_filter_clean_1 = (dense_valid > 0) ? out_filter_1 : 0;
assign out_filter_clean_2 = (dense_valid > 1) ? out_filter_2 : 0;
assign out_filter_clean_3 = (dense_valid > 2) ? out_filter_3 : 0;
assign out_filter_clean_4 = (dense_valid > 3) ? out_filter_4 : 0;
assign out_filter_clean_5 = (dense_valid > 4) ? out_filter_5 : 0;
assign out_filter_clean_6 = (dense_valid > 5) ? out_filter_6 : 0;
assign out_filter_clean_7 = (dense_valid > 6) ? out_filter_7 : 0;
assign out_filter_clean_8 = (dense_valid > 7) ? out_filter_8 : 0;
assign out_filter_clean_9 = (dense_valid > 8) ? out_filter_9 : 0;


mac mac_module 
(
    .rst				(rst),
    .clk				(clk),
    .enable				(mac_enable),
    .input_filter_1		(out_filter_clean_1),
    .input_filter_2		(out_filter_clean_2),
    .input_filter_3		(out_filter_clean_3),
    .input_filter_4		(out_filter_clean_4),
    .input_filter_5		(out_filter_clean_5),
    .input_filter_6		(out_filter_clean_6),
    .input_filter_7		(out_filter_clean_7),
    .input_filter_8		(out_filter_clean_8),
    .input_filter_9		(out_filter_clean_9),
    .input_line_1		(out_line_1),
    .input_line_2		(out_line_2),
    .input_line_3		(out_line_3),
    .input_line_4		(out_line_4),
    .input_line_5		(out_line_5),
    .input_line_6		(out_line_6),
    .input_line_7		(out_line_7),
    .input_line_8		(out_line_8),
    .input_line_9		(out_line_9),
    .output_mac			(out_dense_data),
    .regfile            (regfile)
);




endmodule


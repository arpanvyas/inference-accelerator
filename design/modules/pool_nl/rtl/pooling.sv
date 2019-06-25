`include "header.vh"
module pooling(
    input	rst,
    input	clk,
    input	shifting_line,
    input	line_buffer_reset,
    input	[`ADDR_FIFO-1:0]	row_length,
    input	[`WID_PE_BITS-1:0]  input_line,
    input	pool_enable,
    input   logic [15:0]    pool_type,    //unused
    input   logic [15:0]    pool_horiz,   //unused
    input   logic [15:0]    pool_vert,    //unused
    output reg	[`WID_PE_BITS-1:0]	out_pool_data,
    interface_regfile               regfile
);


logic signed [`WID_PE_BITS-1:0]	max1,max2;


logic signed [`WID_LINE-1:0]	out_line_1;
logic signed [`WID_LINE-1:0] 	out_line_2;
logic signed [`WID_LINE-1:0]	out_line_3;
logic signed [`WID_LINE-1:0] 	out_line_4;
logic signed [`WID_LINE-1:0] 	out_line_5;
logic signed [`WID_LINE-1:0] 	out_line_6;
logic signed [`WID_LINE-1:0] 	out_line_7;
logic signed [`WID_LINE-1:0] 	out_line_8;
logic signed [`WID_LINE-1:0] 	out_line_9;


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




always@(posedge clk, posedge rst) begin
    if(rst) begin
        out_pool_data <= 0;
    end else begin
        if(pool_enable) begin
            max1			<= (out_line_1>out_line_2) ? out_line_1: out_line_2;
            max2			<= (out_line_3>out_line_4) ? out_line_3: out_line_4;
            out_pool_data	<= (max1>max2) ? max1: max2;
        end
    end
end




endmodule


`timescale 1ns / 1ps
`include "header.vh"

module scrap(
    );
	 
`include "user_tasks.vh"
	 
wire [`N_PE-1:0] hot_str;
wire  [3:0] n1 [`N_PE/2-1:0];
reg signed [4:0] dec;
wire [4:0] n_pe_2;
assign hot_str = 32'b00000000_00000000_00000000_00000100;
always@(*)
begin
hot_to_dec(hot_str,dec);
end 
assign n_pe_2 = `N_PE/2-1;

endmodule

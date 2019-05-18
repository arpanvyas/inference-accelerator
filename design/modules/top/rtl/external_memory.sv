`include "header.vh"
module external_memory(
	input clk,
	input we,
	input re,
	input [23:0] rd_addr,
	input [23:0] wr_addr,
	input [31:0] data_in,
	output[31:0] data_out
    );

reg [31:0] mem[ 2**23 - 1:0];
reg [31:0] data_out;

always@(posedge clk)
begin
	if (we) begin
	data_out <= mem[wr_addr];
	end
	
	if (re) begin
	mem[rd_addr] <= data_in;
	end

end


//Storing Model in RAM
initial
begin
    $readmemh("model.dat",mem,0);
    $readmemh("input.dat",mem,4194304);

end

endmodule

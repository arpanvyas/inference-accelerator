`include "header.vh"
module memory_bank(
	input clk,
	input we,
	input re,
	input [`ADDR_RAM-1:0] rd_addr,
	input [`ADDR_RAM-1:0] wr_addr,
	input [`WID_RAM-1:0] data_in,
	output[`WID_RAM-1:0] data_out
    );

reg [`WID_RAM-1:0] mem[2**`ADDR_RAM-1:0];
reg [`WID_RAM-1:0] data_out;

always@(posedge clk)
begin
	if (re) begin
	data_out <= mem[rd_addr];
	end
	
	if (we) begin
	mem[wr_addr] <= data_in;
	end

end


endmodule

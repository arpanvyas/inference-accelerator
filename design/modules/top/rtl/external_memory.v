`include "header.vh"
module external_memory(
	input clk,
	input we,
	input re,
	input [`ADDR_EXT_RAM-1:0] rd_addr,
	input [`ADDR_EXT_RAM-1:0] wr_addr,
	input [`WID_EXT_RAM-1:0] data_in,
	output[`WID_EXT_RAM-1:0] data_out
    );

reg [`WID_EXT_RAM-1:0] mem[2**`ADDR_EXT_RAM-1:0];
reg [`WID_EXT_RAM-1:0] data_out;

always@(posedge clk)
begin
	if (re) begin
	data_out <= mem[wr_addr];
	end
	
	if (we) begin
	mem[rd_addr] <= data_in;
	end

end


endmodule

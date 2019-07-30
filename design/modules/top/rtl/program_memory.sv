`include "header.vh"
module program_memory(
	input logic clk,
	input logic we,
	input logic re,
	input logic [31:0] rd_addr,
	input logic [31:0] wr_addr,
	input logic [31:0] data_in,
	output logic [31:0] data_out
    );

    logic [31:0] mem[(`PC_MAX*2)-1:0];

always@(posedge clk)
begin
	if (re) begin
	data_out <= #1 mem[rd_addr];
	end
	
	if (we) begin
	mem[wr_addr] <= #1 data_in;
	end

end


//Initializing program memory with the program file generated
initial begin

    $readmemb("program.mac",mem);

end


endmodule

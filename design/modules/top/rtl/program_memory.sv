module program_memory(
	input clk,
	input we,
	input re,
	input [31:0] rd_addr,
	input [31:0] wr_addr,
	input [31:0] data_in,
	output[31:0] data_out
    );

reg [31:0] mem[65535:0];
reg [31:0] data_out;

always@(posedge clk)
begin
	if (re) begin
	data_out <= mem[rd_addr];
	end
	
	if (we) begin
	mem[wr_addr] <= data_in;
	end

end


//Initializing program memory with the program file generated
initial begin

    $readmemb("program.mac",mem);

end


endmodule

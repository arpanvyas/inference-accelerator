`include	"header.vh"
module contr(

	input		rst,
	input		clk,
    input								host_start,
    input	[`ADDR_EXT_RAM-1:0]			ext_ram_start_addr,				
	output reg	[`N_PE-1:0]					mem_r_en,
	output reg	[`ADDR_RAM-1:0]				mem_r_addr,
	input	[`WID_RAM-1:0]				mem_r_data,
	output reg	[`N_PE-1:0]					mem_w_en,
	output reg	[`ADDR_RAM-1:0]				mem_w_addr,
	output reg	[`WID_RAM-1:0]				mem_w_data
	);


reg		start;
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mem_r_addr	<= 0;

		mem_w_en	<= 0;
		mem_w_addr	<= 0;
		mem_w_data	<= 0;		
	end
	else begin
		if(host_start) begin
			start 		<= 1;
			mem_r_addr	<=ext_ram_start_addr;
		end
		if(start) begin
			mem_r_en	<= 1;
			mem_r_addr	<= mem_r_addr+1;
			mem_w_en	<= 1;
			mem_w_addr	<= mem_r_addr;
			mem_w_data	<= mem_r_data;
		end

	end
end
endmodule

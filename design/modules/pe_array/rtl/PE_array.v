`include "header.vh"
module PE_array(
	input									 	rst,
	input									 	clk,
	input									 	shifting_line,
	input 									line_buffer_reset,
	input 		[`ADDR_FIFO-1:0]			row_length,
	input 		[`N_PE-1:0]					shifting_filter,
	input 									mac_enable,	 
	input									adder_enable,
	input									final_filter_bank,
	input		[2:0]						pool_nl,
    input								pool_enable,
    input								shifting_line_pool,
    input								line_buffer_reset_pool,
    input [`ADDR_FIFO-1:0]				row_length_pool,	
	input		[2:0]						nl_type,
    input								nl_enable,	
	input		[`WID_PE_BITS*`N_PE-1:0]	input_bus1_PEA,
	input		[`WID_PE_BITS*`N_PE-1:0]	input_bus2_PEA,
	output	[`WID_PE_BITS*`N_PE-1:0]	output_bus1_PEA
    );
	 
wire	[`WID_PE_BITS-1:0]	output_PE	[`N_PE-1:0];
`PACK_ARRAY(`WID_PE_BITS,`N_PE,output_PE,output_bus1_PEA)

genvar i;
generate for(i=0 ; i<`N_PE ; i=i+1)
begin
PE PE_module
	(
		.rst						(rst),
		.clk						(clk),
		.shifting_line			(shifting_line),
		.line_buffer_reset		(line_buffer_reset),
		.row_length				(row_length),
		.shifting_filter		(shifting_filter[i]),
		.mac_enable				(mac_enable),	
		.adder_enable			(adder_enable),
		.final_filter_bank		(final_filter_bank),
		.pool_nl				(pool_nl),
		.pool_enable			(pool_enable),
		.shifting_line_pool		(shifting_line_pool),
		.line_buffer_reset_pool	(line_buffer_reset_pool),
		.row_length_pool		(row_length_pool),

		.nl_type				(nl_type),
		.nl_enable				(nl_enable),
		.input_bus1_PE			(input_bus1_PEA),
		.input_2_PE				(input_bus2_PEA[i]),
		.output_1_PE			(output_PE[i])
	);
end
endgenerate



endmodule

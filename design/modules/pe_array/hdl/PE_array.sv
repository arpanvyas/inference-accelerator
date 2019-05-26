`include "header.vh"
module PE_array(
	input									 	rst,
	input									 	clk,
    interface_pe_array                          intf_pea
    );
	 
wire	[`WID_PE_BITS-1:0]	output_PE	[`N_PE-1:0];
`PACK_ARRAY(`WID_PE_BITS,`N_PE,output_PE,intf_pea.output_bus1_PEA)

genvar i;
generate for(i=0 ; i<`N_PE ; i=i+1)
begin
PE PE_module
	(
		.rst						(rst),
		.clk						(clk),
		.shifting_line			(intf_pea.shifting_line),
		.line_buffer_reset		(intf_pea.line_buffer_reset),
		.row_length				(intf_pea.row_length),
		.shifting_filter		(intf_pea.shifting_filter[i]),
		.mac_enable				(intf_pea.mac_enable),	
		.adder_enable			(intf_pea.adder_enable),
		.final_filter_bank		(intf_pea.final_filter_bank),
		.pool_nl				(intf_pea.pool_nl),
		.pool_enable			(intf_pea.pool_enable),
		.shifting_line_pool		(intf_pea.shifting_line_pool),
		.line_buffer_reset_pool	(intf_pea.line_buffer_reset_pool),
		.row_length_pool		(intf_pea.row_length_pool),

		.nl_type				(intf_pea.nl_type),
		.nl_enable				(intf_pea.nl_enable),
		.input_bus1_PE			(intf_pea.input_bus1_PEA),
		.input_2_PE				(intf_pea.input_bus2_PEA[i]),
		.output_1_PE			(output_PE[i])
	);
end
endgenerate



endmodule

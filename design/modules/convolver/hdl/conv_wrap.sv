`include "header.vh"
module conv_wrap(
	input							rst,
	input							clk,
	input							shifting_line,
	input							line_buffer_reset,
	input	[`ADDR_FIFO-1:0]	row_length,
	input	[`WID_LINE-1:0]	input_line,
	input							shifting_filter,
	input	[`N_PE-1:0]			input_channels,
	input	[`WID_FILTER-1:0]	input_filter,	
	input							mac_enable,
	output						output_valid
//	output [`N_PE-1:0]		output_mac1

    );

wire [`WID_MAC_OUT-1:0] output_mac [`N_PE-1:0];
reg	[`N_PE-1:0] output_mac1;

reg [`WID_MAC_OUT-1:0] input_channels1 [`N_PE-1:0];
	
genvar i;
generate for(i=0 ; i<`N_PE ; i=i+1)
begin
convolver convolver_module
	(
		.rst						(rst),
		.clk						(clk),
		.shifting_line				(shifting_line),
		.line_buffer_reset			(line_buffer_reset),
		.row_length					(row_length),
		.input_line					(input_channels1[i]),
		.shifting_filter			(shifting_filter),
		.input_filter				(input_channels[i]),
		.mac_enable					(mac_enable),
		.output_mac					(output_mac[i])
	);
end
endgenerate
	
	integer i1;
always@(*) begin
	for(i1=0; i1<`N_PE; i1=i1+1)
	begin
//	output_mac1[i1] <= &output_mac[i1];
	input_channels1[i1] <= input_channels[i1];
	end

end

endmodule 

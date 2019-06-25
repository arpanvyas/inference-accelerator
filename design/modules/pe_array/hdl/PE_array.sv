`include "header.vh"
module PE_array(
    input									 	rst,
    input									 	clk,
    interface_pe_array                          intf_pea
);


genvar i;
generate for(i=0 ; i<`N_PE ; i=i+1)
begin
    PE #(.PE_index(i)) PE_module
    (
        .rst				    (rst),
        .clk					(clk),
        .shifting_line			(intf_pea.shifting_line[i]),
        .shifting_filter		(intf_pea.shifting_filter[i]),
        .mac_enable				(intf_pea.mac_enable[i]),	
        .nl_enable              (intf_pea.nl_enable[i]),
        .feedback_enable        (intf_pea.feedback_enable[i]),

        .line_buffer_reset		(intf_pea.line_buffer_reset),
        .row_length				(intf_pea.row_length),
        .adder_enable			(intf_pea.adder_enable[i]),
        .pool_enable			(intf_pea.pool_enable),
        .pool_type              (intf_pea.pool_type),
        .pool_horiz             (intf_pea.pool_horiz),
        .pool_vert              (intf_pea.pool_vert),

        .dense_enable           (intf_pea.dense_enable),
        .dense_valid            (intf_pea.dense_valid),
        .dense_adder_reset      (intf_pea.dense_adder_reset[i]),
        .dense_adder_on         (intf_pea.dense_adder_on[i]),

        .nl_type				(intf_pea.nl_type),
        .input_bus1_PE			(intf_pea.input_bus1_PEA[`N_PE-1:0]),
        .input_2_PE				(intf_pea.input_bus2_PEA[i]),
        .output_1_PE			(intf_pea.output_bus1_PEA[i])
    );
end
endgenerate

logic   [`WID_PE_BITS-1:0] output_pe_all    [`N_PE-1:0];

always_comb begin
    for(int i = 0; i < `N_PE; i = i + 1 ) begin
        output_pe_all[i] = intf_pea.output_bus1_PEA[i];
    end
end

dense_latch dense_latch_inst (
    .clk(clk),
    .rst(rst),
    .data_in(output_pe_all),
    .dense_latch(intf_pea.dense_latch),
    .rd_addr(intf_pea.dense_rd_addr),
    .data_out(intf_pea.output_bus1_PEA[`N_PE])

);

endmodule
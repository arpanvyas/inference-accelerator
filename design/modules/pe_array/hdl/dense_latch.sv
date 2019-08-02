module dense_latch (

    input   logic clk,
    input   logic rst,
    input   logic   [`WID_PE_BITS-1:0]  data_in [`N_PE-1:0],
    input   logic signed  dense_latch,
    input   logic   [`LOG_N_PE-1:0] rd_addr,
    output  logic   [`WID_PE_BITS-1:0]  data_out
);


logic signed  [`WID_PE_BITS-1 : 0 ]  data_latched    [`N_PE-1:0];

always_ff@(posedge clk, posedge rst)
begin
    if(rst) begin
        for(int i = 0; i < `N_PE; i = i + 1) begin
            data_latched[i] <= #1 0;
        end

    end else begin
        if(dense_latch) begin
            for(int i = 0; i < `N_PE; i = i + 1) begin
                data_latched[i] <= #1 data_in[i];
            end
        end //if(dense_latch)

    end //if(rst)

end


always_comb begin
    data_out = data_latched[rd_addr];
end





endmodule

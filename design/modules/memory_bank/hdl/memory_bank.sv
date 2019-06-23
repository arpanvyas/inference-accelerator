`include "header.vh"
module memory_bank(
    input logic clk,
    input logic we,
    input logic re,
    input logic [`ADDR_RAM-1:0] rd_addr,
    input logic [`ADDR_RAM-1:0] wr_addr,
    input logic [`WID_RAM-1:0] data_in,
    output logic [`WID_RAM-1:0] data_out
);

logic [`WID_RAM-1:0] mem[2**`ADDR_RAM-1:0];

always@(posedge clk)
begin
    if (re) begin
        data_out <= #1 mem[rd_addr];
    end

    if (we) begin
        mem[wr_addr] <= #1 data_in;
    end

end


endmodule

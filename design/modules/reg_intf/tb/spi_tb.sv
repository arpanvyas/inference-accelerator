`include "spi_interface.sv"
`include "spi_test.sv"

module spi_tb;

logic   clk;
logic   rst;

always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;
end

intf    i_intf();
assign i_intf.clk = clk;
assign i_intf.rst = rst;

test    t1(i_intf);

reg_intf DUT (
    .clk(i_intf.clk),
    .rst(i_intf.rst),
    .SCLK(i_intf.SCLK),
    .SS(i_intf.SS),
    .MOSI(i_intf.MOSI),
    .MISO(i_intf.MISO)
);

endmodule

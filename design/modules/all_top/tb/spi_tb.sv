`include "spi_interface.sv"
`include "spi_test.sv"

`timescale 1ns/1ps
module spi_tb;

logic   clk;
logic   rst;

`ifndef DDR_SPEED_SIM 
always #5 clk = ~clk;
`else
real memory_clock_period;
assign memory_clock_period = ( `DATA_EXT_RAM/(8*6.4) );
reg high_speed_clk;
real half_clock;
//typedef enum { IDLE, MEM_LOAD, MEM_SAVE, COMPUTATION} ControllerStates;
//ControllerStates state;
wire [1:0] state;
assign state = DUT.inference_accelerator_inst.controller_inst.state;

always@(state) begin
	//if(state == 2'b00 || state == 2'b01 || state == 2'b10) begin
	if( state == 2'b01 || state == 2'b10) begin
		high_speed_clk = 1;
		half_clock = memory_clock_period/2;
	end else begin
		high_speed_clk = 0;
		half_clock = 5;
	end
end

always #half_clock clk = ~clk;


`endif

initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;
end

intf    i_intf();
assign i_intf.clk = clk;
assign i_intf.rst = rst;

test    t1(i_intf);

host DUT (
    .clk(i_intf.clk),
    .rst(i_intf.rst)
);

endmodule

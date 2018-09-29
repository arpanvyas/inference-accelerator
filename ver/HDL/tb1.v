`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:27:02 10/27/2017
// Design Name:   output_buffer
// Module Name:   /home/arpan/Desktop/Inference Accelerator/HDL Model/InferenceAccelerator/tb1.v
// Project Name:  InferenceAccelerator
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: output_buffer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module tb1;

	// Inputs
	reg rst;
	reg clk;
	reg loading_ext_mem;
	reg data_ext_mem;
	reg [5:0] memory_bank_index;
	reg [15:0] memory_bank_address;
	reg loading_PEA;
	reg calc_PEA;
	reg [511:0] input_bus;
	reg [511:0] output_bus;

	// Instantiate the Unit Under Test (UUT)
	output_buffer uut (
		.rst(rst), 
		.clk(clk), 
		.loading_ext_mem(loading_ext_mem), 
		.data_ext_mem(data_ext_mem), 
		.memory_bank_index(memory_bank_index), 
		.memory_bank_address(memory_bank_address), 
		.loading_PEA(loading_PEA), 
		.calc_PEA(calc_PEA), 
		.input_bus(input_bus), 
		.output_bus(output_bus)
	);

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;
		loading_ext_mem = 0;
		data_ext_mem = 0;
		memory_bank_index = 0;
		memory_bank_address = 0;
		loading_PEA = 0;
		calc_PEA = 0;
		input_bus = 0;
		output_bus = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
      
endmodule


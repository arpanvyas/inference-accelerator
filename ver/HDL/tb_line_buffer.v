`timescale 1ns / 1ps

module line_buffer_tb;

	// Inputs
	reg clk;
	reg rst;
	reg[7:0] row_length;
	reg shifting;
	reg fifo_reset;
	reg[15:0] wr_data_i;

	// Outputs
	wire[15:0] rd_data_o;

	// Instantiate the Unit Under Test (UUT)
	line_fifo uut (
		.clk(clk), 
		.rst(rst), 
		.row_length(row_length), 
		.shifting(shifting), 
		.fifo_reset(fifo_reset), 
		.wr_data_i(wr_data_i), 
		.rd_data_o(rd_data_o)
	);

	initial begin
		// Initialize Inputs
		clk = 1;
		rst = 1;
		row_length = 0;
		shifting = 0;
		fifo_reset = 1;
		wr_data_i = 0;

		// Wait 100 ns for global reset to finish
		@(posedge clk);
		rst = 0;
		row_length = 10;
		@(posedge clk);
        
        fifo_reset = 0;
        row_length = 10;
        wr_data_i = 20;
        @(posedge clk);
        shifting = 1;

		// Add stimulus here

		repeat(50) begin
			wr_data_i = wr_data_i + 1;
			@(posedge clk);
		end
		wr_data_i = 100;

		shifting = 1;


	end
      

	always
		#5 clk = !clk;

endmodule


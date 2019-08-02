`include "header.vh"
module fifo_memory
   (
    input							clk,
    input		[`ADDR_FIFO-1:0]	raddr,
    input							re,
    input		[`ADDR_FIFO-1:0] waddr,
    input							we,
    input		[`WID_FIFO-1:0]	din,
    output reg	[`WID_FIFO-1:0]	dout
    );

   reg [`WID_FIFO-1:0]     mem[`DEP_FIFO-1:0];

	integer k;
	initial
	begin
		for (k = 0; k < `DEP_FIFO - 1; k = k + 1)
		begin
		mem[k] = 0;
		end

//		mem = 0;
	end

   always @(posedge clk) begin
		if (we)
			mem[waddr] <= #1 din;
		if (re)
			dout <= #1 mem[raddr];
	end

endmodule

`include "header.vh"

//To pass the row length, rst should be 0, fifo_rst should be 1
//Now make fifo_rst 0 and send in the data sequentially


module line_fifo
   (
    input							clk,
    input							rst,
	 input	[`ADDR_FIFO-1:0]	row_length,

    input							shifting,	//1 denotes data-shifting is going on
	 input							fifo_reset,	//1 denotes get it set for a new image
    input	[`WID_FIFO-1:0]	wr_data_i,


    output	[`WID_FIFO-1:0]	rd_data_o

    );
	 
	 
   reg [`ADDR_FIFO-1:0] 			write_pointer;
	reg [`ADDR_FIFO-1:0]				elements_inside;
	reg [`ADDR_FIFO-1:0]				row_length_h;
   wire [`ADDR_FIFO-1:0] 			read_pointer;
	wire									wr_en;
	

//   wire	empty_int		=		(write_pointer[ADDR_FIFO]		==	read_pointer[ADDR_FIFO]);
//   wire	full_or_empty	=		(write_pointer[ADDR_FIFO-1:0]	==	read_pointer[ADDR_FIFO-1:0]);
//   
//   assign full_o  = full_or_empty & !empty_int;
//   assign empty_o = full_or_empty & empty_int;
//   
always @(posedge clk, posedge rst) begin
	if (rst) begin
		write_pointer <= 0;
		elements_inside	<= 0;
		row_length_h		<= 0;
	end else begin
		
	if(!fifo_reset) begin
	

		if (shifting) begin
			
			if (elements_inside != row_length_h) begin
				write_pointer <= write_pointer + 1'd1;
				elements_inside <= elements_inside + 1'd1;
			end else	if(elements_inside == row_length_h) begin
				elements_inside <= elements_inside;
				
				if(write_pointer != elements_inside) begin
					write_pointer <= write_pointer + 1'd1;
				end else if (write_pointer == elements_inside) begin
					write_pointer <= 0;
				end				
			end 
			
		end else begin
				elements_inside <= elements_inside;
				write_pointer 	 <= write_pointer;
		end

		
	end else if (fifo_reset) begin
		elements_inside	<= 0;
		write_pointer		<= 0;
		if(row_length>2) begin    //making a difference of 2 as otherwise the data on output comes 2 clocks late because of bad logic
			row_length_h		<= row_length-2;
		end else begin
			row_length_h	<= 1;
		end
	end

	end
end	
	

		


		

	
	assign read_pointer = write_pointer;
	assign wr_en = shifting & !fifo_reset;
	
   fifo_memory fifo_ram_module
     (
		.clk			(clk),
		.dout			(rd_data_o),
		.raddr		(read_pointer),
		.re			(1'b1),
		.waddr		(write_pointer),
		.we			(wr_en),
		.din			(wr_data_i)
		);

endmodule

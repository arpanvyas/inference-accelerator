`timescale 1ns / 1ps
`include "header.vh"

module tb_convolver1;

	// Inputs
	reg rst;
	reg clk;
	reg shifting_line;
	reg line_buffer_reset;
	reg [`ADDR_FIFO-1:0] row_length;
	reg [15:0] input_line;
	reg shifting_filter;
	reg [15:0] input_filter;
	reg mac_enable;

	// Outputs
	wire [35:0] output_mac;

	// Instantiate the Unit Under Test (UUT)
	convolver uut (
		.rst(rst), 
		.clk(clk), 
		.shifting_line(shifting_line), 
		.line_buffer_reset(line_buffer_reset), 
		.row_length(row_length), 
		.input_line(input_line), 
		.shifting_filter(shifting_filter), 
		.input_filter(input_filter), 
		.mac_enable(mac_enable), 
		.output_mac(output_mac)
	);

	integer file_im_in, file_flt, file_im_out,file_im_in_ou,f1,f2,f3,f4;
	integer i1,im_in_h,im_in_w;
	reg [`WID_PE_BITS-1:0] flt_in, im_in, im_out;

		initial begin
		im_in_h = 400;
		im_in_w = 400;
		// Initialize Inputs
		rst = 1;
		clk = 1;
		shifting_line = 0;
		line_buffer_reset = 1;
		row_length = im_in_h-3;
		input_line = 0;
		shifting_filter = 0;
		input_filter = 0;
		mac_enable = 0;

		file_im_in = $fopen("../python test files/1input_image.bin","r");
		file_flt = $fopen("../python test files/1input_filter.bin","r");
		file_im_out = $fopen("../python test files/1output_image_ver.bin","w");
		file_im_in_ou = $fopen("../python test files/1input_image_ver.bin","w");
		i1 = 0;

		repeat(10) @(posedge clk);
		rst <= 0;
		@(posedge clk);

	
		fork
			
			begin //sending in the filter
			shifting_filter = 1;
			  	
				repeat(9) begin 
					f1 = $fscanf(file_flt,"%b\n",input_filter);
					@(posedge clk);
				end
			shifting_filter = 0;
			end

			begin //sending in the image
			shifting_line = 1;
			line_buffer_reset = 0;
				repeat((im_in_w)*(im_in_w)) begin 
					f2 = $fscanf(file_im_in,"%b\n",input_line);
					@(posedge clk);
				end
			input_line = 0;
			end

			begin //mac enable
				repeat(im_in_h+im_in_h+4)	@(posedge clk);
				mac_enable = 1;
				repeat((im_in_w)*(im_in_w))	@(posedge clk);
				mac_enable = 0;
				shifting_line = 0;
			end


			begin
				repeat((im_in_h+im_in_h+4+1+3-1))	@(posedge clk);
			repeat((im_in_w)*(im_in_w)) begin //logging out the output
				
				i1 = i1+1;
				if(i1 <= im_in_w-2 ) begin
					$fwrite(file_im_out,"%b\n",output_mac);
				end else if(i1==im_in_w) begin
					i1 = 0;
				end
				@(posedge clk);

			end

			end

			begin
				
				repeat(20000) begin
				$fwrite(file_im_in_ou,"%b\n",uut.out_line_3);
				@(posedge clk);					
				end
		
			end
	
		join

		$fclose(file_im_in);
		$fclose(file_flt);
		$fclose(file_im_out);
		$fclose(file_im_in_ou);

	end
	
	
	always
	begin
		#5;
		clk		<= !clk;
	end
	


      
endmodule


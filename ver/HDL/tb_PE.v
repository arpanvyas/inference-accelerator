`timescale 1ns / 1ps
`include "header.vh"
module tb_PE;

	// Inputs
	reg rst;
	reg clk;
	reg shifting_line;
	reg line_buffer_reset;
	reg row_length;
	reg shifting_filter;
	reg mac_enable;
	reg adder_enable;
	reg final_filter_bank;
	reg [2:0] pool_nl;
	reg pool_enable;
	reg shifting_line_pool;
	reg line_buffer_reset_pool;
	reg row_length_pool;
	reg [2:0] nl_type;
	reg nl_enable;
    wire [`WID_PE_BITS*`N_PE-1:0]		input_bus1_PE,	//line inputs to all the convolvers = 32*16b
    reg	[`WID_PE_BITS-1:0]			input_2_PE,		//feedback input for the Single PE
    reg	[`WID_PE_BITS:0]				output_1_PE		//Single PE output

    `PACK_ARRAY(`WID_PE_BITS,`N_PE,input_bus1_PE_unpack,input_bus1_PE)
    reg		[`WID_PE_BITS-1:0]	input_bus1_PE_unpack[`N_PE-1:0];

	// Instantiate the Unit Under Test (UUT)
	PE uut (
		.rst(rst), 
		.clk(clk), 
		.shifting_line(shifting_line), 
		.line_buffer_reset(line_buffer_reset), 
		.row_length(row_length), 
		.shifting_filter(shifting_filter), 
		.mac_enable(mac_enable), 
		.adder_enable(adder_enable), 
		.final_filter_bank(final_filter_bank), 
		.pool_nl(pool_nl), 
		.pool_enable(pool_enable), 
		.shifting_line_pool(shifting_line_pool), 
		.line_buffer_reset_pool(line_buffer_reset_pool), 
		.row_length_pool(row_length_pool), 
		.nl_type(nl_type), 
		.nl_enable(nl_enable)
		.input_bus1_PE			(input_bus1_PEA),
		.input_2_PE				(input_bus2_PEA),
		.output_1_PE			(output_PE)
	);

	integer i1,im0,im1,im2,im3,im4,im5,fl0,fl1,fl2,fl3,fl4,fl5,oim;
	integer a10,a1,a2,a3,a4,a5,b0,b1,b2,b3,b4,b5;

	initial begin
		// Initialize Inputs
		rst = 0;
		clk = 0;
		shifting_line = 0;
		line_buffer_reset = 0;
		row_length = 0;
		shifting_filter = 0;
		mac_enable = 0;
		adder_enable = 0;
		final_filter_bank = 0;
		pool_nl = 0;
		pool_enable = 0;
		shifting_line_pool = 0;
		line_buffer_reset_pool = 0;
		row_length_pool = 0;
		nl_type = 0;
		nl_enable = 0;

		im0 = $fopen("../python test files/pe_input_image0.bin","r");
		im1 = $fopen("../python test files/pe_input_image1.bin","r");
		im2 = $fopen("../python test files/pe_input_image2.bin","r");
		im3 = $fopen("../python test files/pe_input_image3.bin","r");
		im4 = $fopen("../python test files/pe_input_image4.bin","r");
		im5 = $fopen("../python test files/pe_input_image5.bin","r");
		
		fl0 = $fopen("../python test files/pe_input_filter0.bin","r");
		fl1 = $fopen("../python test files/pe_input_filter1.bin","r");
		fl2 = $fopen("../python test files/pe_input_filter2.bin","r");
		fl3 = $fopen("../python test files/pe_input_filter3.bin","r");
		fl4 = $fopen("../python test files/pe_input_filter4.bin","r");
		fl5 = $fopen("../python test files/pe_input_filter5.bin","r");


		oim = $fopen("../python test files/pea_output_image_ver.bin","w");
		i1 = 0;
		im_in_h = 400;
		im_in_w = 400;
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
				repeat(im_in_w+im_in_w+1)	@(posedge clk);
				mac_enable = 1;
				repeat((im_in_w)*(im_in_w))	@(posedge clk);
				mac_enable = 0;
				shifting_line = 0;
			end


			begin
				repeat((im_in_w+im_in_w+1+3-1))	@(posedge clk);
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

	
		join

	end


	always
	begin
		#5;
		clk		<= !clk;
	end
	
      
endmodule


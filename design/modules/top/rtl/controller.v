`include "header.vh"
module controller(
    input	rst,
    input	clk,

//External Memory
	output	reg	mem_r_en,
	output	reg	[`ADDR_EXT_RAM-1:0]	mem_r_addr,
	input		[`DATA_EXT_RAM-1:0]	mem_r_data,
	output	reg	mem_w_en,
	output	reg	[`ADDR_EXT_RAM-1:0] mem_w_addr,
	output	reg	[`DATA_EXT_RAM-1:0] mem_w_data,

//Host
	input										host_start,
   	input			[`ADDR_EXT_RAM-1:0]			ext_ram_start_addr,
   	output	reg		[`CONTR_STATES_BITS-1:0]	state,
   	output	reg									done,

//PE Array signals
	output	reg									pea_shifting_line;
	output	reg									pea_line_buffer_reset;
	output 	reg		[`ADDR_FIFO-1:0]			pea_row_length;
	output	reg		[`N_PE-1:0]					pea_shifting_filter;
	output	reg 								pea_mac_enable;
	output	reg									pea_adder_enable;
	output	reg									pea_final_filter_bank;
	output	reg		[2:0]						pea_pool_nl;
	output	reg									pea_pool_enable;
	output	reg									pea_shifting_line_pool;
	output	reg									pea_line_buffer_reset_pool;
	output	reg		[`ADDR_FIFO-1:0]			pea_row_length_pool;
	output	reg		[2:0]						pea_nl_type;
	output	reg									pea_nl_enable;	
	output	reg		[`WID_PE_BITS*`N_PE-1:0]	pea_input_bus1_PEA,
	output	reg		[`WID_PE_BITS*`N_PE-1:0]	pea_input_bus2_PEA,
	input			[`WID_PE_BITS*`N_PE-1:0]	pea_output_bus1_PEA,

//First Buffer
	output	reg		[1:0]						f_mode,
	output	reg		[`N_PE-1:0]					f_m0_r_en,
	output	reg		[`ADDR_RAM-1:0]				f_m0_r_addr,
	input			[`WID_RAM-1:0]				f_m0_r_data,
	output	reg		[`N_PE-1:0]					f_m0_w_en,
	output	reg		[`ADDR_RAM-1:0]				f_m0_w_addr,
	output	reg		[`WID_RAM-1:0]				f_m0_w_data,
	
	output	reg									f_m1_r_en,
	output	reg		[`ADDR_RAM-1:0]				f_m1_r_addr,
   	input			[`WID_PE_BITS*`N_PE-1:0]	f_m1_output_bus,
	output	reg									f_m1_w_en,
	output	reg		[`ADDR_RAM-1:0]				f_m1_w_addr,
   	output	reg		[`WID_PE_BITS*`N_PE-1:0]	f_m1_input_bus,

//second buffer 
	output		reg	[1:0]						s_mode,
	output		reg	[`N_PE-1:0]					s_m0_r_en,
	output		reg	[`ADDR_RAM-1:0]				s_m0_r_addr,
	input			[`WID_RAM-1:0]				s_m0_r_data,
	output		reg	[`N_PE-1:0]					s_m0_w_en,
	output		reg	[`ADDR_RAM-1:0]				s_m0_w_addr,
	output		reg	[`WID_RAM-1:0]				s_m0_w_data,
	
	output		reg								s_m1_r_en,
	output		reg	[`ADDR_RAM-1:0]				s_m1_r_addr,
   	input			[`WID_PE_BITS*`N_PE-1:0]	s_m1_output_bus,
	output		reg								s_m1_w_en,
	output		reg	[`ADDR_RAM-1:0]				s_m1_w_addr,
   	output		reg	[`WID_PE_BITS*`N_PE-1:0]	s_m1_input_bus

);


reg [`WID_RAM-1:0] 			reg_bank [`REG_BANK_SIZE-1:0];
reg	[`DATA_WIDTH-1:0]			param_reader;
localparam	[5:0]	flip			= 6'd0, //status of the flip
					c_or_fc			= 6'd15,
						l_conv		= 6'd13,//number of current layer
						l_fc			= 6'd16,

					N_layers_conv	= 6'd1, //number of layers, rename(Ln)
					N_layers_fc		= 6'd2,


					f_num			= 6'd2, //number of filters for the layer, rename(fn)
					f_num_sif		= 6'd14,//Smallest_Integer_Fn(fn/32)
					ch_num			= 6'd3, //the number of channels for the layer, rename(ic)
					ch_num_sif		= 6'd4, //channels of filter per bank = channels of image per bank = Smallest_Integer_Fn(ic/32), rename(CN)
					i_wid			= 6'd5, //the row size of the image, rename(Iw)
					i_out_wid	 	= 40,
					i_out_hei		= 41,
					i_out_siz		= 42,
					i_hei			= 6'd6, //the column size of the image, rename(Ih)
					i_siz			= 6'd7,  //the size of the image for the current layer = Iw*Ih
					f_siz			= 6'd8,	//size of the convolution filter = 3*3
					f_one_per_bank	= 6'd9,	//the size of the filter in the bank for the current layer = CN*Fc
					if_partition	= 6'd10,	//the partition in the memory bank for images and filters, rename(IF_PARTI)
					i_per_bank		= 6'd11,	//partition of bank occupied by images = CN*IC, rename(IMAGES)
					f_all_per_bank	= 6'd12,	//partition of bank occupied by filters = Fn*CN*Fc, rename(FILTERS)
					
					fc_i_ch			= 44,
					fc_i_ch_siz		= 43,
					fc_i_out_ch		= 45,
					fc_i_out_ch_siz = 46,
					fc_i_out_nu		= 47,


					i_index_filter			= 33,//index for mem to buf 
					j_index_channel			= 34,//index for mem to buf
					j_index_one_ch  		= 37,
					buf_flt_load_index		= 38,
					pea_flt_load_index		= 39,
					i_index_channel_bank	= 35,//index for buf to pea
					j_index_filter_bank		= 36,//index for buf to pea

					f_index_inp_ch			= 50,
					f_index_inp_ch_siz		= 51,
					f_index_out_ch			= 52,
					f_index_out_ch_siz		= 53,
					f_index_out_nu			= 54;


reg [5:0] state,prev_state;
localparam	[5:0]	idle										=	0,
					initial_param_load							=	1,
					convolution									=	2,
						individual_layer						=	3,
							load_param_layer					=	4,
							load_con_mem_buf_flt_all			=	5,
								load_con_mem_buf_flt_single		=	6,
							load_con_mem_buf_img_all			=	7,
								load_con_mem_buf_img_single		=	8,
								load_con_buf_pea_flt_single		=	10,
							calc_con_channel_bank_loop			=	11,
								calc_con_filter_bank			=	20,
									load_con_buf_pea_flt_bank	=	9,
									calc_con_filter_bank_loop		=	12,
					fully_connected								=	14,
						load_fc_mem_buf_flt_single				=	15,
						load_fc_mem_buf_flt_all					=	16,
						calc_fc									=	17,
						individual_layer_fc						=	20,
						fc_single_op_nu							=	21,

					stor_buf_mem_img_single						=	18,
					stor_buf_mem_img_all						=	19;

					

//input buffer 
	reg	[1:0]						i_mode;
	reg	[`N_PE-1:0]					i_m0_r_en;
	reg	[`ADDR_RAM-1:0]				i_m0_r_addr;
	reg[`WID_RAM-1:0]				i_m0_r_data;
	reg	[`N_PE-1:0]					i_m0_w_en;
	reg	[`ADDR_RAM-1:0]				i_m0_w_addr;
	reg	[`WID_RAM-1:0]				i_m0_w_data;
	reg								i_m1_r_en;
	reg	[`ADDR_RAM-1:0]				i_m1_r_addr;
    reg[`WID_PE_BITS*`N_PE-1:0]		i_m1_output_bus;
	reg								i_m1_w_en;
	reg	[`ADDR_RAM-1:0]				i_m1_w_addr;
	reg	[`WID_PE_BITS*`N_PE-1:0] 	i_m1_input_bus;

//output buffer 
	reg	[1:0]						o_mode;
	reg	[`N_PE-1:0]					o_m0_r_en;
	reg	[`ADDR_RAM-1:0]				o_m0_r_addr;
	reg[`WID_RAM-1:0]				o_m0_r_data;
	reg	[`N_PE-1:0]					o_m0_w_en;
	reg	[`ADDR_RAM-1:0]				o_m0_w_addr;
	reg	[`WID_RAM-1:0]				o_m0_w_data;
	reg								o_m1_r_en;
	reg	[`ADDR_RAM-1:0]				o_m1_r_addr;
    reg[`WID_PE_BITS*`N_PE-1:0]		o_m1_output_bus;
	reg								o_m1_w_en;
	reg	[`ADDR_RAM-1:0]				o_m1_w_addr;
	reg	[`WID_PE_BITS*`N_PE-1:0] 	o_m1_input_bus;

//The Flip mechanism
always@(*)
begin
	case(reg_bank[flip])

		1:			begin
		s_mode 			=	i_mode;
		s_m0_r_en		=	i_m0_r_en;
		s_m0_r_addr		=	i_m0_r_addr;
		i_m0_r_data		=	s_m0_r_data;
		s_m0_w_en		=	i_m0_w_en;
		s_m0_w_addr		=	i_m0_w_addr;
		s_m0_w_data		=	i_m0_w_data;
		s_m1_r_en		=	i_m1_r_en;
		s_m1_r_addr		=	i_m1_r_addr;
		i_m1_output_bus	=	s_m1_output_bus;
		s_m1_w_en		=	i_m1_w_en;
		s_m1_w_addr		=	i_m1_w_addr;
		s_m1_input_bus	=	i_m1_input_bus;

		f_mode 			=	o_mode;
		f_m0_r_en		=	o_m0_r_en;
		f_m0_r_addr		=	o_m0_r_addr;
		o_m0_r_data		=	f_m0_r_data;
		f_m0_w_en		=	o_m0_w_en;
		f_m0_w_addr		=	o_m0_w_addr;
		f_m0_w_data		=	o_m0_w_data;
		f_m1_r_en		=	o_m1_r_en;
		f_m1_r_addr		=	o_m1_r_addr;
		o_m1_output_bus	=	f_m1_output_bus;
		f_m1_w_en		=	o_m1_w_en;
		f_m1_w_addr		=	o_m1_w_addr;
		f_m1_input_bus	=	o_m1_input_bus;
		end

		default:	begin
		f_mode 			=	i_mode;
		f_m0_r_en		=	i_m0_r_en;
		f_m0_r_addr		=	i_m0_r_addr;
		i_m0_r_data		=	f_m0_r_data;
		f_m0_w_en		=	i_m0_w_en;
		f_m0_w_addr		=	i_m0_w_addr;
		f_m0_w_data		=	i_m0_w_data;
		f_m1_r_en		=	i_m1_r_en;
		f_m1_r_addr		=	i_m1_r_addr;
		i_m1_output_bus	=	f_m1_output_bus;
		f_m1_w_en		=	i_m1_w_en;
		f_m1_w_addr		=	i_m1_w_addr;
		f_m1_input_bus	=	i_m1_input_bus;

		s_mode 			=	o_mode;
		s_m0_r_en		=	o_m0_r_en;
		s_m0_r_addr		=	o_m0_r_addr;
		o_m0_r_data		=	o_m0_r_data;
		s_m0_w_en		=	o_m0_w_en;
		s_m0_w_addr		=	o_m0_w_addr;
		s_m0_w_data		=	o_m0_w_data;
		s_m1_r_en		=	o_m1_r_en;
		s_m1_r_addr		=	o_m1_r_addr;
		o_m1_output_bus	=	s_m1_output_bus;
		s_m1_w_en		=	o_m1_w_en;
		s_m1_w_addr		=	o_m1_w_addr;
		s_m1_input_bus	=	o_m1_input_bus;	
		end

	endcase
end

integer i1;
always@(posedge clk, posedge rst)
begin
	if(rst) begin
		state 				<= idle;
		param_reader		<= 0;
		for(i1=0;i1<`REG_BANK_SIZE;i1=i1+1) begin
			reg_bank[i1] <= 0;
		end

	end else begin
		case(state)
		
			idle : begin
				if(host_start) begin
					state			<=	initial_param_load;
				end else begin
					state	<= idle;
				end

			end

			initial_param_load : begin

				if(prev_state!=state) begin
					mem_r_en		<=	1;
					mem_r_addr		<=	ext_ram_start_addr;
					param_reader	<=	N_layers_conv;	
				end else begin
					if(param_reader<N_layers_fc+1) begin
						reg_bank[param_reader]	<= mem_r_data;
						param_reader			<= param_reader + 1;
						mem_r_addr				<= mem_r_addr	+ 1;
					end	else begin
						mem_r_en				<= 0;
						state					<= convolution;
					end
				end
			
			end

			convolution : begin

				if(state!=prev_state) begin
					if(reg_bank[N_layers_conv]>reg_bank[l_conv]) begin
						state				<= individual_layer;
						reg_bank[c_or_fc]	<= 1;
					end else begin
						state				<= fully_connected;
						reg_bank[l_conv]	<= 0;	//reset in the parent, increase in itself
					end					
				end else begin
					state					<= idle; //some error, go back!
				end

			end
			
			individual_layer : begin
				if(state!=prev_state) begin
					reg_bank[l_conv]	<= reg_bank[l_conv]+1;	//increase in itself, reset in the parent
					state				<= load_param_layer;
				end else begin
					state				<= idle; //some error, go back
				end
			end
			
			load_param_layer : begin
				
				if(state!=prev_state) begin
					param_reader			<= f_num;
					mem_r_en				<= 1;
				end else begin
					if(param_reader<f_all_per_bank+1) begin
						reg_bank[param_reader]	<= mem_r_data;
						param_reader			<= param_reader + 1;
						mem_r_addr				<= mem_r_addr	+ 1;
					end else begin
						mem_r_en				<= 0;
						state					<= load_con_mem_buf_flt_all;
					end
				end

			end
			
			load_con_mem_buf_flt_all: begin
			
				if(state!=prev_state) begin
					if(reg_bank[f_num]>reg_bank[i_index_filter]) begin
						state				<=	load_con_mem_buf_flt_single;
						i_m0_w_en			<=	0;
						connect_mem_r_buf_w <=	1;
					end else begin
						if(reg_bank[l_conv]>1) begin
							state							<= calc_con_channel_bank_loop;
						end else begin
							state							<= load_con_mem_buf_img_all;
						end
							reg_bank[i_index_filter]		<= 0;							// reset in the parent
					end
				end else begin
						state				<= idle;
				end
			end

			load_con_mem_buf_flt_single: begin

				if(state!=prev_state) begin
					reg_bank[i_index_filter] 	 <= reg_bank[i_index_filter] + 1;	//increase in itself
					reg_bank[buf_flt_load_index] <= reg_bank[if_partition] + 9*(reg_bank[i_index_filter])*reg_bank[ch_num_sif];//fixed for a filter
					mem_r_en			   	 	 <= 1;
					mem_r_addr					 <= mem_r_addr;

				end else begin

					if(reg_bank[j_index_channel]<reg_bank[ch_num]) begin

						if(reg_bank[j_index_one_ch]==0) begin
							i_m0_w_addr				 	 				<= reg_bank[buf_flt_load_index]+9*(reg_bank[j_index_channel]>>5);
							i_m0_w_en[reg_bank[j_index_channel][4:0]]	<= 1;
							i_m0_w_en[reg_bank[j_index_channel][4:0]-1]	<= 0;
							mem_r_addr					 				<= mem_r_addr + 1;
						end else if(reg_bank[j_index_one_ch]<8) begin
							reg_bank[j_index_one_ch] 	 				<= reg_bank[j_index_one_ch]+1;
							i_m0_w_addr									<= i_m0_w_addr + 1;
							mem_r_addr									<= mem_r_addr + 1;							
						end else begin
							reg_bank[j_index_one_ch] 	 				<= 0;
							reg_bank[j_index_channel]					<= reg_bank[j_index_channel]+1;
							i_m0_w_addr									<= i_m0_w_addr + 1;		
							mem_r_addr					 				<= mem_r_addr + 1;												
						end
					end else begin
						reg_bank[j_index_channel]						<= 0;
						i_m0_w_en										<= 0;
						state											<= load_con_mem_buf_flt_all;
					end
				end
			
			end
			

			load_con_mem_buf_img_all: begin//all channels of the image
				
				if(state!=prev_state) begin
					reg_bank[buf_flt_load_index] <= 0;
					mem_r_en			   	 	 <= 1;
					mem_r_addr					 <= mem_r_addr;

				end else begin

					if(reg_bank[j_index_channel]<reg_bank[ch_num]) begin

						if(reg_bank[j_index_one_ch]==0) begin
							i_m0_w_addr				 	 				<= reg_bank[buf_flt_load_index]+reg_bank[i_siz]*(reg_bank[j_index_channel]>>5);
							i_m0_w_en[reg_bank[j_index_channel][4:0]]	<= 1;
							i_m0_w_en[reg_bank[j_index_channel][4:0]-1]	<= 0;
							mem_r_addr					 				<= mem_r_addr + 1;
						end else if(reg_bank[j_index_one_ch]<reg_bank[i_siz]-1) begin
							reg_bank[j_index_one_ch] 	 				<= reg_bank[j_index_one_ch]+1;
							i_m0_w_addr									<= i_m0_w_addr + 1;
							mem_r_addr									<= mem_r_addr + 1;							
						end else begin
							reg_bank[j_index_one_ch] 	 				<= 0;
							reg_bank[j_index_channel]					<= reg_bank[j_index_channel]+1;
							i_m0_w_addr									<= i_m0_w_addr + 1;		
							mem_r_addr					 				<= mem_r_addr + 1;												
						end
					end else begin
						reg_bank[j_index_channel]						<= 0;
						i_m0_w_en										<= 0;
						state											<= calc_con_channel_bank_loop;
					end
				end
			
			end

			calc_con_channel_bank_loop : begin

				if(state!=prev_state) begin
					if(reg_bank[ch_num_sif]>reg_bank[i_index_channel_bank]) begin
						reg_bank[i_index_channel_bank]	<= reg_bank[i_index_channel_bank] + 1;//1 to ch_num_sif
						state							<= calc_con_filter_bank_loop;
					end else begin
						reg_bank[i_index_channel_bank]		<= 0;					
						state								<= convolution;
					end

				end else begin
						state				<= idle;
				end

			end

			calc_con_filter_bank_loop : begin
				
				if(state!=prev_state) begin
					if(reg_bank[f_num_sif]>reg_bank[j_index_filter_bank]) begin
						reg_bank[j_index_filter_bank]	<= reg_bank[j_index_filter_bank] + 1;//1 to f_num_sif
						reg_bank[pea_flt_load_index]	<= 9*(reg_bank[i_index_channel_bank]-1)+9*32*reg_bank[ch_num_sif]*reg_bank[j_index_filter_bank];						
						state							<= load_con_buf_pea_flt_bank;
					end else begin
						reg_bank[j_index_filter_bank]	<= 0;
						state							<= calc_con_channel_bank_loop;
					end
				end else begin
						state				<= idle;
				end
			end
			
			load_con_buf_pea_flt_bank : begin

				if(state!=prev_state) begin
					i_m1_r_en			   	 						<=	1;
					i_m1_r_addr										<=	reg_bank[pea_flt_load_index];
					reg_bank[i_index_filter]						<=	0;
					connect_buf_r_pea_w								<=	1;
 
				end else begin

					if(reg_bank[i_index_filter]<33) begin
						if(reg_bank[j_index_one_ch]==0) begin
							reg_bank[j_index_one_ch] 	 				<= reg_bank[j_index_one_ch]+1;
							reg_bank[i_index_filter]					<= reg_bank[i_index_filter] + 1;// 1 to 32	
							i_m1_r_addr									<= i_m1_r_addr + 1;
							pea_shifting_filter[reg_bank[i_index_filter]]	<= 	1;
							pea_shifting_filter[reg_bank[i_index_filter]-1]	<= 	0;							
						end else if(reg_bank[j_index_one_ch]<8) begin
							reg_bank[j_index_one_ch] 	 				<= reg_bank[j_index_one_ch]+1;
							i_m1_r_addr									<= i_m1_r_addr + 1;							
						end else begin
												
							reg_bank[j_index_one_ch] 	 				<= 0;
							i_m1_r_addr									<= reg_bank[pea_flt_load_index]+reg_bank[i_index_filter]*9*reg_bank[ch_num_sif];											
						end
					end else begin
						reg_bank[i_index_filter]						<= 0;
						i_m1_r_en										<= 0;
						connect_buf_r_pea_w								<= 0;
						state											<= calc_con_filter_bank;
					end
				end

			end

			calc_con_filter_bank : begin

				if(state!=prev_state) begin
					i_m1_r_addr						<=	(reg_bank[i_index_channel_bank]-1)*reg_bank[i_siz];
					i_m1_r_en			   	 		<=	1;
					o_m1_w_addr						<=	(reg_bank[j_index_filter_bank]-1)*reg_bank[i_out_siz];//need to adjust the timing for this
					connect_buf_r_pea_w				<=	1;
					connect_pea_r_buf_w				<=	1;
					pea_shifting_line				<=  1;
					pea_row_length					<=	reg_bank[i_wid];
					if(i_index_channel_bank<2) begin
						feedback_pea				<=	0;
						o_m1_r_en					<=	0;
					end else begin
						feedback_pea				<=	1;
						o_m1_r_addr					<=	(reg_bank[j_index_filter_bank]-1)*reg_bank[i_out_siz];
						o_m1_r_en					<=	1;	
					end
				end else begin
					if(reg_bank[j_index_one_ch]==0) begin
							i_m1_r_addr				 	 				<= i_m1_r_addr+1;
							i_m1_w_addr									<= i_m1_w_addr+1;
							o_m1_r_addr									<= o_m1_r_addr+1;
							reg_bank[j_index_one_ch]					<= reg_bank[j_index_one_ch]+1;
						end else if(reg_bank[j_index_one_ch]<reg_bank[i_siz]-1) begin
							i_m1_r_addr				 	 				<= i_m1_r_addr+1;
							i_m1_w_addr									<= i_m1_w_addr+1;
							o_m1_r_addr									<= o_m1_r_addr+1;
							reg_bank[j_index_one_ch]					<= reg_bank[j_index_one_ch]+1;							
						end else begin
							reg_bank[j_index_one_ch] 	 				<= 0;
							i_m1_r_addr				 	 				<= i_m1_r_addr+1;
							i_m1_w_addr									<= i_m1_w_addr+1;
							o_m1_r_addr									<= o_m1_r_addr+1;
							i_m1_r_en									<= 0;
							o_m1_r_en									<= 0;
							o_m1_w_en									<= 0;
							pea_shifting_line							<= 0;
							state										<= calc_con_filter_bank_loop;
					end
				end

			end


			//in the conv case the data is stored in channels and each channel resides in a specific memory bank
			//the channels are arranged by modulus in the memory banks and each channel further contains many
			//individual data units--> neurons in this case.
			//to store the data in the same format in the FC case we can select an (arbitary) number of op_nu in
			//a op_nu_channel and then obtain the total number of channels (=sif(op_nu/number per channel))
			//now further we can divide the channels into each of the bank in two manners
			//		a. modulus
			//		b. quotient and remainder 
			//We will select the method (a) and thus we have to provide the number of op_nu per channel from input
			//data itself (we will use such a value that properly divides the data), after this we obtain the number
			//of channels of output neurons. We will load these channels in the banks in modulus manner store the index
			//of the bank where discontinuity of channels occurs. We will use this value in the further layer of fc.
			//Note that this value needs to be transferred from the last layer of conv also.

			fully_connected : begin

				if(state!=prev_state) begin
					if(reg_bank[N_layers_fc]>reg_bank[l_fc]) begin
						state				<= individual_layer_fc;
						reg_bank[l_fc]		<= reg_bank[l_fc]+1;
						reg_bank[c_or_fc]	<= 1;
					end else begin
						state				<= stor_buf_mem_img_all;
						reg_bank[l_fc]		<= 0;	//reset in the parent, increase in itself
					end					
				end else begin
					state					<= idle; //some error, go back!
				end

			end

			individual_layer_fc : begin //takes care of the output channels

				if(state!=prev_state) begin
					if(reg_bank[fc_i_out_ch]>reg_bank[f_index_out_ch]) begin
						reg_bank[f_index_out_ch]	<= reg_bank[f_index_out_ch]+1;
						state						<= fc_single_op_ch;
					end else begin
						reg_bank[f_index_out_ch]	<= 0;
						state						<= fully_connected;
					end
				end else begin
					state					<= idle; //some error, go back!
				end
			end

			fc_single_op_ch : begin

				if(state!=prev_state) begin
					if(reg_bank[fc_i_out_ch_siz]>reg_bank[f_index_out_ch_siz]) begin
						reg_bank[f_index_out_ch_siz]	<= reg_bank[f_index_out_ch_siz]+1;
						reg_bank[f_index_out_nu]		<= reg_bank[f_index_out_nu]+1;
						state							<= fc_single_op_nu;						
					end else begin
						reg_bank[f_index_out_ch_siz]	<= 0;		
						state							<= individual_layer_fc;			
					end
				end else begin
					state					<= idle; //some error, go back!
				end

			end

			fc_single_op_nu : begin  //reading ext mem weights and buff inp data from here.

				if(state!=prev_state) begin
					mem_r_en			   	 	 <= 1;
					mem_r_addr					 <= mem_r_addr;
					i_m0_r_en[0]				 <= 1;
					i_m0_r_addr					 <= 0;
				end else begin
					
					if(reg_bank[fc_i_ch_siz]>reg_bank[f_index_inp_ch_siz]) begin
						reg_bank[f_index_inp_ch_siz]	<= reg_bank[f_index_inp_ch_siz]+1;
					end else begin
						reg_bank[f_index_inp_ch_siz]	<= 0;
					
						if(reg_bank[fc_i_ch]>reg_bank[f_index_i_ch]) begin
							reg_bank[f_index_i_ch]	<= reg_bank[f_index_i_ch]+1;
						end else if(reg_bank[fc_i_ch]==reg_bank[f_index_i_ch]) begin
							reg_bank[f_index_i_ch]	<= 0;
							state					<= fc_single_op_ch;
						end
					end


					//timing,timing, timing (*&(*&R%$%&***(^%&^%*&
					mem_r_addr									<= mem_r_addr+1;
					i_m0_r_en[reg_bank[f_index_i_ch][4:0]]		<= 1;
					i_m0_r_en[reg_bank[f_index_i_ch][4:0]-1]	<= 0;
					i_m0_r_addr									<= reg_bank[f_index_inp_ch_siz]*(reg_bank[f_index_i_ch]>>5);

					//look at the timing of this part
					f_mac		<= f_mac + i_m0_r_data*mem_r_data;

					//in the end assign f_mac to the memory location

				end
			end
		
			stor_buf_mem_img_all : begin

				if(state!=prev_state) begin
					state					<= state;
				end else begin
					state					<= idle; //some error, go back!
				end

			end

			stor_buf_mem_img_single : begin

				if(state!=prev_state) begin
					state					<= state;
				end else begin
					state					<= idle; //some error, go back!
				end
				

			end

			final_state : begin

				if(state!=prev_state) begin
						state				<= state;
				end else begin
					state					<= idle; //some error, go back!
				end

			end
			
			default: begin
					state				<= idle;
			end
			
			endcase
		
	end
end


always@(posedge clk, posedge rst)
begin
	if(rst) begin
		prev_state			<= idle;
		//state_entry_time	<= 0;
	end	else begin
		prev_state			<= state;
	end
end




endmodule

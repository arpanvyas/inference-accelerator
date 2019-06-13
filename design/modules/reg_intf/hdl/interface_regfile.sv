interface interface_regfile;


	//REG_0001
	logic	[3:0]	general__store_to;
	logic	[11:0]	general__layer_type;

	//REG_0002
	logic	[15:0]	general__mem_load_start_upper;

	//REG_0003
	logic	[15:0]	general__mem_load_start_lower;

	//REG_0004
	logic	[15:0]	general__mem_load_words_upper;

	//REG_0005
	logic	[15:0]	general__mem_load_words_lower;

	//REG_0006
	logic	[15:0]	general__mem_load_buffer_addr;

	//REG_0007
	logic	[15:0]	general__mem_save_start_upper;

	//REG_0008
	logic	[15:0]	general__mem_save_start_lower;

	//REG_0009
	logic	[15:0]	general__mem_save_words_upper;

	//REG_000a
	logic	[15:0]	general__mem_save_words_lower;

	//REG_000b
	logic	[15:0]	general__mem_save_buffer_addr;

	//REG_0040
	logic	[15:0]	general__status;

	//REG_0041
	logic		general__buffer_loaded;
	logic		general__buffer_saved;

	//REG_0080
	logic			general__start_wr;
	logic			general__start_wr_en;
	logic			general__abrupt_end_wr;
	logic			general__abrupt_end_wr_en;
	logic			general__reset_wr;
	logic			general__reset_wr_en;
	logic			general__digital_reset_wr;
	logic			general__digital_reset_wr_en;
	logic			general__flush_buff1_to_ext_mem_wr;
	logic			general__flush_buff1_to_ext_mem_wr_en;
	logic			general__flush_buff2_to_ext_mem_wr;
	logic			general__flush_buff2_to_ext_mem_wr_en;
	logic			general__load_buff1_from_ext_mem_wr;
	logic			general__load_buff1_from_ext_mem_wr_en;
	logic			general__load_buff2_from_ext_mem_wr;
	logic			general__load_buff2_from_ext_mem_wr_en;
	logic			general__start_loading_buffer_wr;
	logic			general__start_loading_buffer_wr_en;
	logic			general__start_saving_buffer_wr;
	logic			general__start_saving_buffer_wr_en;

	//CONV_0001
	logic	[15:0]	conv__data_wid;

	//CONV_0002
	logic	[15:0]	conv__data_hei;

	//CONV_0003
	logic	[15:0]	conv__data_ch;

	//CONV_0004
	logic	[15:0]	conv__filter_wid;

	//CONV_0005
	logic	[15:0]	conv__filter_hei;

	//CONV_0006
	logic	[15:0]	conv__filter_ch;

	//CONV_0007
	logic	[15:0]	conv__filter_num;

	//CONV_0008
	logic	[7:0]	conv__stride_horiz;
	logic	[7:0]	conv__stride_vert;

	//CONV_0009
	logic	[15:0]	conv__data_load_msb;

	//CONV_0010
	logic	[15:0]	conv__data_load_lsb;

	//CONV_0011
	logic	[15:0]	conv__filter_load_msb;

	//CONV_0012
	logic	[15:0]	conv__filter_load_lsb;

	//CONV_0013
	logic	[15:0]	conv__output_save_msb;

	//CONV_0014
	logic	[15:0]	conv__output_save_lsb;

	//CONV_0015
	logic	[15:0]	conv__data_status_cin;

	//CONV_0016
	logic	[15:0]	conv__data_status_cout;

	//CONV_0017
	logic	[3:0]	conv__status;

	//CONV_0018
	logic	[3:0]	conv__padding_horiz;
	logic	[3:0]	conv__padding_vert;

	//CONV_0019
	logic	[15:0]	conv__out_data_wid;

	//CONV_0020
	logic	[15:0]	conv__out_data_hei;

	//POOL_0001
	logic	[15:0]	pool__data_wid;

	//POOL_0002
	logic	[15:0]	pool__data_hei;

	//POOL_0003
	logic	[15:0]	pool__data_ch;

	//POOL_0004
	logic	[15:0]	pool__pool_type;

	//POOL_0005
	logic	[15:0]	pool__pool_horiz;

	//POOL_0006
	logic	[15:0]	pool__pool_vert;

	//POOL_0007
	logic	[15:0]	pool__pool_horiz_stride;

	//POOL_0008
	logic	[15:0]	pool__pool_vert_stride;

	//POOL_0009
	logic	[15:0]	pool__output_wid;

	//POOL_0010
	logic	[15:0]	pool__output_hei;

	//POOL_0011
	logic	[15:0]	pool__output_ch;

	//NL_0001
	logic	[15:0]	nl__data_wid;

	//NL_0002
	logic	[15:0]	nl__data_hei;

	//NL_0003
	logic	[15:0]	nl__data_ch;

	//NL_0004
	logic	[15:0]	nl__nl_type;

	//NL_0005
	logic	[15:0]	nl__output_wid;

	//NL_0006
	logic	[15:0]	nl__output_hei;

	//NL_0007
	logic	[15:0]	nl__output_ch;

	//NL_0008
	logic	[15:0]	nl__input_data_format;

	//NL_0009
	logic	[15:0]	nl__input_data_length;

	//NL_0010
	logic	[15:0]	nl__output_data_length;

	//FC_0001
	logic	[15:0]	fc__input_data_type;

	//FC_0002
	logic	[15:0]	fc__data_wid;

	//FC_0003
	logic	[15:0]	fc__data_hei;

	//FC_0004
	logic	[15:0]	fc__data_ch;

	//FC_0005
	logic	[15:0]	fc__output_wid;

	//FC_0006
	logic	[15:0]	fc__output_hei;

	//FC_0007
	logic	[15:0]	fc__output_ch;

	//FC_0008
	logic	[15:0]	fc__input_data_length;

	//FC_0009
	logic	[15:0]	fc__output_data_length;

	//FC_0010
	logic	[15:0]	fc__wid_weight_matrix;

	//FC_0011
	logic	[15:0]	fc__hei_weight_matrix;


endinterface

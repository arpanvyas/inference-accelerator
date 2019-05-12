module reg_intf(
    input  clk,
    input  rst,

    //SPI Slave Signals
    input  SCLK,
    input  MOSI,
    input  SS,
    output MISO,

    //Program Driver Signals
    input  wr_en_drv,
    input logic rd_en_drv,
    input logic [13:0] addr_drv,
    input logic [15:0] write_data_drv,
    output logic [15:0] read_data_drv
    
    //From Controller
    input logic spi_or_driver 
    
    //Register Fields Signals 

);


//INSTANTIATING spi_slave_inst

logic                   clk;
logic                   rst;
logic                   MOSI;
logic                   SCLK;
logic                   SS;
logic                   MISO;
logic   [15:0]          tx_data_spi;
logic   [13:0]          rx_addr_spi;
logic   [15:0]          rx_data_spi;

logic                   rd_en_stretch_spi;
logic                   wr_en_stretch_spi;

spi_slave spi_slave_inst (
        .clk(clk),
        .rst(rst),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .SS(SS),
        .MISO(MISO),
        //Input
        .tx_data(tx_data_spi),
        //Output
        .rx_addr(rx_addr_spi),
        .rx_data(rx_data_spi),
        .rd_en_stretch(rd_en_stretch_spi),
        .wr_en_stretch(wr_en_stretch_spi)
);

///////////////////////////////////////////////
//SPI vs Driver Instance
///////////////////////////////////////////////

logic   [15:0]      read_data;
logic   [15:0]      write_data;
logic   [13:0]      addr;

reg_intf_mux reg_intf_mux_inst (
    .clk(clk),
    .rst(rst),

    .spi_or_driver(spi_or_driver),

    .rd_en_stretch_spi(rd_en_stretch_spi),
    .wr_en_stretch_spi(wr_en_stretch_spi),
    .addr_spi(rx_addr_spi),
    .read_data_spi(tx_data_spi),
    .write_data_spi(rx_data_spi),

    .wr_en_drv(wr_en_drv),
    .rd_en_drv(rd_en_drv),
    .addr_drv(addr_drv),
    .write_data_drv(write_data_drv),
    .read_data_drv(read_data_drv),

    .wr_en(wr_en),
    .rd_en(rd_en),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
);





//CODE FROM THIS POINT TO BE CHANGED ON CHANGING REGISTERFILE(S)

logic	[15:0]		read_data_GENERAL_CONFIG;
logic	[15:0]		read_data_CONV;
logic	[15:0]		read_data_POOL;
logic	[15:0]		read_data_NL;
logic	[15:0]		read_data_FC;

always@(*)
begin
    case(addr[13:9])
        5'h00 : read_data = read_data_GENERAL_CONFIG;
        5'h01 : read_data = read_data_CONV;
        5'h02 : read_data = read_data_POOL;
        5'h03 : read_data = read_data_NL;
        5'h04 : read_data = read_data_FC;
        default : read_data = 16'h0; 
    endcase
end
//INSTANTIATING regfile_conv_inst

logic	[15:0]		CONV_0001__data_wid;
logic	[15:0]		CONV_0002__data_hei;
logic	[15:0]		CONV_0003__data_ch;
logic	[15:0]		CONV_0004__filter_wid;
logic	[15:0]		CONV_0005__filter_hei;
logic	[15:0]		CONV_0006__filter_ch;
logic	[15:0]		CONV_0007__filter_num;
logic	[7:0]		CONV_0008__stride_horiz;
logic	[7:0]		CONV_0008__stride_vert;
logic	[15:0]		CONV_0009__data_load_msb;
logic	[15:0]		CONV_0010__data_load_lsb;
logic	[15:0]		CONV_0011__filter_load_msb;
logic	[15:0]		CONV_0012__filter_load_lsb;
logic	[15:0]		CONV_0013__output_save_msb;
logic	[15:0]		CONV_0014__output_save_lsb;
logic	[15:0]		CONV_0015__data_status_cin;
logic	[15:0]		CONV_0016__data_status_cout;
logic	[3:0]		CONV_0017__status;

regfile_conv regfile_conv_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_CONV(read_data_CONV),
	.CONV_0001__data_wid(CONV_0001__data_wid),
	.CONV_0002__data_hei(CONV_0002__data_hei),
	.CONV_0003__data_ch(CONV_0003__data_ch),
	.CONV_0004__filter_wid(CONV_0004__filter_wid),
	.CONV_0005__filter_hei(CONV_0005__filter_hei),
	.CONV_0006__filter_ch(CONV_0006__filter_ch),
	.CONV_0007__filter_num(CONV_0007__filter_num),
	.CONV_0008__stride_horiz(CONV_0008__stride_horiz),
	.CONV_0008__stride_vert(CONV_0008__stride_vert),
	.CONV_0009__data_load_msb(CONV_0009__data_load_msb),
	.CONV_0010__data_load_lsb(CONV_0010__data_load_lsb),
	.CONV_0011__filter_load_msb(CONV_0011__filter_load_msb),
	.CONV_0012__filter_load_lsb(CONV_0012__filter_load_lsb),
	.CONV_0013__output_save_msb(CONV_0013__output_save_msb),
	.CONV_0014__output_save_lsb(CONV_0014__output_save_lsb),
	.CONV_0015__data_status_cin(CONV_0015__data_status_cin),
	.CONV_0016__data_status_cout(CONV_0016__data_status_cout),
	.CONV_0017__status(CONV_0017__status)
);

//INSTANTIATING regfile_fc_inst

logic	[15:0]		FC_0001__input_data_type;
logic	[15:0]		FC_0002__data_wid;
logic	[15:0]		FC_0003__data_hei;
logic	[15:0]		FC_0004__data_ch;
logic	[15:0]		FC_0005__output_wid;
logic	[15:0]		FC_0006__output_hei;
logic	[15:0]		FC_0007__output_ch;
logic	[15:0]		FC_0008__input_data_length;
logic	[15:0]		FC_0009__output_data_length;
logic	[15:0]		FC_0010__wid_weight_matrix;
logic	[15:0]		FC_0011__hei_weight_matrix;

regfile_fc regfile_fc_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_FC(read_data_FC),
	.FC_0001__input_data_type(FC_0001__input_data_type),
	.FC_0002__data_wid(FC_0002__data_wid),
	.FC_0003__data_hei(FC_0003__data_hei),
	.FC_0004__data_ch(FC_0004__data_ch),
	.FC_0005__output_wid(FC_0005__output_wid),
	.FC_0006__output_hei(FC_0006__output_hei),
	.FC_0007__output_ch(FC_0007__output_ch),
	.FC_0008__input_data_length(FC_0008__input_data_length),
	.FC_0009__output_data_length(FC_0009__output_data_length),
	.FC_0010__wid_weight_matrix(FC_0010__wid_weight_matrix),
	.FC_0011__hei_weight_matrix(FC_0011__hei_weight_matrix)
);

//INSTANTIATING regfile_general_config_inst

logic	[3:0]		REG_0001__store_to;
logic	[11:0]		REG_0001__layer_type;
logic	[15:0]		REG_0002__mem_load_start_upper;
logic	[15:0]		REG_0003__mem_load_start_lower;
logic	[15:0]		REG_0004__mem_load_words_upper;
logic	[15:0]		REG_0005__mem_load_words_lower;
logic	[15:0]		REG_0006__mem_load_buffer_addr;
logic	[15:0]		REG_0007__mem_save_start_upper;
logic	[15:0]		REG_0008__mem_save_start_lower;
logic	[15:0]		REG_0009__mem_save_words_upper;
logic	[15:0]		REG_000a__mem_save_words_lower;
logic	[15:0]		REG_000b__mem_save_buffer_addr;
logic	[15:0]		REG_0040__status;
logic			REG_0041__buffer_loaded;
logic			REG_0041__buffer_saved;
logic			REG_0080__start_wr;
logic			REG_0080__start_wr_en;
logic			REG_0080__abrupt_end_wr;
logic			REG_0080__abrupt_end_wr_en;
logic			REG_0080__reset_wr;
logic			REG_0080__reset_wr_en;
logic			REG_0080__digital_reset_wr;
logic			REG_0080__digital_reset_wr_en;
logic			REG_0080__flush_buff1_to_ext_mem_wr;
logic			REG_0080__flush_buff1_to_ext_mem_wr_en;
logic			REG_0080__flush_buff2_to_ext_mem_wr;
logic			REG_0080__flush_buff2_to_ext_mem_wr_en;
logic			REG_0080__load_buff1_from_ext_mem_wr;
logic			REG_0080__load_buff1_from_ext_mem_wr_en;
logic			REG_0080__load_buff2_from_ext_mem_wr;
logic			REG_0080__load_buff2_from_ext_mem_wr_en;
logic			REG_0080__start_loading_buffer_wr;
logic			REG_0080__start_loading_buffer_wr_en;
logic			REG_0080__start_saving_buffer_wr;
logic			REG_0080__start_saving_buffer_wr_en;

regfile_general_config regfile_general_config_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_GENERAL_CONFIG(read_data_GENERAL_CONFIG),
	.REG_0001__store_to(REG_0001__store_to),
	.REG_0001__layer_type(REG_0001__layer_type),
	.REG_0002__mem_load_start_upper(REG_0002__mem_load_start_upper),
	.REG_0003__mem_load_start_lower(REG_0003__mem_load_start_lower),
	.REG_0004__mem_load_words_upper(REG_0004__mem_load_words_upper),
	.REG_0005__mem_load_words_lower(REG_0005__mem_load_words_lower),
	.REG_0006__mem_load_buffer_addr(REG_0006__mem_load_buffer_addr),
	.REG_0007__mem_save_start_upper(REG_0007__mem_save_start_upper),
	.REG_0008__mem_save_start_lower(REG_0008__mem_save_start_lower),
	.REG_0009__mem_save_words_upper(REG_0009__mem_save_words_upper),
	.REG_000a__mem_save_words_lower(REG_000a__mem_save_words_lower),
	.REG_000b__mem_save_buffer_addr(REG_000b__mem_save_buffer_addr),
	.REG_0040__status(REG_0040__status),
	.REG_0041__buffer_loaded(REG_0041__buffer_loaded),
	.REG_0041__buffer_saved(REG_0041__buffer_saved),
	.REG_0080__start_wr(REG_0080__start_wr),
	.REG_0080__start_wr_en(REG_0080__start_wr_en),
	.REG_0080__abrupt_end_wr(REG_0080__abrupt_end_wr),
	.REG_0080__abrupt_end_wr_en(REG_0080__abrupt_end_wr_en),
	.REG_0080__reset_wr(REG_0080__reset_wr),
	.REG_0080__reset_wr_en(REG_0080__reset_wr_en),
	.REG_0080__digital_reset_wr(REG_0080__digital_reset_wr),
	.REG_0080__digital_reset_wr_en(REG_0080__digital_reset_wr_en),
	.REG_0080__flush_buff1_to_ext_mem_wr(REG_0080__flush_buff1_to_ext_mem_wr),
	.REG_0080__flush_buff1_to_ext_mem_wr_en(REG_0080__flush_buff1_to_ext_mem_wr_en),
	.REG_0080__flush_buff2_to_ext_mem_wr(REG_0080__flush_buff2_to_ext_mem_wr),
	.REG_0080__flush_buff2_to_ext_mem_wr_en(REG_0080__flush_buff2_to_ext_mem_wr_en),
	.REG_0080__load_buff1_from_ext_mem_wr(REG_0080__load_buff1_from_ext_mem_wr),
	.REG_0080__load_buff1_from_ext_mem_wr_en(REG_0080__load_buff1_from_ext_mem_wr_en),
	.REG_0080__load_buff2_from_ext_mem_wr(REG_0080__load_buff2_from_ext_mem_wr),
	.REG_0080__load_buff2_from_ext_mem_wr_en(REG_0080__load_buff2_from_ext_mem_wr_en),
	.REG_0080__start_loading_buffer_wr(REG_0080__start_loading_buffer_wr),
	.REG_0080__start_loading_buffer_wr_en(REG_0080__start_loading_buffer_wr_en),
	.REG_0080__start_saving_buffer_wr(REG_0080__start_saving_buffer_wr),
	.REG_0080__start_saving_buffer_wr_en(REG_0080__start_saving_buffer_wr_en)
);

//INSTANTIATING regfile_nl_inst

logic	[15:0]		NL_0001__data_wid;
logic	[15:0]		NL_0002__data_hei;
logic	[15:0]		NL_0003__data_ch;
logic	[15:0]		NL_0004__nl_type;
logic	[15:0]		NL_0005__output_wid;
logic	[15:0]		NL_0006__output_hei;
logic	[15:0]		NL_0007__output_ch;
logic	[15:0]		NL_0008__input_data_format;
logic	[15:0]		NL_0009__input_data_length;
logic	[15:0]		NL_0010__output_data_length;

regfile_nl regfile_nl_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_NL(read_data_NL),
	.NL_0001__data_wid(NL_0001__data_wid),
	.NL_0002__data_hei(NL_0002__data_hei),
	.NL_0003__data_ch(NL_0003__data_ch),
	.NL_0004__nl_type(NL_0004__nl_type),
	.NL_0005__output_wid(NL_0005__output_wid),
	.NL_0006__output_hei(NL_0006__output_hei),
	.NL_0007__output_ch(NL_0007__output_ch),
	.NL_0008__input_data_format(NL_0008__input_data_format),
	.NL_0009__input_data_length(NL_0009__input_data_length),
	.NL_0010__output_data_length(NL_0010__output_data_length)
);

//INSTANTIATING regfile_pool_inst

logic	[15:0]		POOL_0001__data_wid;
logic	[15:0]		POOL_0002__data_hei;
logic	[15:0]		POOL_0003__data_ch;
logic	[15:0]		POOL_0004__pool_type;
logic	[15:0]		POOL_0005__pool_horiz;
logic	[15:0]		POOL_0006__pool_vert;
logic	[15:0]		POOL_0007__pool_horiz_stride;
logic	[15:0]		POOL_0008__pool_vert_stride;
logic	[15:0]		POOL_0009__output_wid;
logic	[15:0]		POOL_0010__output_hei;
logic	[15:0]		POOL_0011__output_ch;

regfile_pool regfile_pool_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_POOL(read_data_POOL),
	.POOL_0001__data_wid(POOL_0001__data_wid),
	.POOL_0002__data_hei(POOL_0002__data_hei),
	.POOL_0003__data_ch(POOL_0003__data_ch),
	.POOL_0004__pool_type(POOL_0004__pool_type),
	.POOL_0005__pool_horiz(POOL_0005__pool_horiz),
	.POOL_0006__pool_vert(POOL_0006__pool_vert),
	.POOL_0007__pool_horiz_stride(POOL_0007__pool_horiz_stride),
	.POOL_0008__pool_vert_stride(POOL_0008__pool_vert_stride),
	.POOL_0009__output_wid(POOL_0009__output_wid),
	.POOL_0010__output_hei(POOL_0010__output_hei),
	.POOL_0011__output_ch(POOL_0011__output_ch)
);

endmodule

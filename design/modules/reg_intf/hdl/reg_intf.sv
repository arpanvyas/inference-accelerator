module reg_intf(
    input  clk,
    input  rst,
    input  SCLK,
    input  MOSI,
    input  SS,
    output MISO

);


//INSTANTIATING spi_slave_inst

logic                   clk;
logic                   rst;
logic                   MOSI;
logic                   SCLK;
logic                   SS;
logic                   MISO;
logic   [15:0]          tx_data;
logic   [13:0]          rx_addr;
logic                   rx_addr_en;
logic   [1:0]           rx_rw_mode;
logic                   rx_rw_mode_en;
logic   [15:0]          rx_data;
logic                   rx_data_en;

logic                   rd_en_stretch;
logic                   wr_en_stretch;

spi_slave spi_slave_inst (
        .clk(clk),
        .rst(rst),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .SS(SS),
        .MISO(MISO),
        .tx_data(tx_data),
        .rx_addr(rx_addr),
        .rx_addr_en(rx_addr_en),
        .rx_rw_mode(rx_rw_mode),
        .rx_rw_mode_en(rx_rw_mode_en),
        .rx_data(rx_data),
        .rx_data_en(rx_data_en),
        .rd_en_stretch(rd_en_stretch),
        .wr_en_stretch(wr_en_stretch)
);

//Syncing rd_en and wr_en

logic rd_en_synced;
logic wr_en_synced;

sync_2s rd_en_stretch_sync (
    .clk(clk), .d(rd_en_stretch), .q(rd_en_synced)
);

sync_2s wr_en_stretch_sync (
    .clk(clk), .d(wr_en_stretch), .q(wr_en_synced)
);

//Getting single cycle rd_en and wr_en from synced (as their length uncertain)
logic rd_en_synced_hold;
logic wr_en_synced_hold;

logic rd_en;
logic wr_en;

always@(posedge clk, posedge rst)
begin
    if(rst) begin
        rd_en_synced_hold <= #1 0;
        wr_en_synced_hold <= #1 0;
    end else begin
        rd_en_synced_hold <= #1 rd_en_synced;
        wr_en_synced_hold <= #1 wr_en_synced;
    end
end

assign rd_en = (!rd_en_synced_hold && rd_en_synced);
assign wr_en = (!wr_en_synced_hold && wr_en_synced);


///////////////////////////////////////////////////////////////////////////////////////
////The purpose of clean logic is to ensure that at very high frequencies of
////SCKL wrt clk, wr_en and rd_en will not be long enough and so rather than
////writing garbage (metastable) data, the design will simply not
////accept writes, but may give bad reads, although ROC will not occur.
///////////////////////////////////////////////////////////////////////////////////////
//
//logic rw_en_hold;
//logic rw_en_clean;
//logic rw_en_clean_hold;
//logic rw_mode_en;
//
//logic			wr_en;
//logic			rd_en;
logic	[13:0]		addr;
logic	[15:0]		write_data;
//
//
//always@(posedge clk, posedge rst) begin
//    if(rst) begin
//        rw_en_hold <= #1 0;
//        rw_en_clean_hold <= #1 0;
//    end else begin
//        rw_en_hold <= #1 rx_rw_mode_en;
//        rw_en_clean_hold <= #1 rw_en_clean;
//    end
//end
//
//assign rw_en_clean = rw_en_hold && rx_rw_mode_en;
//assign rw_mode_en = (rw_en_clean) && (!rw_en_clean_hold);
//
//assign rd_en = (rw_mode_en) && (rx_rw_mode == 2'b00);
//assign wr_en = (rw_mode_en) && (rx_rw_mode == 2'b01);
assign write_data = rx_data;
assign addr = rx_addr;

//always@(*)
//begin
//    if(rst) begin
//        tx_data = 0;
//    end else begin
//        if(rd_en) begin
//            tx_data = tx_data_mux;
//        end else begin
//            tx_data = tx_data;
//        end
//    end
//end



//CODE FROM THIS POINT TO BE CHANGED ON CHANGING REGISTERFILE(S)

logic	[15:0]		read_data_GENERAL_CONFIG;
logic	[15:0]		read_data_CONV;
logic	[15:0]		read_data_POOL;
logic	[15:0]		read_data_NL;
logic	[15:0]		read_data_FC;

always@(*)
begin
    case(addr[13:9])
        5'h00 : tx_data = read_data_GENERAL_CONFIG;
        5'h01 : tx_data = read_data_CONV;
        5'h02 : tx_data = read_data_POOL;
        5'h03 : tx_data = read_data_NL;
        5'h04 : tx_data = read_data_FC;
        default : tx_data = 16'h0; 
    endcase
end
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
logic	[15:0]		REG_0010__mem_save_words_lower;
logic	[15:0]		REG_0011__mem_save_buffer_addr;
logic	[15:0]		REG_0012__status;
logic			REG_0013__start_wr;
logic			REG_0013__start_wr_en;
logic			REG_0013__abrupt_end_wr;
logic			REG_0013__abrupt_end_wr_en;
logic			REG_0013__reset_wr;
logic			REG_0013__reset_wr_en;
logic			REG_0013__digital_reset_wr;
logic			REG_0013__digital_reset_wr_en;
logic			REG_0013__flush_buff1_to_ext_mem_wr;
logic			REG_0013__flush_buff1_to_ext_mem_wr_en;
logic			REG_0013__flush_buff2_to_ext_mem_wr;
logic			REG_0013__flush_buff2_to_ext_mem_wr_en;
logic			REG_0013__load_buff1_from_ext_mem_wr;
logic			REG_0013__load_buff1_from_ext_mem_wr_en;
logic			REG_0013__load_buff2_from_ext_mem_wr;
logic			REG_0013__load_buff2_from_ext_mem_wr_en;
logic			REG_0013__start_loading_buffer_wr;
logic			REG_0013__start_loading_buffer_wr_en;
logic			REG_0013__start_saving_buffer_wr;
logic			REG_0013__start_saving_buffer_wr_en;
logic			REG_0014__buffer_loaded_wr;
logic			REG_0014__buffer_loaded_wr_en;
logic			REG_0014__buffer_saved_wr;
logic			REG_0014__buffer_saved_wr_en;

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
	.REG_0010__mem_save_words_lower(REG_0010__mem_save_words_lower),
	.REG_0011__mem_save_buffer_addr(REG_0011__mem_save_buffer_addr),
	.REG_0012__status(REG_0012__status),
	.REG_0013__start_wr(REG_0013__start_wr),
	.REG_0013__start_wr_en(REG_0013__start_wr_en),
	.REG_0013__abrupt_end_wr(REG_0013__abrupt_end_wr),
	.REG_0013__abrupt_end_wr_en(REG_0013__abrupt_end_wr_en),
	.REG_0013__reset_wr(REG_0013__reset_wr),
	.REG_0013__reset_wr_en(REG_0013__reset_wr_en),
	.REG_0013__digital_reset_wr(REG_0013__digital_reset_wr),
	.REG_0013__digital_reset_wr_en(REG_0013__digital_reset_wr_en),
	.REG_0013__flush_buff1_to_ext_mem_wr(REG_0013__flush_buff1_to_ext_mem_wr),
	.REG_0013__flush_buff1_to_ext_mem_wr_en(REG_0013__flush_buff1_to_ext_mem_wr_en),
	.REG_0013__flush_buff2_to_ext_mem_wr(REG_0013__flush_buff2_to_ext_mem_wr),
	.REG_0013__flush_buff2_to_ext_mem_wr_en(REG_0013__flush_buff2_to_ext_mem_wr_en),
	.REG_0013__load_buff1_from_ext_mem_wr(REG_0013__load_buff1_from_ext_mem_wr),
	.REG_0013__load_buff1_from_ext_mem_wr_en(REG_0013__load_buff1_from_ext_mem_wr_en),
	.REG_0013__load_buff2_from_ext_mem_wr(REG_0013__load_buff2_from_ext_mem_wr),
	.REG_0013__load_buff2_from_ext_mem_wr_en(REG_0013__load_buff2_from_ext_mem_wr_en),
	.REG_0013__start_loading_buffer_wr(REG_0013__start_loading_buffer_wr),
	.REG_0013__start_loading_buffer_wr_en(REG_0013__start_loading_buffer_wr_en),
	.REG_0013__start_saving_buffer_wr(REG_0013__start_saving_buffer_wr),
	.REG_0013__start_saving_buffer_wr_en(REG_0013__start_saving_buffer_wr_en),
	.REG_0014__buffer_loaded_wr(REG_0014__buffer_loaded_wr),
	.REG_0014__buffer_loaded_wr_en(REG_0014__buffer_loaded_wr_en),
	.REG_0014__buffer_saved_wr(REG_0014__buffer_saved_wr),
	.REG_0014__buffer_saved_wr_en(REG_0014__buffer_saved_wr_en)
);

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

endmodule

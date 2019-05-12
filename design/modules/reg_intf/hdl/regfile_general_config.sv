module regfile_general_config (
	input	logic		clk,
	input	logic		rst,
	input	logic		wr_en,
	input	logic		rd_en,
	input	logic	[13:0]	addr,
	input	logic	[15:0]	write_data,
	output	logic	[15:0]	read_data_GENERAL_CONFIG,

	//REG_0001
	output	logic	[3:0]	REG_0001__store_to,
	output	logic	[11:0]	REG_0001__layer_type,

	//REG_0002
	output	logic	[15:0]	REG_0002__mem_load_start_upper,

	//REG_0003
	output	logic	[15:0]	REG_0003__mem_load_start_lower,

	//REG_0004
	output	logic	[15:0]	REG_0004__mem_load_words_upper,

	//REG_0005
	output	logic	[15:0]	REG_0005__mem_load_words_lower,

	//REG_0006
	output	logic	[15:0]	REG_0006__mem_load_buffer_addr,

	//REG_0007
	output	logic	[15:0]	REG_0007__mem_save_start_upper,

	//REG_0008
	output	logic	[15:0]	REG_0008__mem_save_start_lower,

	//REG_0009
	output	logic	[15:0]	REG_0009__mem_save_words_upper,

	//REG_0010
	output	logic	[15:0]	REG_0010__mem_save_words_lower,

	//REG_0011
	output	logic	[15:0]	REG_0011__mem_save_buffer_addr,

	//REG_0012
	output	logic	[15:0]	REG_0012__status,

	//REG_0013
	output	logic			REG_0013__start_wr,
	output	logic			REG_0013__start_wr_en,
	output	logic			REG_0013__abrupt_end_wr,
	output	logic			REG_0013__abrupt_end_wr_en,
	output	logic			REG_0013__reset_wr,
	output	logic			REG_0013__reset_wr_en,
	output	logic			REG_0013__digital_reset_wr,
	output	logic			REG_0013__digital_reset_wr_en,
	output	logic			REG_0013__flush_buff1_to_ext_mem_wr,
	output	logic			REG_0013__flush_buff1_to_ext_mem_wr_en,
	output	logic			REG_0013__flush_buff2_to_ext_mem_wr,
	output	logic			REG_0013__flush_buff2_to_ext_mem_wr_en,
	output	logic			REG_0013__load_buff1_from_ext_mem_wr,
	output	logic			REG_0013__load_buff1_from_ext_mem_wr_en,
	output	logic			REG_0013__load_buff2_from_ext_mem_wr,
	output	logic			REG_0013__load_buff2_from_ext_mem_wr_en,
	output	logic			REG_0013__start_loading_buffer_wr,
	output	logic			REG_0013__start_loading_buffer_wr_en,
	output	logic			REG_0013__start_saving_buffer_wr,
	output	logic			REG_0013__start_saving_buffer_wr_en,

	//REG_0014
	input	logic		REG_0014__buffer_loaded_wr,
	input	logic		REG_0014__buffer_loaded_wr_en,
	input	logic		REG_0014__buffer_saved_wr,
	input	logic		REG_0014__buffer_saved_wr_en
	);

//DECLARATIONS
logic	[15:0]	REG_0001;
logic	[15:0]	REG_0002;
logic	[15:0]	REG_0003;
logic	[15:0]	REG_0004;
logic	[15:0]	REG_0005;
logic	[15:0]	REG_0006;
logic	[15:0]	REG_0007;
logic	[15:0]	REG_0008;
logic	[15:0]	REG_0009;
logic	[15:0]	REG_0010;
logic	[15:0]	REG_0011;
logic	[15:0]	REG_0012;
logic	[15:0]	REG_0013;
logic	[15:0]	REG_0014;

//READ REGISTER
always@(*)
begin
	case (addr)
		14'h1 : read_data_GENERAL_CONFIG = REG_0001;
		14'h2 : read_data_GENERAL_CONFIG = REG_0002;
		14'h3 : read_data_GENERAL_CONFIG = REG_0003;
		14'h4 : read_data_GENERAL_CONFIG = REG_0004;
		14'h5 : read_data_GENERAL_CONFIG = REG_0005;
		14'h6 : read_data_GENERAL_CONFIG = REG_0006;
		14'h7 : read_data_GENERAL_CONFIG = REG_0007;
		14'h8 : read_data_GENERAL_CONFIG = REG_0008;
		14'h9 : read_data_GENERAL_CONFIG = REG_0009;
		14'h10 : read_data_GENERAL_CONFIG = REG_0010;
		14'h11 : read_data_GENERAL_CONFIG = REG_0011;
		14'h12 : read_data_GENERAL_CONFIG = REG_0012;
		14'h13 : read_data_GENERAL_CONFIG = REG_0013;
		14'h14 : read_data_GENERAL_CONFIG = REG_0014;
		default : read_data_GENERAL_CONFIG = 16'h0;
	endcase
end


//REGISTER REG_0001
assign	{REG_0001__layer_type,REG_0001__store_to }	=	{ REG_0001[15:4],REG_0001[3:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0001[15:4],REG_0001[3:0] } <= #1 { 12'h0,4'h0 };
	end else begin
		if (wr_en && addr == 14'h1) begin
			{ REG_0001[15:4],REG_0001[3:0] } <= #1 { write_data[15:4],write_data[3:0] };
		end
	end
end





//REGISTER REG_0002
assign	{REG_0002__mem_load_start_upper }	=	{ REG_0002[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0002[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h2) begin
			{ REG_0002[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0003
assign	{REG_0003__mem_load_start_lower }	=	{ REG_0003[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0003[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h3) begin
			{ REG_0003[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0004
assign	{REG_0004__mem_load_words_upper }	=	{ REG_0004[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0004[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h4) begin
			{ REG_0004[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0005
assign	{REG_0005__mem_load_words_lower }	=	{ REG_0005[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0005[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h5) begin
			{ REG_0005[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0006
assign	{REG_0006__mem_load_buffer_addr }	=	{ REG_0006[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0006[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h6) begin
			{ REG_0006[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0007
assign	{REG_0007__mem_save_start_upper }	=	{ REG_0007[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0007[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h7) begin
			{ REG_0007[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0008
assign	{REG_0008__mem_save_start_lower }	=	{ REG_0008[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0008[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h8) begin
			{ REG_0008[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0009
assign	{REG_0009__mem_save_words_upper }	=	{ REG_0009[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0009[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h9) begin
			{ REG_0009[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0010
assign	{REG_0010__mem_save_words_lower }	=	{ REG_0010[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0010[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h10) begin
			{ REG_0010[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0011
assign	{REG_0011__mem_save_buffer_addr }	=	{ REG_0011[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0011[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h11) begin
			{ REG_0011[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0012
assign	{REG_0012__status }	=	{ REG_0012[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_0012[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h12) begin
			{ REG_0012[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0013
assign	{REG_0013[9:9],REG_0013[8:8],REG_0013[7:7],REG_0013[6:6],REG_0013[5:5],REG_0013[4:4],REG_0013[3:3],REG_0013[2:2],REG_0013[1:1],REG_0013[0:0] }	=	{ 1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0 };
//WOC fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		REG_0013__start_wr <= #1 1'h0;
		REG_0013__abrupt_end_wr <= #1 1'h0;
		REG_0013__reset_wr <= #1 1'h0;
		REG_0013__digital_reset_wr <= #1 1'h0;
		REG_0013__flush_buff1_to_ext_mem_wr <= #1 1'h0;
		REG_0013__flush_buff2_to_ext_mem_wr <= #1 1'h0;
		REG_0013__load_buff1_from_ext_mem_wr <= #1 1'h0;
		REG_0013__load_buff2_from_ext_mem_wr <= #1 1'h0;
		REG_0013__start_loading_buffer_wr <= #1 1'h0;
		REG_0013__start_saving_buffer_wr <= #1 1'h0;
	end else begin
		if (wr_en && addr == 14'h13) begin
			REG_0013__start_wr <= #1 write_data[0:0];
			REG_0013__start_wr_en <= #1 1;
			REG_0013__abrupt_end_wr <= #1 write_data[1:1];
			REG_0013__abrupt_end_wr_en <= #1 1;
			REG_0013__reset_wr <= #1 write_data[2:2];
			REG_0013__reset_wr_en <= #1 1;
			REG_0013__digital_reset_wr <= #1 write_data[3:3];
			REG_0013__digital_reset_wr_en <= #1 1;
			REG_0013__flush_buff1_to_ext_mem_wr <= #1 write_data[4:4];
			REG_0013__flush_buff1_to_ext_mem_wr_en <= #1 1;
			REG_0013__flush_buff2_to_ext_mem_wr <= #1 write_data[5:5];
			REG_0013__flush_buff2_to_ext_mem_wr_en <= #1 1;
			REG_0013__load_buff1_from_ext_mem_wr <= #1 write_data[6:6];
			REG_0013__load_buff1_from_ext_mem_wr_en <= #1 1;
			REG_0013__load_buff2_from_ext_mem_wr <= #1 write_data[7:7];
			REG_0013__load_buff2_from_ext_mem_wr_en <= #1 1;
			REG_0013__start_loading_buffer_wr <= #1 write_data[8:8];
			REG_0013__start_loading_buffer_wr_en <= #1 1;
			REG_0013__start_saving_buffer_wr <= #1 write_data[9:9];
			REG_0013__start_saving_buffer_wr_en <= #1 1;
		end
	end
end





//REGISTER REG_0014
logic	[0:0]	REG_0014__buffer_loaded;
logic	[0:0]	REG_0014__buffer_saved;
assign	{REG_0014[1:1],REG_0014[0:0] }	=	{ REG_0014__buffer_saved,REG_0014__buffer_loaded };
//ROC fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		REG_0014__buffer_loaded <= #1 1'h0;
		REG_0014__buffer_saved <= #1 1'h0;
	end else begin
		if (rd_en && addr == 14'h14) begin
			REG_0014__buffer_loaded <= #1 1'h0;
			REG_0014__buffer_saved <= #1 1'h0;
		end else begin
			if(REG_0014__buffer_loaded_wr_en) begin
				REG_0014__buffer_loaded <= #1 REG_0014__buffer_loaded_wr;
			end
			if(REG_0014__buffer_saved_wr_en) begin
				REG_0014__buffer_saved <= #1 REG_0014__buffer_saved_wr;
			end
		end
	end
end







endmodule


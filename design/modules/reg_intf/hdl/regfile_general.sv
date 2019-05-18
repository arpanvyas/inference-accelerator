module regfile_general (
	input	logic		clk,
	input	logic		rst,
	input	logic		wr_en,
	input	logic		rd_en,
	input	logic	[13:0]	addr,
	input	logic	[15:0]	write_data,
	output	logic	[15:0]	read_data_GENERAL,
	regfile_interface	regfile
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
logic	[15:0]	REG_000a;
logic	[15:0]	REG_000b;
logic	[15:0]	REG_0040;
logic	[15:0]	REG_0041;
logic	[15:0]	REG_0080;

//READ REGISTER
always@(*)
begin
	case (addr)
		14'h1 : read_data_GENERAL = REG_0001;
		14'h2 : read_data_GENERAL = REG_0002;
		14'h3 : read_data_GENERAL = REG_0003;
		14'h4 : read_data_GENERAL = REG_0004;
		14'h5 : read_data_GENERAL = REG_0005;
		14'h6 : read_data_GENERAL = REG_0006;
		14'h7 : read_data_GENERAL = REG_0007;
		14'h8 : read_data_GENERAL = REG_0008;
		14'h9 : read_data_GENERAL = REG_0009;
		14'ha : read_data_GENERAL = REG_000a;
		14'hb : read_data_GENERAL = REG_000b;
		14'h40 : read_data_GENERAL = REG_0040;
		14'h41 : read_data_GENERAL = REG_0041;
		14'h80 : read_data_GENERAL = REG_0080;
		default : read_data_GENERAL = 16'h0;
	endcase
end


//REGISTER REG_0001
assign	{regfile.general__layer_type,regfile.general__store_to }	=	{ REG_0001[15:4],REG_0001[3:0] };
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
assign	{regfile.general__mem_load_start_upper }	=	{ REG_0002[15:0] };
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
assign	{regfile.general__mem_load_start_lower }	=	{ REG_0003[15:0] };
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
assign	{regfile.general__mem_load_words_upper }	=	{ REG_0004[15:0] };
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
assign	{regfile.general__mem_load_words_lower }	=	{ REG_0005[15:0] };
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
assign	{regfile.general__mem_load_buffer_addr }	=	{ REG_0006[15:0] };
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
assign	{regfile.general__mem_save_start_upper }	=	{ REG_0007[15:0] };
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
assign	{regfile.general__mem_save_start_lower }	=	{ REG_0008[15:0] };
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
assign	{regfile.general__mem_save_words_upper }	=	{ REG_0009[15:0] };
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





//REGISTER REG_000a
assign	{regfile.general__mem_save_words_lower }	=	{ REG_000a[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_000a[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'ha) begin
			{ REG_000a[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_000b
assign	{regfile.general__mem_save_buffer_addr }	=	{ REG_000b[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ REG_000b[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'hb) begin
			{ REG_000b[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER REG_0040
assign	{REG_0040[15:0] }	=	{ regfile.general__status };





//REGISTER REG_0041
assign	{REG_0041[1:1],REG_0041[0:0] }	=	{ regfile.general__buffer_saved,regfile.general__buffer_loaded };





//REGISTER REG_0080
assign	{REG_0080[9:9],REG_0080[8:8],REG_0080[7:7],REG_0080[6:6],REG_0080[5:5],REG_0080[4:4],REG_0080[3:3],REG_0080[2:2],REG_0080[1:1],REG_0080[0:0] }	=	{ 1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0 };
//WOC fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		regfile.general__start_wr <= #1 1'h0;
		regfile.general__start_wr_en <= #1 0;
		regfile.general__abrupt_end_wr <= #1 1'h0;
		regfile.general__abrupt_end_wr_en <= #1 0;
		regfile.general__reset_wr <= #1 1'h0;
		regfile.general__reset_wr_en <= #1 0;
		regfile.general__digital_reset_wr <= #1 1'h0;
		regfile.general__digital_reset_wr_en <= #1 0;
		regfile.general__flush_buff1_to_ext_mem_wr <= #1 1'h0;
		regfile.general__flush_buff1_to_ext_mem_wr_en <= #1 0;
		regfile.general__flush_buff2_to_ext_mem_wr <= #1 1'h0;
		regfile.general__flush_buff2_to_ext_mem_wr_en <= #1 0;
		regfile.general__load_buff1_from_ext_mem_wr <= #1 1'h0;
		regfile.general__load_buff1_from_ext_mem_wr_en <= #1 0;
		regfile.general__load_buff2_from_ext_mem_wr <= #1 1'h0;
		regfile.general__load_buff2_from_ext_mem_wr_en <= #1 0;
		regfile.general__start_loading_buffer_wr <= #1 1'h0;
		regfile.general__start_loading_buffer_wr_en <= #1 0;
		regfile.general__start_saving_buffer_wr <= #1 1'h0;
		regfile.general__start_saving_buffer_wr_en <= #1 0;
	end else begin
		if (wr_en && addr == 14'h80) begin
			regfile.general__start_wr <= #1 write_data[0:0];
			regfile.general__start_wr_en <= #1 1;
			regfile.general__abrupt_end_wr <= #1 write_data[1:1];
			regfile.general__abrupt_end_wr_en <= #1 1;
			regfile.general__reset_wr <= #1 write_data[2:2];
			regfile.general__reset_wr_en <= #1 1;
			regfile.general__digital_reset_wr <= #1 write_data[3:3];
			regfile.general__digital_reset_wr_en <= #1 1;
			regfile.general__flush_buff1_to_ext_mem_wr <= #1 write_data[4:4];
			regfile.general__flush_buff1_to_ext_mem_wr_en <= #1 1;
			regfile.general__flush_buff2_to_ext_mem_wr <= #1 write_data[5:5];
			regfile.general__flush_buff2_to_ext_mem_wr_en <= #1 1;
			regfile.general__load_buff1_from_ext_mem_wr <= #1 write_data[6:6];
			regfile.general__load_buff1_from_ext_mem_wr_en <= #1 1;
			regfile.general__load_buff2_from_ext_mem_wr <= #1 write_data[7:7];
			regfile.general__load_buff2_from_ext_mem_wr_en <= #1 1;
			regfile.general__start_loading_buffer_wr <= #1 write_data[8:8];
			regfile.general__start_loading_buffer_wr_en <= #1 1;
			regfile.general__start_saving_buffer_wr <= #1 write_data[9:9];
			regfile.general__start_saving_buffer_wr_en <= #1 1;
		end else begin
		regfile.general__start_wr <= #1 1'h0;
		regfile.general__start_wr_en <= #1 0;
		regfile.general__abrupt_end_wr <= #1 1'h0;
		regfile.general__abrupt_end_wr_en <= #1 0;
		regfile.general__reset_wr <= #1 1'h0;
		regfile.general__reset_wr_en <= #1 0;
		regfile.general__digital_reset_wr <= #1 1'h0;
		regfile.general__digital_reset_wr_en <= #1 0;
		regfile.general__flush_buff1_to_ext_mem_wr <= #1 1'h0;
		regfile.general__flush_buff1_to_ext_mem_wr_en <= #1 0;
		regfile.general__flush_buff2_to_ext_mem_wr <= #1 1'h0;
		regfile.general__flush_buff2_to_ext_mem_wr_en <= #1 0;
		regfile.general__load_buff1_from_ext_mem_wr <= #1 1'h0;
		regfile.general__load_buff1_from_ext_mem_wr_en <= #1 0;
		regfile.general__load_buff2_from_ext_mem_wr <= #1 1'h0;
		regfile.general__load_buff2_from_ext_mem_wr_en <= #1 0;
		regfile.general__start_loading_buffer_wr <= #1 1'h0;
		regfile.general__start_loading_buffer_wr_en <= #1 0;
		regfile.general__start_saving_buffer_wr <= #1 1'h0;
		regfile.general__start_saving_buffer_wr_en <= #1 0;
		end
	end
end







endmodule


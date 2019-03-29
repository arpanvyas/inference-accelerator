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
	output	logic	[15:0]	REG_0004__mem_save_start_upper,

	//REG_0005
	output	logic	[15:0]	REG_0005__mem_save_start_lower,

	//REG_0006
	output	logic	[15:0]	REG_0006__status,

	//REG_0007
	output	logic			REG_0007__flush_buff2_to_ext_mem_wr,
	output	logic			REG_0007__flush_buff2_to_ext_mem_wr_en,
	output	logic			REG_0007__abrupt_end_wr,
	output	logic			REG_0007__abrupt_end_wr_en,
	output	logic			REG_0007__reset_wr,
	output	logic			REG_0007__reset_wr_en,
	output	logic			REG_0007__digital_reset_wr,
	output	logic			REG_0007__digital_reset_wr_en,
	output	logic			REG_0007__flush_buff1_to_ext_mem_wr,
	output	logic			REG_0007__flush_buff1_to_ext_mem_wr_en,
	output	logic			REG_0007__load_buff1_from_ext_mem_wr,
	output	logic			REG_0007__load_buff1_from_ext_mem_wr_en,
	output	logic			REG_0007__load_buff2_from_ext_mem_wr,
	output	logic			REG_0007__load_buff2_from_ext_mem_wr_en
	);

//DECLARATIONS
logic	[15:0]	REG_0001;
logic	[15:0]	REG_0002;
logic	[15:0]	REG_0003;
logic	[15:0]	REG_0004;
logic	[15:0]	REG_0005;
logic	[15:0]	REG_0006;
logic	[15:0]	REG_0007;

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
assign	{REG_0004__mem_save_start_upper }	=	{ REG_0004[15:0] };
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
assign	{REG_0005__mem_save_start_lower }	=	{ REG_0005[15:0] };
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
assign	{REG_0006__status }	=	{ REG_0006[15:0] };
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
assign	{REG_0007[6:6],REG_0007[5:5],REG_0007[4:4],REG_0007[3:3],REG_0007[2:2],REG_0007[1:1],REG_0007[0:0] }	=	{ 1'h0,1'h0,1'h0,1'h0,1'h0,1'h0,1'h0 };
//WOC fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		REG_0007__flush_buff2_to_ext_mem_wr <= #1 1'h0;
		REG_0007__abrupt_end_wr <= #1 1'h0;
		REG_0007__reset_wr <= #1 1'h0;
		REG_0007__digital_reset_wr <= #1 1'h0;
		REG_0007__flush_buff1_to_ext_mem_wr <= #1 1'h0;
		REG_0007__load_buff1_from_ext_mem_wr <= #1 1'h0;
		REG_0007__load_buff2_from_ext_mem_wr <= #1 1'h0;
	end else begin
		if (wr_en && addr == 14'h7) begin
			REG_0007__flush_buff2_to_ext_mem_wr <= #1 write_data[0:0];
			REG_0007__flush_buff2_to_ext_mem_wr_en <= #1 1;
			REG_0007__abrupt_end_wr <= #1 write_data[1:1];
			REG_0007__abrupt_end_wr_en <= #1 1;
			REG_0007__reset_wr <= #1 write_data[2:2];
			REG_0007__reset_wr_en <= #1 1;
			REG_0007__digital_reset_wr <= #1 write_data[3:3];
			REG_0007__digital_reset_wr_en <= #1 1;
			REG_0007__flush_buff1_to_ext_mem_wr <= #1 write_data[4:4];
			REG_0007__flush_buff1_to_ext_mem_wr_en <= #1 1;
			REG_0007__load_buff1_from_ext_mem_wr <= #1 write_data[5:5];
			REG_0007__load_buff1_from_ext_mem_wr_en <= #1 1;
			REG_0007__load_buff2_from_ext_mem_wr <= #1 write_data[6:6];
			REG_0007__load_buff2_from_ext_mem_wr_en <= #1 1;
		end
	end
end







endmodule


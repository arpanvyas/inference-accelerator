module regfile_conv (
	input	logic		clk,
	input	logic		rst,
	input	logic		wr_en,
	input	logic		rd_en,
	input	logic	[13:0]	addr,
	input	logic	[15:0]	write_data,
	output	logic	[15:0]	read_data_CONV,
	regfile_interface	regfile
);

//DECLARATIONS
logic	[15:0]	CONV_0001;
logic	[15:0]	CONV_0002;
logic	[15:0]	CONV_0003;
logic	[15:0]	CONV_0004;
logic	[15:0]	CONV_0005;
logic	[15:0]	CONV_0006;
logic	[15:0]	CONV_0007;
logic	[15:0]	CONV_0008;
logic	[15:0]	CONV_0009;
logic	[15:0]	CONV_0010;
logic	[15:0]	CONV_0011;
logic	[15:0]	CONV_0012;
logic	[15:0]	CONV_0013;
logic	[15:0]	CONV_0014;
logic	[15:0]	CONV_0015;
logic	[15:0]	CONV_0016;
logic	[15:0]	CONV_0017;
logic	[15:0]	CONV_0018;
logic	[15:0]	CONV_0019;
logic	[15:0]	CONV_0020;

//READ REGISTER
always@(*)
begin
	case (addr)
		14'h101 : read_data_CONV = CONV_0001;
		14'h102 : read_data_CONV = CONV_0002;
		14'h103 : read_data_CONV = CONV_0003;
		14'h104 : read_data_CONV = CONV_0004;
		14'h105 : read_data_CONV = CONV_0005;
		14'h106 : read_data_CONV = CONV_0006;
		14'h107 : read_data_CONV = CONV_0007;
		14'h108 : read_data_CONV = CONV_0008;
		14'h109 : read_data_CONV = CONV_0009;
		14'h10a : read_data_CONV = CONV_0010;
		14'h10b : read_data_CONV = CONV_0011;
		14'h10c : read_data_CONV = CONV_0012;
		14'h10d : read_data_CONV = CONV_0013;
		14'h10e : read_data_CONV = CONV_0014;
		14'h10f : read_data_CONV = CONV_0015;
		14'h110 : read_data_CONV = CONV_0016;
		14'h111 : read_data_CONV = CONV_0017;
		14'h112 : read_data_CONV = CONV_0018;
		14'h113 : read_data_CONV = CONV_0019;
		14'h114 : read_data_CONV = CONV_0020;
		default : read_data_CONV = 16'h0;
	endcase
end


//REGISTER CONV_0001
assign	{regfile.conv__data_wid }	=	{ CONV_0001[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0001[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h101) begin
			{ CONV_0001[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0002
assign	{regfile.conv__data_hei }	=	{ CONV_0002[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0002[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h102) begin
			{ CONV_0002[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0003
assign	{regfile.conv__data_ch }	=	{ CONV_0003[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0003[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h103) begin
			{ CONV_0003[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0004
assign	{regfile.conv__filter_wid }	=	{ CONV_0004[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0004[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h104) begin
			{ CONV_0004[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0005
assign	{regfile.conv__filter_hei }	=	{ CONV_0005[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0005[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h105) begin
			{ CONV_0005[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0006
assign	{CONV_0006[15:0] }	=	{ regfile.conv__filter_ch };





//REGISTER CONV_0007
assign	{regfile.conv__filter_num }	=	{ CONV_0007[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0007[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h107) begin
			{ CONV_0007[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0008
assign	{regfile.conv__stride_vert,regfile.conv__stride_horiz }	=	{ CONV_0008[15:8],CONV_0008[7:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0008[15:8],CONV_0008[7:0] } <= #1 { 8'h0,8'h0 };
	end else begin
		if (wr_en && addr == 14'h108) begin
			{ CONV_0008[15:8],CONV_0008[7:0] } <= #1 { write_data[15:8],write_data[7:0] };
		end
	end
end





//REGISTER CONV_0009
assign	{regfile.conv__data_load_msb }	=	{ CONV_0009[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0009[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h109) begin
			{ CONV_0009[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0010
assign	{regfile.conv__data_load_lsb }	=	{ CONV_0010[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0010[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h10a) begin
			{ CONV_0010[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0011
assign	{regfile.conv__filter_load_msb }	=	{ CONV_0011[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0011[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h10b) begin
			{ CONV_0011[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0012
assign	{regfile.conv__filter_load_lsb }	=	{ CONV_0012[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0012[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h10c) begin
			{ CONV_0012[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0013
assign	{regfile.conv__output_save_msb }	=	{ CONV_0013[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0013[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h10d) begin
			{ CONV_0013[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0014
assign	{regfile.conv__output_save_lsb }	=	{ CONV_0014[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0014[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h10e) begin
			{ CONV_0014[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER CONV_0015
assign	{CONV_0015[15:0] }	=	{ regfile.conv__data_status_cin };





//REGISTER CONV_0016
assign	{CONV_0016[15:0] }	=	{ regfile.conv__data_status_cout };





//REGISTER CONV_0017
assign	{CONV_0017[3:0] }	=	{ regfile.conv__status };





//REGISTER CONV_0018
assign	{regfile.conv__padding_vert,regfile.conv__padding_horiz }	=	{ CONV_0018[7:4],CONV_0018[3:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ CONV_0018[7:4],CONV_0018[3:0] } <= #1 { 4'h1,4'h1 };
	end else begin
		if (wr_en && addr == 14'h112) begin
			{ CONV_0018[7:4],CONV_0018[3:0] } <= #1 { write_data[7:4],write_data[3:0] };
		end
	end
end





//REGISTER CONV_0019
assign	{CONV_0019[15:0] }	=	{ regfile.conv__out_data_wid };





//REGISTER CONV_0020
assign	{CONV_0020[15:0] }	=	{ regfile.conv__out_data_hei };







endmodule


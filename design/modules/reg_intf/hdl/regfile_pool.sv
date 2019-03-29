module regfile_pool (
	input	logic		clk,
	input	logic		rst,
	input	logic		wr_en,
	input	logic		rd_en,
	input	logic	[13:0]	addr,
	input	logic	[15:0]	write_data,
	output	logic	[15:0]	read_data_POOL,

	//POOL_0001
	output	logic	[15:0]	POOL_0001__data_wid,

	//POOL_0002
	output	logic	[15:0]	POOL_0002__data_hei,

	//POOL_0003
	output	logic	[15:0]	POOL_0003__data_ch,

	//POOL_0004
	output	logic	[15:0]	POOL_0004__pool_type,

	//POOL_0005
	output	logic	[15:0]	POOL_0005__pool_horiz,

	//POOL_0006
	output	logic	[15:0]	POOL_0006__pool_vert,

	//POOL_0007
	output	logic	[15:0]	POOL_0007__pool_horiz_stride,

	//POOL_0008
	output	logic	[15:0]	POOL_0008__pool_vert_stride,

	//POOL_0009
	input	logic	[15:0]	POOL_0009__output_wid,

	//POOL_0010
	input	logic	[15:0]	POOL_0010__output_hei,

	//POOL_0011
	input	logic	[15:0]	POOL_0011__output_ch
	);

//DECLARATIONS
logic	[15:0]	POOL_0001;
logic	[15:0]	POOL_0002;
logic	[15:0]	POOL_0003;
logic	[15:0]	POOL_0004;
logic	[15:0]	POOL_0005;
logic	[15:0]	POOL_0006;
logic	[15:0]	POOL_0007;
logic	[15:0]	POOL_0008;
logic	[15:0]	POOL_0009;
logic	[15:0]	POOL_0010;
logic	[15:0]	POOL_0011;

//READ REGISTER
always@(*)
begin
	case (addr)
		14'h201 : read_data_POOL = POOL_0001;
		14'h202 : read_data_POOL = POOL_0002;
		14'h203 : read_data_POOL = POOL_0003;
		14'h204 : read_data_POOL = POOL_0004;
		14'h205 : read_data_POOL = POOL_0005;
		14'h206 : read_data_POOL = POOL_0006;
		14'h207 : read_data_POOL = POOL_0007;
		14'h208 : read_data_POOL = POOL_0008;
		14'h209 : read_data_POOL = POOL_0009;
		14'h20a : read_data_POOL = POOL_0010;
		14'h20b : read_data_POOL = POOL_0011;
		default : read_data_POOL = 16'h0;
	endcase
end


//REGISTER POOL_0001
assign	{POOL_0001__data_wid }	=	{ POOL_0001[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ POOL_0001[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h201) begin
			{ POOL_0001[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER POOL_0002
assign	{POOL_0002__data_hei }	=	{ POOL_0002[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ POOL_0002[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h202) begin
			{ POOL_0002[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER POOL_0003
assign	{POOL_0003__data_ch }	=	{ POOL_0003[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ POOL_0003[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h203) begin
			{ POOL_0003[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER POOL_0004
assign	{POOL_0004__pool_type }	=	{ POOL_0004[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ POOL_0004[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h204) begin
			{ POOL_0004[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER POOL_0005
assign	{POOL_0005__pool_horiz }	=	{ POOL_0005[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ POOL_0005[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h205) begin
			{ POOL_0005[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER POOL_0006
assign	{POOL_0006__pool_vert }	=	{ POOL_0006[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ POOL_0006[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h206) begin
			{ POOL_0006[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER POOL_0007
assign	{POOL_0007__pool_horiz_stride }	=	{ POOL_0007[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ POOL_0007[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h207) begin
			{ POOL_0007[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER POOL_0008
assign	{POOL_0008__pool_vert_stride }	=	{ POOL_0008[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ POOL_0008[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h208) begin
			{ POOL_0008[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER POOL_0009
assign	{POOL_0009[15:0] }	=	{ POOL_0009__output_wid };





//REGISTER POOL_0010
assign	{POOL_0010[15:0] }	=	{ POOL_0010__output_hei };





//REGISTER POOL_0011
assign	{POOL_0011[15:0] }	=	{ POOL_0011__output_ch };







endmodule


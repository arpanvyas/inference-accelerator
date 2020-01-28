module regfile_dense (
	input	logic		clk,
	input	logic		rst,
	input	logic		wr_en,
	input	logic		rd_en,
	input	logic	[13:0]	addr,
	input	logic	[15:0]	write_data,
	output	logic	[15:0]	read_data_DENSE,
	interface_regfile	regfile
);

//DECLARATIONS
logic	[15:0]	DENSE_0001;
logic	[15:0]	DENSE_0002;
logic	[15:0]	DENSE_0003;
logic	[15:0]	DENSE_0004;
logic	[15:0]	DENSE_0005;
logic	[15:0]	DENSE_0006;
logic	[15:0]	DENSE_0007;
logic	[15:0]	DENSE_0008;
logic	[15:0]	DENSE_0009;
logic	[15:0]	DENSE_0010;
logic	[15:0]	DENSE_0011;
logic	[15:0]	DENSE_0012;

//READ REGISTER
always@(*)
begin
	case (addr)
		14'h401 : read_data_DENSE = DENSE_0001;
		14'h402 : read_data_DENSE = DENSE_0002;
		14'h403 : read_data_DENSE = DENSE_0003;
		14'h404 : read_data_DENSE = DENSE_0004;
		14'h405 : read_data_DENSE = DENSE_0005;
		14'h406 : read_data_DENSE = DENSE_0006;
		14'h407 : read_data_DENSE = DENSE_0007;
		14'h408 : read_data_DENSE = DENSE_0008;
		14'h409 : read_data_DENSE = DENSE_0009;
		14'h40a : read_data_DENSE = DENSE_0010;
		14'h40b : read_data_DENSE = DENSE_0011;
		14'h40c : read_data_DENSE = DENSE_0012;
		default : read_data_DENSE = 16'h0;
	endcase
end


//REGISTER DENSE_0001
assign	{regfile.dense__input_data_type }	=	{ DENSE_0001[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ DENSE_0001[15:0] } <= #1 { 16'h1 };
	end else begin
		if (wr_en && addr == 14'h401) begin
			{ DENSE_0001[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER DENSE_0002
assign	{regfile.dense__data_wid }	=	{ DENSE_0002[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ DENSE_0002[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h402) begin
			{ DENSE_0002[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER DENSE_0003
assign	{regfile.dense__data_hei }	=	{ DENSE_0003[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ DENSE_0003[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h403) begin
			{ DENSE_0003[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER DENSE_0004
assign	{regfile.dense__data_ch }	=	{ DENSE_0004[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ DENSE_0004[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h404) begin
			{ DENSE_0004[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER DENSE_0005
assign	{DENSE_0005[15:0] }	=	{ regfile.dense__output_wid };





//REGISTER DENSE_0006
assign	{DENSE_0006[15:0] }	=	{ regfile.dense__output_hei };





//REGISTER DENSE_0007
assign	{DENSE_0007[15:0] }	=	{ regfile.dense__output_ch };





//REGISTER DENSE_0008
assign	{regfile.dense__input_data_length }	=	{ DENSE_0008[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ DENSE_0008[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h408) begin
			{ DENSE_0008[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER DENSE_0009
assign	{regfile.dense__output_data_length }	=	{ DENSE_0009[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ DENSE_0009[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h409) begin
			{ DENSE_0009[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER DENSE_0010
assign	{DENSE_0010[15:0] }	=	{ regfile.dense__wid_weight_matrix };





//REGISTER DENSE_0011
assign	{DENSE_0011[15:0] }	=	{ regfile.dense__hei_weight_matrix };





//REGISTER DENSE_0012
assign	{regfile.dense__use_bias }	=	{ DENSE_0012[0:0] };
assign	{DENSE_0012[15:1] }	=	{ regfile.dense__reserved_1 };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ DENSE_0012[0:0] } <= #1 { 1'h1 };
	end else begin
		if (wr_en && addr == 14'h40c) begin
			{ DENSE_0012[0:0] } <= #1 { write_data[0:0] };
		end
	end
end







endmodule


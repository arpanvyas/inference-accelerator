module regfile_nl (
	input	logic		clk,
	input	logic		rst,
	input	logic		wr_en,
	input	logic		rd_en,
	input	logic	[13:0]	addr,
	input	logic	[15:0]	write_data,
	output	logic	[15:0]	read_data_NL,
	interface_regfile	regfile
);

//DECLARATIONS
logic	[15:0]	NL_0001;
logic	[15:0]	NL_0002;
logic	[15:0]	NL_0003;
logic	[15:0]	NL_0004;
logic	[15:0]	NL_0005;
logic	[15:0]	NL_0006;
logic	[15:0]	NL_0007;
logic	[15:0]	NL_0008;
logic	[15:0]	NL_0009;
logic	[15:0]	NL_0010;

//READ REGISTER
always@(*)
begin
	case (addr)
		14'h301 : read_data_NL = NL_0001;
		14'h302 : read_data_NL = NL_0002;
		14'h303 : read_data_NL = NL_0003;
		14'h304 : read_data_NL = NL_0004;
		14'h305 : read_data_NL = NL_0005;
		14'h306 : read_data_NL = NL_0006;
		14'h307 : read_data_NL = NL_0007;
		14'h308 : read_data_NL = NL_0008;
		14'h309 : read_data_NL = NL_0009;
		14'h30a : read_data_NL = NL_0010;
		default : read_data_NL = 16'h0;
	endcase
end


//REGISTER NL_0001
assign	{regfile.nl__data_wid }	=	{ NL_0001[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ NL_0001[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h301) begin
			{ NL_0001[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER NL_0002
assign	{regfile.nl__data_hei }	=	{ NL_0002[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ NL_0002[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h302) begin
			{ NL_0002[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER NL_0003
assign	{regfile.nl__data_ch }	=	{ NL_0003[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ NL_0003[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h303) begin
			{ NL_0003[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER NL_0004
assign	{regfile.nl__nl_type }	=	{ NL_0004[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ NL_0004[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h304) begin
			{ NL_0004[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER NL_0005
assign	{NL_0005[15:0] }	=	{ regfile.nl__output_wid };





//REGISTER NL_0006
assign	{NL_0006[15:0] }	=	{ regfile.nl__output_hei };





//REGISTER NL_0007
assign	{NL_0007[15:0] }	=	{ regfile.nl__output_ch };





//REGISTER NL_0008
assign	{regfile.nl__input_data_format }	=	{ NL_0008[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ NL_0008[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h308) begin
			{ NL_0008[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER NL_0009
assign	{regfile.nl__input_data_length }	=	{ NL_0009[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ NL_0009[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h309) begin
			{ NL_0009[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER NL_0010
assign	{NL_0010[15:0] }	=	{ regfile.nl__output_data_length };







endmodule


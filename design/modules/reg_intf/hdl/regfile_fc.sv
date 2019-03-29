module regfile_fc (
	input	logic		clk,
	input	logic		rst,
	input	logic		wr_en,
	input	logic		rd_en,
	input	logic	[13:0]	addr,
	input	logic	[15:0]	write_data,
	output	logic	[15:0]	read_data_FC,

	//FC_0001
	output	logic	[15:0]	FC_0001__input_data_type,

	//FC_0002
	output	logic	[15:0]	FC_0002__data_wid,

	//FC_0003
	output	logic	[15:0]	FC_0003__data_hei,

	//FC_0004
	output	logic	[15:0]	FC_0004__data_ch,

	//FC_0005
	input	logic	[15:0]	FC_0005__output_wid,

	//FC_0006
	input	logic	[15:0]	FC_0006__output_hei,

	//FC_0007
	input	logic	[15:0]	FC_0007__output_ch,

	//FC_0008
	output	logic	[15:0]	FC_0008__input_data_length,

	//FC_0009
	output	logic	[15:0]	FC_0009__output_data_length,

	//FC_0010
	input	logic	[15:0]	FC_0010__wid_weight_matrix,

	//FC_0011
	input	logic	[15:0]	FC_0011__hei_weight_matrix
	);

//DECLARATIONS
logic	[15:0]	FC_0001;
logic	[15:0]	FC_0002;
logic	[15:0]	FC_0003;
logic	[15:0]	FC_0004;
logic	[15:0]	FC_0005;
logic	[15:0]	FC_0006;
logic	[15:0]	FC_0007;
logic	[15:0]	FC_0008;
logic	[15:0]	FC_0009;
logic	[15:0]	FC_0010;
logic	[15:0]	FC_0011;

//READ REGISTER
always@(*)
begin
	case (addr)
		14'h401 : read_data_FC = FC_0001;
		14'h402 : read_data_FC = FC_0002;
		14'h403 : read_data_FC = FC_0003;
		14'h404 : read_data_FC = FC_0004;
		14'h405 : read_data_FC = FC_0005;
		14'h406 : read_data_FC = FC_0006;
		14'h407 : read_data_FC = FC_0007;
		14'h408 : read_data_FC = FC_0008;
		14'h409 : read_data_FC = FC_0009;
		14'h40a : read_data_FC = FC_0010;
		14'h40b : read_data_FC = FC_0011;
		default : read_data_FC = 16'h0;
	endcase
end


//REGISTER FC_0001
assign	{FC_0001__input_data_type }	=	{ FC_0001[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ FC_0001[15:0] } <= #1 { 16'h1 };
	end else begin
		if (wr_en && addr == 14'h401) begin
			{ FC_0001[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER FC_0002
assign	{FC_0002__data_wid }	=	{ FC_0002[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ FC_0002[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h402) begin
			{ FC_0002[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER FC_0003
assign	{FC_0003__data_hei }	=	{ FC_0003[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ FC_0003[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h403) begin
			{ FC_0003[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER FC_0004
assign	{FC_0004__data_ch }	=	{ FC_0004[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ FC_0004[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h404) begin
			{ FC_0004[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER FC_0005
assign	{FC_0005[15:0] }	=	{ FC_0005__output_wid };





//REGISTER FC_0006
assign	{FC_0006[15:0] }	=	{ FC_0006__output_hei };





//REGISTER FC_0007
assign	{FC_0007[15:0] }	=	{ FC_0007__output_ch };





//REGISTER FC_0008
assign	{FC_0008__input_data_length }	=	{ FC_0008[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ FC_0008[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h408) begin
			{ FC_0008[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER FC_0009
assign	{FC_0009__output_data_length }	=	{ FC_0009[15:0] };
//RW fields
always@(posedge clk, posedge rst) begin
	if (rst) begin
		{ FC_0009[15:0] } <= #1 { 16'h0 };
	end else begin
		if (wr_en && addr == 14'h409) begin
			{ FC_0009[15:0] } <= #1 { write_data[15:0] };
		end
	end
end





//REGISTER FC_0010
assign	{FC_0010[15:0] }	=	{ FC_0010__wid_weight_matrix };





//REGISTER FC_0011
assign	{FC_0011[15:0] }	=	{ FC_0011__hei_weight_matrix };







endmodule


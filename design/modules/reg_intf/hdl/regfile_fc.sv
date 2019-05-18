module regfile_fc (
	input	logic		clk,
	input	logic		rst,
	input	logic		wr_en,
	input	logic		rd_en,
	input	logic	[13:0]	addr,
	input	logic	[15:0]	write_data,
	output	logic	[15:0]	read_data_FC,
	regfile_interface	regfile
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
assign	{regfile.fc__input_data_type }	=	{ FC_0001[15:0] };
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
assign	{regfile.fc__data_wid }	=	{ FC_0002[15:0] };
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
assign	{regfile.fc__data_hei }	=	{ FC_0003[15:0] };
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
assign	{regfile.fc__data_ch }	=	{ FC_0004[15:0] };
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
assign	{FC_0005[15:0] }	=	{ regfile.fc__output_wid };





//REGISTER FC_0006
assign	{FC_0006[15:0] }	=	{ regfile.fc__output_hei };





//REGISTER FC_0007
assign	{FC_0007[15:0] }	=	{ regfile.fc__output_ch };





//REGISTER FC_0008
assign	{regfile.fc__input_data_length }	=	{ FC_0008[15:0] };
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
assign	{regfile.fc__output_data_length }	=	{ FC_0009[15:0] };
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
assign	{FC_0010[15:0] }	=	{ regfile.fc__wid_weight_matrix };





//REGISTER FC_0011
assign	{FC_0011[15:0] }	=	{ regfile.fc__hei_weight_matrix };







endmodule


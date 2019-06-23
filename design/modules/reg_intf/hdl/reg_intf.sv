module reg_intf(
    input  clk,
    input  rst,

    //SPI Slave Signals
    input  SCLK,
    input  MOSI,
    input  SS,
    output MISO,

    //Program Driver Signals
    input  wr_en_drv,
    input logic rd_en_drv,
    input logic [13:0] addr_drv,
    input logic [15:0] write_data_drv,
    output logic [15:0] read_data_drv,
    
    //Register Fields Signals 
    interface_regfile regfile,

    //From Controller
    input logic spi_or_driver 
);


//INSTANTIATING spi_slave_inst

logic                   clk;
logic                   rst;
logic                   MOSI;
logic                   SCLK;
logic                   SS;
logic                   MISO;
logic   [15:0]          tx_data_spi;
logic   [13:0]          rx_addr_spi;
logic   [15:0]          rx_data_spi;

logic                   rd_en_stretch_spi;
logic                   wr_en_stretch_spi;

spi_slave spi_slave_inst (
        .clk(clk),
        .rst(rst),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .SS(SS),
        .MISO(MISO),
        //Input
        .tx_data(tx_data_spi),
        //Output
        .rx_addr(rx_addr_spi),
        .rx_data(rx_data_spi),
        .rd_en_stretch(rd_en_stretch_spi),
        .wr_en_stretch(wr_en_stretch_spi)
);

///////////////////////////////////////////////
//SPI vs Driver Instance
///////////////////////////////////////////////

logic   [15:0]      read_data;
logic   [15:0]      write_data;
logic   [13:0]      addr;

reg_intf_mux reg_intf_mux_inst (
    .clk(clk),
    .rst(rst),

    .spi_or_driver(spi_or_driver),

    .rd_en_stretch_spi(rd_en_stretch_spi),
    .wr_en_stretch_spi(wr_en_stretch_spi),
    .addr_spi(rx_addr_spi),
    .read_data_spi(tx_data_spi),
    .write_data_spi(rx_data_spi),

    .wr_en_drv(wr_en_drv),
    .rd_en_drv(rd_en_drv),
    .addr_drv(addr_drv),
    .write_data_drv(write_data_drv),
    .read_data_drv(read_data_drv),

    .wr_en(wr_en),
    .rd_en(rd_en),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
);





//CODE FROM THIS POINT TO BE CHANGED ON CHANGING REGISTERFILE(S)

logic	[15:0]		read_data_GENERAL;
logic	[15:0]		read_data_CONV;
logic	[15:0]		read_data_POOL;
logic	[15:0]		read_data_NL;
logic	[15:0]		read_data_DENSE;

always@(*)
begin
    case(addr[13:9])
        5'h00 : read_data = read_data_GENERAL;
        5'h01 : read_data = read_data_CONV;
        5'h02 : read_data = read_data_POOL;
        5'h03 : read_data = read_data_NL;
        5'h04 : read_data = read_data_DENSE;
        default : read_data = 16'h0; 
    endcase
end



//INSTANTIATING regfile_general_inst

regfile_general regfile_general_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_GENERAL(read_data_GENERAL),
    .regfile(regfile)
);

//INSTANTIATING regfile_conv_inst


regfile_conv regfile_conv_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_CONV(read_data_CONV),
    .regfile(regfile)
);

//INSTANTIATING regfile_dense_inst

regfile_dense regfile_dense_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_DENSE(read_data_DENSE),
    .regfile(regfile)
);

//INSTANTIATING regfile_nl_inst

regfile_nl regfile_nl_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_NL(read_data_NL),
    .regfile(regfile)
);

//INSTANTIATING regfile_pool_inst

regfile_pool regfile_pool_inst (
	.clk(clk),
	.rst(rst),
	.wr_en(wr_en),
	.rd_en(rd_en),
	.addr(addr),
	.write_data(write_data),
	.read_data_POOL(read_data_POOL),
    .regfile(regfile)
);

endmodule

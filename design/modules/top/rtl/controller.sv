module controller (
    input logic clk,
    input logic rst,

    //SPI Slave Signals
    input  SCLK,
    input  MOSI,
    input  SS,
    output MISO


);

//INSTANTIATING program_driver_inst

logic			wr_en_drv;
logic			rd_en_drv;
logic	[13:0]		addr_drv;
logic	[15:0]		write_data_drv;
logic	[15:0]		read_data_drv;

logic           run_program;
logic           done_executing;
logic  [31:0]   pc_max;
logic           spi_or_driver;

assign run_program = 1;
assign done_executing = 1;
assign spi_or_driver = 0;
assign pc_max = 16282;


program_driver program_driver_inst (
	.clk(clk),
	.rst(rst),
    .run_program(run_program),
    .done_executing(done_executing),
    .pc_max(pc_max),
	.wr_en_drv(wr_en_drv),
	.rd_en_drv(rd_en_drv),
	.addr_drv(addr_drv),
	.write_data_drv(write_data_drv),
	.read_data_drv(read_data_drv)
);


//INSTANTIATING reg_intf_inst

logic			SCLK;
logic			MOSI;
logic			SS;
logic			MISO;

reg_intf reg_intf_inst (
	.clk(clk),
	.rst(rst),
	.SCLK(SCLK),
	.MOSI(MOSI),
	.SS(SS),
	.MISO(MISO),
	.wr_en_drv(wr_en_drv),
	.rd_en_drv(rd_en_drv),
	.addr_drv(addr_drv),
	.write_data_drv(write_data_drv),
	.read_data_drv(read_data_drv),
    .spi_or_driver(spi_or_driver)
);







endmodule

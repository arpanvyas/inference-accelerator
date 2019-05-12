module reg_intf_mux (
    input logic clk,
    input logic rst,

    input logic spi_or_driver,

    input logic wr_en_stretch_spi,
    input logic rd_en_stretch_spi,
    input logic [13:0] addr_spi,
    input logic [15:0] write_data_spi,
    output logic [15:0] read_data_spi,

    input logic wr_en_drv,
    input logic rd_en_drv,
    input logic [13:0] addr_drv,
    input logic [15:0] write_data_drv,
    output logic [15:0] read_data_drv,

    output logic wr_en,
    output logic rd_en,
    output logic [13:0] addr,
    output logic [15:0] write_data,
    input logic [15:0] read_data

);

///////////////////////////////////////////////////
//SPI Slave Interfacing 
///////////////////////////////////////////////////
//Syncing rd_en and wr_en

logic rd_en_synced_spi;
logic wr_en_synced_spi;

sync_2s rd_en_stretch_spi_sync (
    .clk(clk), .d(rd_en_stretch_spi), .q(rd_en_synced_spi)
);

sync_2s wr_en_stretch_spi_sync (
    .clk(clk), .d(wr_en_stretch_spi), .q(wr_en_synced_spi)
);

//Getting single cycle rd_en and wr_en from synced (as their length uncertain)
logic rd_en_synced_hold_spi;
logic wr_en_synced_hold_spi;

logic rd_en_spi;
logic wr_en_spi;

always@(posedge clk, posedge rst)
begin
    if(rst) begin
        rd_en_synced_hold_spi <= #1 0;
        wr_en_synced_hold_spi <= #1 0;
    end else begin
        rd_en_synced_hold_spi <= #1 rd_en_synced_spi;
        wr_en_synced_hold_spi <= #1 wr_en_synced_spi;
    end
end

assign rd_en_spi = (!rd_en_synced_hold_spi && rd_en_synced_spi);
assign wr_en_spi = (!wr_en_synced_hold_spi && wr_en_synced_spi);

///////////////////////////////////////////////////
//Program Driver Interface
///////////////////////////////////////////////////



///////////////////////////////////////////////////
//Muxing
///////////////////////////////////////////////////

assign rd_en = (spi_or_driver) ? rd_en_spi : rd_en_drv;
assign wr_en = (spi_or_driver) ? wr_en_spi : wr_en_drv;
assign addr  = (spi_or_driver) ? addr_spi  : addr_drv;
assign write_data = (spi_or_driver) ? write_data_spi : write_data_drv;
assign read_data_spi = (spi_or_driver) ? read_data : 'd0;
assign read_data_drv = (spi_or_driver) ? 'd0       : read_data;



endmodule

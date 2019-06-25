`include "header.vh"
interface interface_extmem;

logic   we;
logic   re;
logic   [`ADDR_EXT_RAM-1:0]      rd_addr;
logic   [`ADDR_EXT_RAM-1:0]      wr_addr;
logic   [`DATA_EXT_RAM-1:0]      rd_data;
logic   [`DATA_EXT_RAM-1:0]      wr_data;

endinterface;

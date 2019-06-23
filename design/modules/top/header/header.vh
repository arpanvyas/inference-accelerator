// header.vh
`ifndef _my_header_
`define _my_header_
// Start of include contents

//Overall data description
`define DATA_WIDTH 16

//external memory
`define ADDR_EXT_RAM 23
`define WID_EXT_RAM `DATA_WIDTH
`define DATA_EXT_RAM 16

//Memory Bank
`define ADDR_RAM 16
`define WID_RAM `DATA_WIDTH

//Controller
`define REG_BANK_SIZE 64
`define CONTR_STATES 14
`define CONTR_STATES_BITS 6



//PE Array
`define N_PE 32
`define LOG_N_PE $clog2(`N_PE)

`define LAT_MAC 3
`define LAT_ADD_TREE 5
`define LAT_FB_ADD 1
`define LAT_NL 1
`define LAT_DENSE_ADD 1
`define LAT_POOL 2
`define CONV_ROW_MAX 3
`define MAC_COL_MAX 3
`define DENSE_PER_GO `CONV_ROW_MAX * `MAC_COL_MAX

//Buffers
`define N_BUF `N_PE+1

//PE
`define WID_PE_BITS `DATA_WIDTH
`define N_CONV `N_PE
`define BUS_PE_BITS `N_CONV*`WID_PE_BITS

//Convolver 
`define WID_CONV_OUT `DATA_WIDTH

////Line Buffer
`define WID_LINE `DATA_WIDTH
//fifo
`define WID_FIFO `DATA_WIDTH
`define ADDR_FIFO 9
`define DEP_FIFO 2**`ADDR_FIFO

//Filter Buffer
`define	WID_FILTER	`DATA_WIDTH

////MAC
`define	WID_MAC_MULT	32//`DATA_WIDTH//32 //`WID_FIFO+`WID_LINE
`define	WID_MAC_OUT		36//`DATA_WIDTH//36 //`WID_MAC_MULT+4


//Some functions
`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST)    genvar pk_idx; generate for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) begin; assign PK_DEST[((PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):((PK_WIDTH)*pk_idx)] = PK_SRC[pk_idx][((PK_WIDTH)-1):0]; end; endgenerate
`define UNPACK_ARRAY(PK_WIDTH,PK_LEN,PK_DEST,PK_SRC)  genvar unpk_idx; generate for (unpk_idx=0; unpk_idx<(PK_LEN); unpk_idx=unpk_idx+1) begin; assign PK_DEST[unpk_idx][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*unpk_idx+(PK_WIDTH-1)):((PK_WIDTH)*unpk_idx)]; end; endgenerate















// Use parentheses to mitigate any undesired operator precedence issues
`endif 




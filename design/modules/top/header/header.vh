// header.vh
`ifndef _my_header_
`define _my_header_
// Start of include contents

//GLOBAL FREQUENTLY CHANGED DEFINES
`define DATA_WIDTH 16
`define SCALE      8  //usually DATA_WIDTH/2, this is the frac_size
//`define PC_MAX 73188
`define PC_MAX 86244 //alt
`define ADDR_FIFO 9 //size of the 2 fifos in each convolver
`define ADDR_RAM 16 //size of each one of `N_BUF memory banks
//`define NP4
//`define NP8
//`define NP16
`define NP32
//`define NP64
//`define NP128


//external memory
`define ADDR_EXT_RAM 21
`define WID_EXT_RAM `DATA_WIDTH
`define DATA_EXT_RAM `DATA_WIDTH

//Memory Bank
`define WID_RAM `DATA_WIDTH

//Controller
`define REG_BANK_SIZE 64
`define CONTR_STATES 14
`define CONTR_STATES_BITS 6
//`define PC_MAX 14628

//Regfile



//PE Array

`ifdef NP4      `define N_PE 4      `endif
`ifdef NP8      `define N_PE 8      `endif
`ifdef NP16     `define N_PE 16     `endif
`ifdef NP32     `define N_PE 32     `endif
`ifdef NP64     `define N_PE 64     `endif
`ifdef NP128    `define N_PE 128    `endif

`define LOG_N_PE $clog2(`N_PE)

`define LAT_READ_BUF 1
`define LAT_MAC 3
`define LAT_ADD_TREE `LOG_N_PE
`define LAT_FB_ADD 1
`define LAT_BIAS_ADD 1
`define LAT_NL 1
`define LAT_DENSE_ADD 1
`define LAT_POOL 2
`define CONV_ROW_MAX 3
`define MAC_COL_MAX 3
`define DENSE_PER_GO (`CONV_ROW_MAX*`MAC_COL_MAX)

//Buffers
`define N_BUF `N_PE+1
`define LOG_N_BUF $clog2(`N_BUF)

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
`define DEP_FIFO 2**`ADDR_FIFO

//Filter Buffer
`define	WID_FILTER	`DATA_WIDTH

////MAC
//`define	WID_MAC_MULT	16//`DATA_WIDTH//32 //`WID_FIFO+`WID_LINE
//`define	WID_MAC_OUT		16//`DATA_WIDTH//36 //`WID_MAC_MULT+4

`define	WID_MAC_MULT	`DATA_WIDTH//`DATA_WIDTH//32 //`WID_FIFO+`WID_LINE
`define	WID_MAC_OUT		`DATA_WIDTH//`DATA_WIDTH//36 //`WID_MAC_MULT+4


//Some functions
`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST)    genvar pk_idx; generate for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) begin; assign PK_DEST[((PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):((PK_WIDTH)*pk_idx)] = PK_SRC[pk_idx][((PK_WIDTH)-1):0]; end; endgenerate
`define UNPACK_ARRAY(PK_WIDTH,PK_LEN,PK_DEST,PK_SRC)  genvar unpk_idx; generate for (unpk_idx=0; unpk_idx<(PK_LEN); unpk_idx=unpk_idx+1) begin; assign PK_DEST[unpk_idx][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*unpk_idx+(PK_WIDTH-1)):((PK_WIDTH)*unpk_idx)]; end; endgenerate






`ifdef NP4
    `define TILL_NP4 
`endif

`ifdef NP8
    `define TILL_NP4
    `define TILL_NP8
`endif

`ifdef NP16
    `define TILL_NP4
    `define TILL_NP8
    `define TILL_NP16
`endif

`ifdef NP32
    `define TILL_NP4
    `define TILL_NP8
    `define TILL_NP16
    `define TILL_NP32
`endif

`ifdef NP64
    `define TILL_NP4
    `define TILL_NP8
    `define TILL_NP16
    `define TILL_NP32
    `define TILL_NP64
`endif

`ifdef NP128
    `define TILL_NP4
    `define TILL_NP8
    `define TILL_NP16
    `define TILL_NP32
    `define TILL_NP64
    `define TILL_NP128
`endif




// Use parentheses to mitigate any undesired operator precedence issues
`endif 




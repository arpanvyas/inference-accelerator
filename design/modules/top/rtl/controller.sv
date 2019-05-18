module controller (
    input logic clk,
    input logic rst,

    //SPI Slave Signals
    input  SCLK,
    input  MOSI,
    input  SS,
    output MISO,


//First Buffer
	output	logic		[1:0]						f_mode,
	output	logic		[`N_PE-1:0]					f_m0_r_en,
	output	logic		[`ADDR_RAM-1:0]				f_m0_r_addr,
	input			    [`WID_RAM-1:0]			    f_m0_r_data,
	output	logic		[`N_PE-1:0]					f_m0_w_en,
	output	logic		[`ADDR_RAM-1:0]				f_m0_w_addr,
	output	logic		[`WID_RAM-1:0]				f_m0_w_data,
	
	output	logic									f_m1_r_en,
	output	logic		[`ADDR_RAM-1:0]				f_m1_r_addr,
   	input			    [`WID_PE_BITS*`N_PE-1:0]    f_m1_output_bus,
	output	logic									f_m1_w_en,
	output	logic		[`ADDR_RAM-1:0]				f_m1_w_addr,
   	output	logic		[`WID_PE_BITS*`N_PE-1:0]	f_m1_input_bus,

//second buffer 
	output		logic	[1:0]						s_mode,
	output		logic	[`N_PE-1:0]					s_m0_r_en,
	output		logic	[`ADDR_RAM-1:0]				s_m0_r_addr,
	input			    [`WID_RAM-1:0]				s_m0_r_data,
	output		logic	[`N_PE-1:0]					s_m0_w_en,
	output		logic	[`ADDR_RAM-1:0]				s_m0_w_addr,
	output		logic	[`WID_RAM-1:0]				s_m0_w_data,
	
	output		logic								s_m1_r_en,
	output		logic	[`ADDR_RAM-1:0]				s_m1_r_addr,
   	input			    [`WID_PE_BITS*`N_PE-1:0]    s_m1_output_bus,
	output		logic								s_m1_w_en,
	output		logic	[`ADDR_RAM-1:0]				s_m1_w_addr,
   	output		logic	[`WID_PE_BITS*`N_PE-1:0]	s_m1_input_bus




);

//INSTANTIATING program_driver_inst

logic			wr_en_drv;
logic			rd_en_drv;
logic	[13:0]		addr_drv;
logic	[15:0]		write_data_drv;
logic	[15:0]		read_data_drv;

logic           run_program;
logic           done_executing;
logic           busy;
logic  [31:0]   pc_max;
logic           spi_or_driver;
logic           execute_2;

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
	.read_data_drv(read_data_drv),
    .execute_2(execute_2)
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
    .spi_or_driver(spi_or_driver),

    //Fields to be used


);

parameter IDLE = 0, MEM = 1, COMPUTATION = 2;
logic [4:0] state;


always@(posedge clk, posedge rst) begin
    if(rst) begin
        state <= IDLE;
        busy  <= 0;

    end else begin

        case(state) 
            IDLE : begin
                if(execute_2) begin
                   


                end else begin
                    state <= IDLE;
                end

            end

            MEM : begin

            end

            COMPUTATION : begin


            end

            default : begin
                
            end


        endcase


    end

end






endmodule

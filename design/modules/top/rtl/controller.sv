module controller (
    input logic clk,
    input logic rst,

    //SPI Slave Signals
    input  SCLK,
    input  MOSI,
    input  SS,
    output MISO,

    //External Memory
    interface_extmem intf_extmem,

    //First Buffer
    interface_buffer intf_buf1,

    //second buffer 
    interface_buffer intf_buf2

);

`include "user_tasks.vh"

interface_regfile regfile();


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
logic           next_layer;

assign run_program = 1;
assign spi_or_driver = 0;
assign pc_max = 15504;


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
    .execute_2(execute_2),
    .next_layer(next_layer)
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
    .regfile(regfile)


);

typedef enum { IDLE, MEM_LOAD, MEM_SAVE, COMPUTATION} ControllerStates;
ControllerStates state;
ControllerStates prev_state;
ControllerStates next_state;

logic [31:0] mem_load_start;
logic [31:0] mem_load_words;
logic [5:0]  mem_load_buffer_addr;
logic [31:0] mem_load_idx;
logic [31:0] next_mem_load_idx;
logic [`ADDR_RAM-1:0]  buf1_wr_addr         [`N_PE-1:0];
logic [`ADDR_RAM-1:0]  next_buf1_wr_addr    [`N_PE-1:0];
logic [`ADDR_RAM-1:0]  buf2_wr_addr         [`N_PE-1:0];
logic [`ADDR_RAM-1:0]  next_buf2_wr_addr    [`N_PE-1:0];
logic mem_load_buff_1_or_2;
logic mem_save_buff_1_or_2;

logic [31:0] mem_save_start;
logic [31:0] mem_save_words;
logic [5:0]  mem_save_buffer_addr;
logic [31:0] mem_save_idx;
logic [31:0] next_mem_save_idx;
logic [`ADDR_RAM-1:0]  buf1_rd_addr        [`N_PE-1:0];
logic [`ADDR_RAM-1:0]  next_buf1_rd_addr   [`N_PE-1:0];
logic [`ADDR_RAM-1:0]  buf2_rd_addr        [`N_PE-1:0];
logic [`ADDR_RAM-1:0]  next_buf2_rd_addr   [`N_PE-1:0];

integer idx;

always@(posedge clk, posedge rst) begin
    if(rst) begin
        state   <= #1 IDLE;
        mem_load_idx <= #1 0;
        mem_save_idx <= #1 0;
    end else begin
        state   <= #1 next_state;
        mem_load_idx <= #1 next_mem_load_idx;
        mem_save_idx <= #1 next_mem_save_idx;
    end
end


always@(*) begin

    next_state  = state;
    done_executing = 0;
    busy = 0;

    intf_buf1.mode = 0;
    intf_buf2.mode = 0;

    intf_buf1.m0_w_en   = 0;
    intf_buf2.m0_w_en   = 0;

    intf_buf1.m0_r_en   = 0;
    intf_buf2.m0_r_en   = 0;

    intf_buf1.m0_r_addr = 0;
    intf_buf2.m0_r_addr = 0;

    intf_buf1.m0_w_addr = 0;
    intf_buf1.m0_w_addr = 0;

    intf_buf1.m0_w_data = 0;
    intf_buf2.m0_w_data = 0;

    intf_extmem.we  = 0;
    intf_extmem.re  = 0;
    intf_extmem.wr_addr = 0;
    intf_extmem.rd_addr = 0;
    intf_extmem.wr_data = 0;

    next_mem_load_idx = mem_load_idx;
    next_mem_save_idx = mem_save_idx;


    for(idx = 0; idx < `N_PE; idx = idx + 1) begin
        next_buf1_wr_addr[idx]   = buf1_wr_addr[idx];
        next_buf2_wr_addr[idx]   = buf2_wr_addr[idx];
        next_buf1_rd_addr[idx]   = buf1_rd_addr[idx];
        next_buf2_rd_addr[idx]   = buf2_rd_addr[idx];
    end

    case(state)

        IDLE : begin

            if(execute_2) begin

                if(regfile.general__start_wr == 1) begin
                    next_state = COMPUTATION;
                end else if (regfile.general__start_loading_buffer_wr) begin
                    next_state = MEM_LOAD;
                end else if (regfile.general__start_saving_buffer_wr) begin
                    next_state = MEM_SAVE;
                end

            end

        end

        MEM_LOAD : begin
            busy = 1;

            intf_buf1.mode = 0;
            intf_buf2.mode = 0;

            intf_buf1.m0_w_data = intf_extmem.rd_data;
            intf_buf2.m0_w_data = intf_extmem.rd_data;

            if(mem_load_idx < mem_load_words) begin
                intf_extmem.re  = 1;
                intf_extmem.rd_addr = mem_load_start + mem_load_idx; //bit mismatch but okay
                next_mem_load_idx   = mem_load_idx + 1;
            end else begin
                next_state   = IDLE;
                done_executing  = 1;
                next_mem_load_idx   = 0;
            end

            if(prev_state == state) begin
                if(mem_load_buff_1_or_2) begin
                    intf_buf1.m0_w_en   = dec_to_hot(mem_load_buffer_addr);
                    intf_buf1.m0_w_addr = buf1_wr_addr[mem_load_buffer_addr];
                    intf_buf2.m0_w_en   = 0;

                    next_buf1_wr_addr[mem_load_buffer_addr]  =  buf1_wr_addr[mem_load_buffer_addr] + 1;
                end else begin
                    intf_buf2.m0_w_en   = dec_to_hot(mem_load_buffer_addr);
                    intf_buf2.m0_w_addr = buf2_wr_addr[mem_load_buffer_addr];
                    intf_buf1.m0_w_en   = 0;

                    next_buf2_wr_addr[mem_load_buffer_addr]  =  buf2_wr_addr[mem_load_buffer_addr] + 1;
                end

            end

        end

        MEM_SAVE : begin
            busy         = 1;

            intf_buf1.mode = 0;
            intf_buf2.mode = 0;

            if(mem_save_buff_1_or_2) begin
                intf_extmem.wr_data = intf_buf1.m0_r_data;
            end else begin
                intf_extmem.wr_data = intf_buf2.m0_r_data;
            end


            if(mem_save_idx < mem_save_words) begin

                if(mem_save_buff_1_or_2) begin

                    intf_buf1.m0_r_en   = dec_to_hot(mem_save_buffer_addr);
                    intf_buf1.m0_r_addr = buf1_rd_addr[mem_save_buffer_addr];

                    next_buf1_rd_addr[mem_save_buffer_addr]  =  buf1_rd_addr[mem_save_buffer_addr] + 1;

                end else begin

                    intf_buf2.m0_r_en   = dec_to_hot(mem_save_buffer_addr);
                    intf_buf2.m0_r_addr = buf2_wr_addr[mem_save_buffer_addr];

                    next_buf2_rd_addr[mem_save_buffer_addr]  =  buf2_rd_addr[mem_save_buffer_addr] + 1;

                end

                next_mem_save_idx   = mem_save_idx + 1;

            end else begin

                next_state   = IDLE;
                done_executing  = 1;
                next_mem_save_idx = 0;
            end

            if(prev_state == state) begin
                intf_extmem.we = 1;
                intf_extmem.wr_addr = mem_save_start + mem_save_idx - 1;
            end


        end


        COMPUTATION : begin
            busy   = 1;

            if(prev_state == state) begin
                done_executing = 1;
                next_state  = IDLE;
            end

        end

    endcase

end


always@(posedge clk, posedge rst) begin
    if(rst) begin

        for(idx = 0; idx < `N_PE; idx = idx + 1) begin
            buf1_wr_addr[idx]   <= #1 0;
            buf2_wr_addr[idx]   <= #1 0;
            buf1_rd_addr[idx]   <= #1 0;
            buf2_rd_addr[idx]   <= #1 0;

        end

    end else begin

        if(next_layer) begin
            for(idx = 0; idx < `N_PE ; idx = idx + 1) begin
                buf1_wr_addr[idx]    <= #1 0;
                buf2_wr_addr[idx]    <= #1 0;

                buf1_rd_addr[idx]    <= #1 0;
                buf2_rd_addr[idx]    <= #1 0;
            end
        end else begin
            for(idx = 0; idx < `N_PE ; idx = idx + 1) begin
                buf1_wr_addr[idx]    <= #1 next_buf1_wr_addr[idx];
                buf2_wr_addr[idx]    <= #1 next_buf2_wr_addr[idx];

                buf1_rd_addr[idx]    <= #1 next_buf1_rd_addr[idx];
                buf2_rd_addr[idx]    <= #1 next_buf2_rd_addr[idx];
            end
        end
    end
end


assign mem_load_start = {regfile.general__mem_load_start_upper,regfile.general__mem_load_start_lower};
assign mem_load_words = {regfile.general__mem_load_words_upper,regfile.general__mem_load_words_lower};
assign mem_load_buffer_addr = regfile.general__mem_load_buffer_addr[5:0];

assign mem_save_start = {regfile.general__mem_save_start_upper,regfile.general__mem_save_start_lower};
assign mem_save_words = {regfile.general__mem_save_words_upper,regfile.general__mem_save_words_lower};
assign mem_save_buffer_addr = regfile.general__mem_save_buffer_addr;

assign mem_load_buff_1_or_2 = (regfile.general__mem_load_buffer_addr[8] == 0) ? 1 : 0;
assign mem_save_buff_1_or_2 = (regfile.general__mem_save_buffer_addr[8] == 0) ? 1 : 0;

always@(posedge clk,posedge rst)
begin
    if(rst) begin
        prev_state  <= #1 IDLE;
    end else begin
        prev_state  <= #1 state;
    end

end

endmodule

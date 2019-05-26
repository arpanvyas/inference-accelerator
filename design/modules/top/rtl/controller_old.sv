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

parameter IDLE = 0, MEM_LOAD = 1, MEM_SAVE = 2, COMPUTATION = 3;
logic [4:0] state;
logic [4:0] prev_state;

logic [31:0] mem_load_start;
logic [31:0] mem_load_words;
logic [5:0]  mem_load_buffer_addr;
logic [31:0] mem_load_idx;
logic [`ADDR_RAM-1:0]  buf1_wr_addr   [`N_PE-1:0];
logic [`ADDR_RAM-1:0]  buf2_wr_addr   [`N_PE-1:0];

logic [31:0] mem_save_start;
logic [31:0] mem_save_words;
logic [5:0]  mem_save_buffer_addr;
logic [31:0] mem_save_idx;
logic [`ADDR_RAM-1:0]  buf1_rd_addr   [`N_PE-1:0];
logic [`ADDR_RAM-1:0]  buf2_rd_addr   [`N_PE-1:0];

integer idx;

always@(posedge clk, posedge rst) begin
    if(rst) begin
        state <= IDLE;
        busy  <= 0;

        intf_extmem.we  <= 0;
        intf_extmem.re  <= 0;

        intf_buf1.m0_r_en   <= 0;
        intf_buf1.m0_w_en   <= 0;
        intf_buf2.m0_r_en   <= 0;
        intf_buf2.m0_w_en   <= 0;

        for(idx = 0; idx < `N_PE ; idx = idx + 1) begin
            buf1_wr_addr[idx]    <= 0;
            buf2_wr_addr[idx]    <= 0;

            buf1_rd_addr[idx]    <= 0;
            buf2_rd_addr[idx]    <= 0;
        end



    end else begin

        if(next_layer) begin
            for(idx = 0; idx < `N_PE ; idx = idx + 1) begin
                buf1_wr_addr[idx]    <= 0;
                buf2_wr_addr[idx]    <= 0;

                buf1_rd_addr[idx]    <= 0;
                buf2_rd_addr[idx]    <= 0;
            end
        end

        done_executing <= 0;

        case(state) 
            IDLE : begin

                intf_extmem.we  <= 0;
                intf_extmem.re  <= 0;

                intf_buf1.m0_r_en   <= 0;
                intf_buf1.m0_w_en   <= 0;
                intf_buf2.m0_r_en   <= 0;
                intf_buf2.m0_w_en   <= 0;

                if(execute_2) begin

                    if(regfile.general__start_wr == 1) begin
                        state <= COMPUTATION;



                    end else if (regfile.general__start_loading_buffer_wr) begin
                        state <= MEM_LOAD;
                        mem_load_start <= {regfile.general__mem_load_start_upper,regfile.general__mem_load_start_lower};
                        mem_load_words <= {regfile.general__mem_load_words_upper,regfile.general__mem_load_words_lower};
                        mem_load_buffer_addr <= regfile.general__mem_load_buffer_addr[5:0];
                        mem_load_idx   <= 0; 

                    end else if (regfile.general__start_saving_buffer_wr) begin
                        state <= MEM_SAVE;
                        mem_save_start <= {regfile.general__mem_save_start_upper,regfile.general__mem_save_start_lower};
                        mem_save_words <= {regfile.general__mem_save_words_upper,regfile.general__mem_save_words_lower};
                        mem_save_buffer_addr <= regfile.general__mem_save_buffer_addr;
                        mem_save_idx    <= 0;
                    end


                end else begin
                    state <= IDLE;
                end

            end

            MEM_LOAD : begin
                state   <= MEM_LOAD;

                intf_buf1.mode <= 0;
                intf_buf2.mode <= 0;

                if(mem_load_idx < mem_load_words) begin
                    intf_extmem.re  <= 1;
                    intf_extmem.rd_addr <= mem_load_start + mem_load_idx; //bit mismatch but okay
                    mem_load_idx    <= mem_load_idx + 1;
                end else begin
                    intf_extmem.re  <= 0;
                    mem_load_idx    <= 0;
                    state   <= IDLE;
                    done_executing  <= 1;
                end

                if(prev_state == state) begin
                    if(regfile.general__mem_load_buffer_addr[8] == 0)
                    begin
                        intf_buf1.m0_w_en   <= dec_to_hot(regfile.general__mem_load_buffer_addr[5:0]);
                        intf_buf1.m0_w_addr <= buf1_wr_addr[regfile.general__mem_load_buffer_addr[5:0]];
                        buf1_wr_addr[regfile.general__mem_load_buffer_addr[5:0]]  <=  buf1_wr_addr[regfile.general__mem_load_buffer_addr[5:0]] + 1;
                        intf_buf1.m0_w_data <= intf_extmem.rd_data;
                    end else begin
                        intf_buf2.m0_w_en   <= dec_to_hot(regfile.general__mem_load_buffer_addr[5:0]);
                        intf_buf2.m0_w_addr <= buf2_wr_addr[regfile.general__mem_load_buffer_addr[5:0]];
                        buf2_wr_addr[regfile.general__mem_load_buffer_addr[5:0]]  <=  buf2_wr_addr[regfile.general__mem_load_buffer_addr[5:0]] + 1;
                        intf_buf2.m0_w_data <= intf_extmem.rd_data;
                    end

                end

            end

            MEM_SAVE : begin
                state   <= MEM_SAVE;

                intf_buf1.mode <= 0;
                intf_buf2.mode <= 0;

                if(mem_save_idx < mem_save_words) begin
                    if(regfile.general__mem_save_buffer_addr[8] == 0) begin
                        intf_buf1.m0_r_en   <= regfile.general__mem_save_buffer_addr[5:0];
                        intf_buf1.m0_r_addr <= buf1_rd_addr[regfile.general__mem_save_buffer_addr[5:0]];
                    end else begin
                        intf_buf2.m0_r_en   <= regfile.general__mem_save_buffer_addr[5:0];
                        intf_buf2.m0_r_addr <= buf2_rd_addr[regfile.general__mem_save_buffer_addr[5:0]];
                        mem_save_idx        <= mem_save_idx + 1;

                    end
                end else begin
                    mem_save_idx        <= 0;
                    state               <= IDLE;
                    done_executing      <= 1;
                end



                if(prev_state == state) begin
                    if(regfile.general__mem_save_buffer_addr[8] == 0) begin
                        intf_extmem.wr_data <= intf_buf1.m0_r_data;
                        intf_extmem.we      <= 1;
                        intf_extmem.wr_addr <= mem_save_start + mem_save_idx;
                        mem_save_idx        <= mem_save_idx + 1;
                    end else begin
                        intf_extmem.wr_data <= intf_buf2.m0_r_data;
                        intf_extmem.we      <= 1;
                        intf_extmem.wr_addr <= mem_save_start + mem_save_idx;
                        mem_save_idx        <= mem_save_idx + 1;
                    end

                end



            end

            COMPUTATION : begin
                state   <= COMPUTATION;
                state   <= IDLE;
                done_executing  <= 1;


            end

            default : begin

            end


        endcase




    end

end


always@(posedge clk,posedge rst)
begin
    if(rst) begin
        prev_state  <= IDLE;
    end else begin
        prev_state  <= state;
    end

end

endmodule

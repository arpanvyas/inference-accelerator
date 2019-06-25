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

    //Second buffer 
    interface_buffer intf_buf2,

    //PE Array
    interface_pe_array intf_pea

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


///////////////////////////////////////////////////////
//Computation Controller
///////////////////////////////////////////////////////

logic   [2:0]   comp_sel;
logic           start_comp;
logic           done_comp;

computation_controller computation_controller_inst (

    .clk(clk),
    .rst(rst),
    .comp_sel(comp_sel),
    .start_comp(start_comp),
    .regfile(regfile),
    .intf_pea(intf_pea),
    .intf_buf1(intf_buf1),
    .intf_buf2(intf_buf2),
    .done(done_comp)
);


///////////////////////////////////////////////////////
//State Machine For This Block
///////////////////////////////////////////////////////


typedef enum { IDLE, MEM_LOAD, MEM_SAVE, COMPUTATION} ControllerStates;
ControllerStates state;
ControllerStates prev_state;
ControllerStates next_state;

logic [31:0] mem_load_start;
logic [31:0] mem_load_words;
logic [5:0]  mem_load_buffer_addr;
logic [31:0] mem_load_idx;
logic [31:0] next_mem_load_idx;
logic [`ADDR_RAM-1:0]  buf1_wr_addr         [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf1_wr_addr    [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  buf2_wr_addr         [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf2_wr_addr    [`N_BUF-1:0];
logic mem_load_buff_1_or_2;
logic mem_save_buff_1_or_2;

logic [31:0] mem_save_start;
logic [31:0] mem_save_words;
logic [5:0]  mem_save_buffer_addr;
logic [31:0] mem_save_idx;
logic [31:0] next_mem_save_idx;
logic [`ADDR_RAM-1:0]  buf1_rd_addr        [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf1_rd_addr   [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  buf2_rd_addr        [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf2_rd_addr   [`N_BUF-1:0];


always_ff@(posedge clk, posedge rst) begin
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


always_comb begin

    next_state  = state;
    done_executing = 0;
    busy = 0;


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


    for(int idx_var = 0; idx_var < `N_BUF; idx_var = idx_var + 1) begin
        next_buf1_wr_addr[idx_var]   = buf1_wr_addr[idx_var];
        next_buf2_wr_addr[idx_var]   = buf2_wr_addr[idx_var];
        next_buf1_rd_addr[idx_var]   = buf1_rd_addr[idx_var];
        next_buf2_rd_addr[idx_var]   = buf2_rd_addr[idx_var];
    end


    comp_sel = 0;
    start_comp = 0;

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
                    intf_buf1.m0_w_en   = mem_load_buffer_addr;
                    intf_buf1.m0_w_addr = buf1_wr_addr[mem_load_buffer_addr];
                    intf_buf2.m0_w_en   = 0;

                    next_buf1_wr_addr[mem_load_buffer_addr]  =  buf1_wr_addr[mem_load_buffer_addr] + 1;
                end else begin
                    intf_buf2.m0_w_en   = mem_load_buffer_addr;
                    intf_buf2.m0_w_addr = buf2_wr_addr[mem_load_buffer_addr];
                    intf_buf1.m0_w_en   = 0;

                    next_buf2_wr_addr[mem_load_buffer_addr]  =  buf2_wr_addr[mem_load_buffer_addr] + 1;
                end

            end

        end

        MEM_SAVE : begin
            busy         = 1;


            if(mem_save_buff_1_or_2) begin
                intf_extmem.wr_data = intf_buf1.m0_r_data;
            end else begin
                intf_extmem.wr_data = intf_buf2.m0_r_data;
            end


            if(mem_save_idx < mem_save_words) begin

                if(mem_save_buff_1_or_2) begin

                    intf_buf1.m0_r_en   = mem_save_buffer_addr;
                    intf_buf1.m0_r_addr = buf1_rd_addr[mem_save_buffer_addr];

                    next_buf1_rd_addr[mem_save_buffer_addr]  =  buf1_rd_addr[mem_save_buffer_addr] + 1;

                end else begin

                    intf_buf2.m0_r_en   = mem_save_buffer_addr;
                    intf_buf2.m0_r_addr = buf2_rd_addr[mem_save_buffer_addr];

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

            case (regfile.general__layer_type[3:0])

                4'b0000, 4'b0101: begin
                    comp_sel = 3'b001;
                end

                4'b0001, 4'b1000: begin
                    comp_sel = 3'b010;
                end

                4'b0011: begin
                    comp_sel = 3'b011;
                end

                default : begin
                    comp_sel = 3'b000;
                end

            endcase

            if(done_comp) begin
                done_executing = 1;
                next_state  = IDLE;
            end

            if(prev_state != state) begin

                start_comp = 1;
            end

        end

    endcase

end


always_ff@(posedge clk, posedge rst) begin
    if(rst) begin

        for(int idx_var = 0; idx_var < `N_BUF; idx_var = idx_var + 1) begin
            buf1_wr_addr[idx_var]   <= #1 0;
            buf2_wr_addr[idx_var]   <= #1 0;
            buf1_rd_addr[idx_var]   <= #1 0;
            buf2_rd_addr[idx_var]   <= #1 0;

        end

    end else begin

        if(next_layer) begin
            for(int idx_var = 0; idx_var < `N_BUF ; idx_var = idx_var + 1) begin
                buf1_wr_addr[idx_var]    <= #1 0;
                buf2_wr_addr[idx_var]    <= #1 0;

                buf1_rd_addr[idx_var]    <= #1 0;
                buf2_rd_addr[idx_var]    <= #1 0;
            end
        end else begin
            for(int idx_var = 0; idx_var < `N_BUF ; idx_var = idx_var + 1) begin
                buf1_wr_addr[idx_var]    <= #1 next_buf1_wr_addr[idx_var];
                buf2_wr_addr[idx_var]    <= #1 next_buf2_wr_addr[idx_var];

                buf1_rd_addr[idx_var]    <= #1 next_buf1_rd_addr[idx_var];
                buf2_rd_addr[idx_var]    <= #1 next_buf2_rd_addr[idx_var];
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

always_ff@(posedge clk,posedge rst)
begin
    if(rst) begin
        prev_state  <= #1 IDLE;
    end else begin
        prev_state  <= #1 state;
    end

end

endmodule

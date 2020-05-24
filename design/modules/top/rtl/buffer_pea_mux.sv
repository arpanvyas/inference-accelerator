module buffer_pea_mux (


    interface_buffer            intf_buf1,
    interface_buffer            intf_buf2,
    interface_pe_array          intf_pea,

    input   logic   [2:0]       comp_sel,

    interface_pe_array_ctrl     intf_pea_ctrl_conv,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl_conv,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl_conv,
    input   logic  [1:0]        aybz_azby_conv,

    interface_pe_array_ctrl     intf_pea_ctrl_dense,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl_dense,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl_dense,
    input   logic  [1:0]        aybz_azby_dense,

    interface_pe_array_ctrl     intf_pea_ctrl_pool,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl_pool,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl_pool,
    input   logic  [1:0]        aybz_azby_pool

);


///////////////////////////////////////////////
//Connect Data Lines From BUF to PEA
//////////////////////////////////////////////


logic [1:0]   aybz_azby;
//This decides the ping pong mode, 1 : default, Feed forward starts from Buf1
//                                 0 : Feed forward starts from Buf2
//
//Basically connects inputs of PEA with BUF1/BUF2 outputs
//A : Output BUF1 ; B : Output BUF2
//Y : Input1 PEA  ; Z : Input2 PEA 
//a : Output BUF1 bank#32 spread out 
//b : Output BUF2 bank#32 spread out
//So, 4 modes
//AYBZ : conv/pool, BUF1 driver --> 2'b01
//AZBY : conv/pool, BUF2 driver --> 2'b00
//AYaZ : dense , BUF1 driver    --> 2'b11
//BYbZ : dense, BUF2 driver     --> 2'b10

//comp_sel
//000: IDLE
//001: CONV
//010: DENSE
//011: POOL
always_comb begin
    case(comp_sel)
        3'b000  : begin
            aybz_azby = 2'b01;
            intf_buf1.mode = 0;
            intf_buf2.mode = 0;
        end
        3'b001  : begin
            aybz_azby = aybz_azby_conv;
            intf_buf1.mode = 1;
            intf_buf2.mode = 1;
        end
        3'b010  : begin
            aybz_azby = aybz_azby_dense;
            intf_buf1.mode = 1;
            intf_buf2.mode = 1;
        end
        3'b011  : begin
            aybz_azby = aybz_azby_pool;
            intf_buf1.mode = 1;
            intf_buf2.mode = 1;
        end
        default : begin
            aybz_azby = 2'b01;
            intf_buf1.mode = 0;
            intf_buf2.mode = 0;
        end
    endcase
end



always_comb begin

    if(aybz_azby) begin

        case(aybz_azby)

            2'b01: begin //AYBZ: conv/pool PING
                for(int i = 0; i < `N_BUF; i = i + 1) begin
                    intf_pea.input_bus1_PEA[i] = intf_buf1.m1_output_bus[i]; //conv input and filters
                    intf_pea.input_bus2_PEA[i] = intf_buf2.m1_output_bus[i]; //conv output feedback

                    intf_buf1.m1_input_bus[i] = intf_pea.output_bus1_PEA[i]; //not relevant
                    intf_buf2.m1_input_bus[i] = intf_pea.output_bus1_PEA[i]; //conv outputs
                end 
            end

            2'b00: begin //AZBY: conv/pool PONG
                for(int i = 0; i < `N_BUF; i = i + 1) begin
                    intf_pea.input_bus1_PEA[i] = intf_buf2.m1_output_bus[i]; //conv output feedback
                    intf_pea.input_bus2_PEA[i] = intf_buf1.m1_output_bus[i]; //conv input and filters

                    intf_buf1.m1_input_bus[i] = intf_pea.output_bus1_PEA[i]; //conv outputs
                    intf_buf2.m1_input_bus[i] = intf_pea.output_bus1_PEA[i]; //not relevant
                end
            end

            2'b11: begin //AYaZ: dense PING
                for(int i = 0; i < `N_BUF; i = i + 1) begin
                    intf_pea.input_bus1_PEA[i] = intf_buf1.m1_output_bus[i]; //dense weights
                    intf_pea.input_bus2_PEA[i] = intf_buf1.m1_output_bus[`N_PE]; //dense input

                    intf_buf1.m1_input_bus[i] = intf_pea.output_bus1_PEA[`N_PE]; //not relevant
                    intf_buf2.m1_input_bus[i] = intf_pea.output_bus1_PEA[`N_PE]; //dense output
                end
            end

            2'b10: begin //BYbZ: dense PONG
                for(int i = 0; i < `N_BUF; i = i + 1) begin
                    intf_pea.input_bus1_PEA[i] = intf_buf2.m1_output_bus[i]; //dense weights
                    intf_pea.input_bus2_PEA[i] = intf_buf2.m1_output_bus[`N_PE]; //dense input

                    intf_buf1.m1_input_bus[i] = intf_pea.output_bus1_PEA[`N_PE]; //dense output
                    intf_buf2.m1_input_bus[i] = intf_pea.output_bus1_PEA[`N_PE]; //not relevant
                end
            end

        endcase

    end
end

////////////////////////////////////////////////////////////
//Connect Control Signals
///////////////////////////////////////////////////////////


always_comb begin

    case(comp_sel)

        3'b000: begin       //IDLE

            intf_buf1.m1_r_en = 0;
            intf_buf1.m1_w_en = 0;

            intf_buf2.m1_r_en = 0;
            intf_buf2.m1_w_en = 0;

            for(int i0 = 0; i0 < `N_BUF; i0 = i0+1) begin
                intf_buf1.m1_r_addr[i0] = 0;
                intf_buf1.m1_w_addr[i0] = 0;
                intf_buf2.m1_r_addr[i0] = 0;
                intf_buf2.m1_w_addr[i0] = 0;
            end

            for(int i1 = 0; i1 < `N_PE; i1 = i1+1) begin
                intf_pea.shifting_line[i1] = 0;
                intf_pea.shifting_filter[i1] = 0;
                intf_pea.mac_enable[i1] = 0;
            end

            intf_pea.line_buffer_reset = 0;
            intf_pea.row_length = 0;
            intf_pea.adder_enable = 0;
            intf_pea.nl_type = 0;
            intf_pea.shifting_bias = 0;
            intf_pea.bias_enable = 0;
            intf_pea.nl_enable = 0;
            intf_pea.feedback_enable = 0;

            intf_pea.pool_enable = 0;
            intf_pea.dense_enable = 0;
            intf_pea.dense_valid = 0;
            intf_pea.dense_adder_reset = '1;
            intf_pea.dense_adder_on = 0;
            intf_pea.dense_latch = 0;
            intf_pea.dense_rd_addr = 0;

        end

        3'b001: begin       //CONV

            intf_buf1.m1_r_en = intf_buf1_m1_ctrl_conv.m1_r_en;
            intf_buf1.m1_r_addr = intf_buf1_m1_ctrl_conv.m1_r_addr;
            intf_buf1.m1_w_en = intf_buf1_m1_ctrl_conv.m1_w_en;
            intf_buf1.m1_w_addr = intf_buf1_m1_ctrl_conv.m1_w_addr;

            intf_buf2.m1_r_en = intf_buf2_m1_ctrl_conv.m1_r_en;
            intf_buf2.m1_r_addr = intf_buf2_m1_ctrl_conv.m1_r_addr;
            intf_buf2.m1_w_en = intf_buf2_m1_ctrl_conv.m1_w_en;
            intf_buf2.m1_w_addr = intf_buf2_m1_ctrl_conv.m1_w_addr;

            intf_pea.shifting_line = intf_pea_ctrl_conv.shifting_line;
            intf_pea.line_buffer_reset = intf_pea_ctrl_conv.line_buffer_reset;
            intf_pea.row_length = intf_pea_ctrl_conv.row_length;
            intf_pea.shifting_filter = intf_pea_ctrl_conv.shifting_filter;
            intf_pea.mac_enable = intf_pea_ctrl_conv.mac_enable;
            intf_pea.adder_enable = intf_pea_ctrl_conv.adder_enable;
            intf_pea.nl_type = intf_pea_ctrl_conv.nl_type;
            intf_pea.nl_enable = intf_pea_ctrl_conv.nl_enable;
            intf_pea.feedback_enable = intf_pea_ctrl_conv.feedback_enable;
            intf_pea.bias_enable = intf_pea_ctrl_conv.bias_enable;
            intf_pea.shifting_bias = intf_pea_ctrl_conv.shifting_bias;


            intf_pea.pool_enable    = intf_pea_ctrl_conv.pool_enable;
            intf_pea.dense_enable    = intf_pea_ctrl_conv.dense_enable;
            intf_pea.dense_valid    = intf_pea_ctrl_conv.dense_valid;
            intf_pea.dense_adder_reset = intf_pea_ctrl_conv.dense_adder_reset;
            intf_pea.dense_adder_on = intf_pea_ctrl_conv.dense_adder_on;
            intf_pea.dense_latch = intf_pea_ctrl_conv.dense_latch;
            intf_pea.dense_rd_addr = intf_pea_ctrl_conv.dense_rd_addr;


        end

        3'b010: begin       //DENSE

            intf_buf1.m1_r_en = intf_buf1_m1_ctrl_dense.m1_r_en;
            intf_buf1.m1_r_addr = intf_buf1_m1_ctrl_dense.m1_r_addr;
            intf_buf1.m1_w_en = intf_buf1_m1_ctrl_dense.m1_w_en;
            intf_buf1.m1_w_addr = intf_buf1_m1_ctrl_dense.m1_w_addr;

            intf_buf2.m1_r_en = intf_buf2_m1_ctrl_dense.m1_r_en;
            intf_buf2.m1_r_addr = intf_buf2_m1_ctrl_dense.m1_r_addr;
            intf_buf2.m1_w_en = intf_buf2_m1_ctrl_dense.m1_w_en;
            intf_buf2.m1_w_addr = intf_buf2_m1_ctrl_dense.m1_w_addr;

            intf_pea.shifting_line = intf_pea_ctrl_dense.shifting_line;
            intf_pea.line_buffer_reset = intf_pea_ctrl_dense.line_buffer_reset;
            intf_pea.row_length = intf_pea_ctrl_dense.row_length;
            intf_pea.shifting_filter = intf_pea_ctrl_dense.shifting_filter;
            intf_pea.mac_enable = intf_pea_ctrl_dense.mac_enable;
            intf_pea.adder_enable = intf_pea_ctrl_dense.adder_enable;
            intf_pea.nl_type = intf_pea_ctrl_dense.nl_type;
            intf_pea.nl_enable = intf_pea_ctrl_dense.nl_enable;
            intf_pea.feedback_enable = intf_pea_ctrl_dense.feedback_enable;
            intf_pea.bias_enable = intf_pea_ctrl_dense.bias_enable;
            intf_pea.shifting_bias = intf_pea_ctrl_dense.shifting_bias;

            intf_pea.pool_enable    = intf_pea_ctrl_dense.pool_enable;
            intf_pea.dense_enable    = intf_pea_ctrl_dense.dense_enable;
            intf_pea.dense_valid    = intf_pea_ctrl_dense.dense_valid;
            intf_pea.dense_adder_reset = intf_pea_ctrl_dense.dense_adder_reset;
            intf_pea.dense_adder_on = intf_pea_ctrl_dense.dense_adder_on;
            intf_pea.dense_latch = intf_pea_ctrl_dense.dense_latch;
            intf_pea.dense_rd_addr = intf_pea_ctrl_dense.dense_rd_addr;

        end

        3'b011: begin       //POOL

            intf_buf1.m1_r_en = intf_buf1_m1_ctrl_pool.m1_r_en;
            intf_buf1.m1_r_addr = intf_buf1_m1_ctrl_pool.m1_r_addr;
            intf_buf1.m1_w_en = intf_buf1_m1_ctrl_pool.m1_w_en;
            intf_buf1.m1_w_addr = intf_buf1_m1_ctrl_pool.m1_w_addr;

            intf_buf2.m1_r_en = intf_buf2_m1_ctrl_pool.m1_r_en;
            intf_buf2.m1_r_addr = intf_buf2_m1_ctrl_pool.m1_r_addr;
            intf_buf2.m1_w_en = intf_buf2_m1_ctrl_pool.m1_w_en;
            intf_buf2.m1_w_addr = intf_buf2_m1_ctrl_pool.m1_w_addr;

            intf_pea.shifting_line = intf_pea_ctrl_pool.shifting_line;
            intf_pea.line_buffer_reset = intf_pea_ctrl_pool.line_buffer_reset;
            intf_pea.row_length = intf_pea_ctrl_pool.row_length;
            intf_pea.shifting_filter = intf_pea_ctrl_pool.shifting_filter;
            intf_pea.mac_enable = intf_pea_ctrl_pool.mac_enable;
            intf_pea.adder_enable = intf_pea_ctrl_pool.adder_enable;
            intf_pea.nl_type = intf_pea_ctrl_pool.nl_type;
            intf_pea.nl_enable = intf_pea_ctrl_pool.nl_enable;
            intf_pea.feedback_enable = intf_pea_ctrl_pool.feedback_enable;
            intf_pea.bias_enable = intf_pea_ctrl_pool.bias_enable;
            intf_pea.shifting_bias = intf_pea_ctrl_pool.shifting_bias;


            intf_pea.pool_enable    = intf_pea_ctrl_pool.pool_enable;
            intf_pea.dense_enable    = intf_pea_ctrl_pool.dense_enable;
            intf_pea.dense_valid    = intf_pea_ctrl_pool.dense_valid;
            intf_pea.dense_adder_reset = intf_pea_ctrl_pool.dense_adder_reset;
            intf_pea.dense_adder_on = intf_pea_ctrl_pool.dense_adder_on;
            intf_pea.dense_latch = intf_pea_ctrl_pool.dense_latch;
            intf_pea.dense_rd_addr = intf_pea_ctrl_pool.dense_rd_addr;



        end

        default: begin


            intf_buf1.m1_r_en = 0;
            intf_buf1.m1_w_en = 0;

            intf_buf2.m1_r_en = 0;
            intf_buf2.m1_w_en = 0;


            for(int i0 = 0; i0 < `N_BUF; i0 = i0+1) begin
                intf_buf1.m1_r_addr[i0] = 0;
                intf_buf1.m1_w_addr[i0] = 0;
                intf_buf2.m1_r_addr[i0] = 0;
                intf_buf2.m1_w_addr[i0] = 0;
            end

            for(int i1 = 0; i1 < `N_PE; i1 = i1+1) begin
                intf_pea.shifting_line[i1] = 0;
                intf_pea.shifting_filter[i1] = 0;
                intf_pea.mac_enable[i1] = 0;

            end

            intf_pea.line_buffer_reset = 0;
            intf_pea.row_length = 0;
            intf_pea.adder_enable = 0;
            intf_pea.nl_type = 0;
            intf_pea.shifting_bias = 0;
            intf_pea.bias_enable = 0;
            intf_pea.nl_enable = 0;
            intf_pea.feedback_enable = 0;

            intf_pea.pool_enable = 0;
            intf_pea.dense_enable = 0;
            intf_pea.dense_valid = 0;
            intf_pea.dense_adder_reset = 1;
            intf_pea.dense_adder_on = 0;
            intf_pea.dense_latch = 0;
            intf_pea.dense_rd_addr = 0;


        end

    endcase



end






endmodule

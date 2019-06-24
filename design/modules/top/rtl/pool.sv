module pool (
    input   logic   clk,
    input   logic   rst,
    input   logic   start,
    interface_regfile   regfile,
    interface_pe_array_ctrl     intf_pea_ctrl,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl,
    output  logic [1:0]         aybz_azby,
    output  logic               done

);

logic [`ADDR_RAM-1:0]  buf1_wr_addr         [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf1_wr_addr    [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  buf2_wr_addr         [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf2_wr_addr    [`N_BUF-1:0];

logic [`ADDR_RAM-1:0]  buf1_rd_addr        [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf1_rd_addr   [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  buf2_rd_addr        [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf2_rd_addr   [`N_BUF-1:0];

logic ping_pong; //1: ping, 0: pong

logic   [`LOG_N_PE-1:0] extra_c;
logic   extra_c_present;

logic signed   [7:0]   CB, next_cb, cb;
logic   [7:0]   next_c_mod, c_mod;//Channel blocks
logic   [7:0]   CBe;


logic           cbe_on, next_cbe_on;

logic   [15:0]  channels;
logic   [15:0]  input_size;
logic   [15:0]  output_size;
logic   [15:0]  output_width;
logic   [15:0]  output_height;

logic   [15:0]  input_idx_ff1, next_input_idx_ff1; //read from BUF1
logic   [15:0]  input_idx_ff2, next_input_idx_ff2; //write to PEA
logic   [15:0]  input_idx_ff3, next_input_idx_ff3; //pool enable
logic   [15:0]  input_idx_ff4, next_input_idx_ff4; //write to BUF2

logic   [15:0]  latency_cnt_1, next_latency_cnt_1;
logic   [15:0]  latency_cnt_2, next_latency_cnt_2;

logic   pool_valid;

typedef enum { IDLE, s_CB, s_CB_I  } PoolStates;

PoolStates state;
PoolStates next_state, prev_state;



logic           pool_valid_d;
logic   [15:0]  pool_valid_cnt;


always_ff@(posedge clk, posedge rst) begin
    if(rst) begin
        state <= #1 IDLE;

        cb  <= #1 -1;

        cbe_on <= #1 0;

        c_mod <= #1 0;


        latency_cnt_1 <= #1 0;
        latency_cnt_2 <= #1 0;

        input_idx_ff1 <= #1 0;
        input_idx_ff2 <= #1 0;
        input_idx_ff3 <= #1 0;
        input_idx_ff4 <= #1 0;

    end else begin
        state <= #1 next_state;
        prev_state <= #1 state;

        cb  <= #1 next_cb;

        cbe_on <= #1 next_cbe_on;

        c_mod <= #1 next_c_mod;

        input_idx_ff1 <= #1 next_input_idx_ff1;
        input_idx_ff2 <= #1 next_input_idx_ff2;
        input_idx_ff3 <= #1 next_input_idx_ff3;
        input_idx_ff4 <= #1 next_input_idx_ff4;

        latency_cnt_1 <= #1 next_latency_cnt_1;
        latency_cnt_2 <= #1 next_latency_cnt_2;

    end
end



always_comb begin

    next_state = state;
    done = 0;
    next_cb = cb;
    next_cbe_on = cbe_on;

    next_c_mod = c_mod;


    next_input_idx_ff1 = input_idx_ff1;
    next_input_idx_ff2 = input_idx_ff2;
    next_input_idx_ff3 = input_idx_ff3;
    next_input_idx_ff4 = input_idx_ff4;

    intf_pea_ctrl.pool_enable = 1;
    intf_pea_ctrl.dense_enable = 0;
    intf_pea_ctrl.dense_valid = 0;
    intf_pea_ctrl.dense_adder_reset = 1;
    intf_pea_ctrl.dense_adder_on = 0;

    for (int idx_var = 0; idx_var < `N_PE; idx_var = idx_var + 1) begin
        intf_pea_ctrl.shifting_line[idx_var] = 0;
        intf_pea_ctrl.shifting_filter[idx_var] = 0;
        intf_pea_ctrl.mac_enable[idx_var] = 0;
        intf_pea_ctrl.feedback_enable[idx_var] = 0;
    end

    for (int i0 = 0; i0 < `N_BUF; i0 = i0 + 1) begin
        intf_buf1_m1_ctrl.m1_r_en[i0] = 0;
        intf_buf1_m1_ctrl.m1_r_addr[i0] = 0;
        intf_buf1_m1_ctrl.m1_w_en[i0] = 0;
        intf_buf1_m1_ctrl.m1_w_addr[i0] = 0;

        intf_buf2_m1_ctrl.m1_r_en[i0] = 0;
        intf_buf2_m1_ctrl.m1_r_addr[i0] = 0;
        intf_buf2_m1_ctrl.m1_w_en[i0] = 0;
        intf_buf2_m1_ctrl.m1_w_addr[i0] = 0;
    end

    intf_pea_ctrl.nl_enable = 0;
    intf_pea_ctrl.row_length = regfile.pool__data_wid;
    intf_pea_ctrl.nl_type = regfile.nl__nl_type;
    intf_pea_ctrl.adder_enable = 0;
    intf_pea_ctrl.line_buffer_reset = 1;
    

    next_latency_cnt_1 = latency_cnt_1;
    next_latency_cnt_2 = latency_cnt_2;

    case(state) 



        IDLE : begin
            if (start) begin
                next_state = s_CB;
            end

        end

        s_CB : begin

            next_input_idx_ff1 = 0;
            next_input_idx_ff2 = 0;
            next_input_idx_ff3 = 0;
            next_input_idx_ff4 = 0;
            next_latency_cnt_1 = 0;
            next_latency_cnt_2 = 0;

            if(prev_state != s_CB) begin

                if(cb == CBe-1) begin
                    next_state = IDLE;
                    next_cbe_on = 0;
                    next_cb = -1;
                    done = 1;
                end else begin
                    next_cb = cb + 1;
                    next_state = s_CB_I;
                    if(CB < CBe && cb == CB-1) begin
                        next_cbe_on = 1;
                    end else begin
                        next_cbe_on = 0;
                    end
                end

            end 

        end //s_CB


        s_CB_I : begin


            intf_pea_ctrl.line_buffer_reset = 0;


            //I. Feed forward

            //1. Read Image logic

            if(input_idx_ff1 < input_size ) begin

                if(cbe_on == 0) begin
                    for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                        intf_buf1_m1_ctrl.m1_r_en[i1] = 1;
                        intf_buf1_m1_ctrl.m1_r_addr[i1] = input_size*cb + input_idx_ff1;
                    end
                end else begin //extra_c
                    for(int i1 = 0; i1 < extra_c; i1 = i1 + 1) begin
                        intf_buf1_m1_ctrl.m1_r_en[i1] = 1;
                        intf_buf1_m1_ctrl.m1_r_addr[i1] = input_size*cb + input_idx_ff1;
                    end
                end

                next_input_idx_ff1 = input_idx_ff1 + 1;

            end

            //2. Writing logic, follows read logic by 1 cycle
            //The pooling happens diagonally because i'th input from BUF will
            //go to each PE's i'th Conv
            if(latency_cnt_1 == 1) begin

                if(input_idx_ff2 < input_size ) begin
                    if(cbe_on == 1) begin

                        for(int i0 = 0; i0 < extra_c; i0 = i0 + 1) begin 
                            intf_pea_ctrl.shifting_line[i0][i0] = 1;                
                        end //for i0

                    end else begin //!cbe_on

                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_pea_ctrl.shifting_line[i0][i0] = 1;                
                        end //for i0

                    end //if !cbe_on

                    next_input_idx_ff2 = input_idx_ff2 + 1;

                end

            end else begin
                next_latency_cnt_1 = latency_cnt_1 + 1;
            end



            //3. Write Back Logic
            if(latency_cnt_2 == (regfile.pool__pool_vert-1)*regfile.pool__data_wid + regfile.pool__pool_horiz) begin

                if(input_idx_ff3 < output_size) begin

                    if(pool_valid_d == 1) begin
                        if(cbe_on == 0) begin
                            for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                                intf_buf2_m1_ctrl.m1_w_en[i0] = 1;
                                intf_buf2_m1_ctrl.m1_w_addr[i0] = output_size*cb + input_idx_ff3;
                            end//for i0 
                        end else begin
                            for(int i0 = 0; i0 < extra_c; i0 = i0 + 1) begin
                                intf_buf2_m1_ctrl.m1_w_en[i0] = 1;
                                intf_buf2_m1_ctrl.m1_w_addr[i0] = output_size*cb + input_idx_ff3;
                            end
                        end//for i0

                        next_input_idx_ff3 = input_idx_ff3 + 1;

                    end else begin //pool_valid_d == 0

                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_buf2_m1_ctrl.m1_w_en[i0] = 0;
                            intf_buf2_m1_ctrl.m1_w_addr[i0] = output_size*cb + input_idx_ff3;
                        end//for i0


                        next_input_idx_ff3 = input_idx_ff3;
                    end //pool_valid_d

                end//input_idx_ff3 < ..


            end else begin
                next_latency_cnt_2 = latency_cnt_2 + 1;
            end




            if(input_idx_ff3 == output_size) begin
                //All over jump to parent state
                next_state = s_CB;
            end




        end



    endcase



end


logic   [15:0]  horiz_cnt, next_horiz_cnt;
logic   [15:0]  vert_cnt, next_vert_cnt;
logic   [15:0]  col_num, next_col_num;

always_comb begin

    next_horiz_cnt = horiz_cnt;
    next_vert_cnt = vert_cnt;
    next_col_num = col_num;

    if(state == s_CB_I) begin
        if(latency_cnt_2 == (regfile.pool__pool_vert-1)*regfile.pool__data_wid + regfile.pool__pool_horiz ) begin

            if(horiz_cnt < regfile.pool__pool_horiz -1 ) begin
                next_horiz_cnt = horiz_cnt + 1;
            end else if(horiz_cnt == regfile.pool__pool_horiz - 1 ) begin
                next_horiz_cnt = 0;
            end

            if(col_num == regfile.pool__data_wid - 1 ) begin
                if(vert_cnt < regfile.pool__pool_vert -1 ) begin
                    next_vert_cnt = vert_cnt + 1;
                end else if(vert_cnt == regfile.pool__pool_vert - 1) begin
                    next_vert_cnt = 0;
                end

            end else begin 
                next_vert_cnt = vert_cnt;

            end

            if(col_num < regfile.pool__data_wid -1 ) begin
                next_col_num = col_num + 1;
            end else if(col_num == regfile.pool__data_wid - 1 ) begin
                next_col_num = 0;
            end


            if(horiz_cnt == 0 && vert_cnt == 0) begin
                pool_valid = 1;
            end else begin
                pool_valid = 0;
            end

        end else begin
            pool_valid = 0;
        end
    end else begin
        next_horiz_cnt = 0;
        next_vert_cnt = 0;
        next_col_num = 0;
        pool_valid = 0;
    end

end



always_ff@(posedge clk, posedge rst) begin
    if(rst) begin
        horiz_cnt <= #1 0;
        vert_cnt <= #1 0;
        col_num <= #1 0;
        pool_valid_cnt <= #1 0;
    end else begin
        horiz_cnt <= #1 next_horiz_cnt;
        vert_cnt <= #1 next_vert_cnt;
        col_num <= #1 next_col_num;
        pool_valid_cnt[15:0] <= #1 {pool_valid_cnt[14:0],pool_valid};
    end
end


assign pool_valid_d = pool_valid_cnt[`LAT_POOL-1];










assign extra_c =  (channels - {channels[15:`LOG_N_PE], {`LOG_N_PE{1'b0}} } );

always_comb begin
    extra_c_present = 0;
    if(extra_c > 0 ) begin
        extra_c_present = 1;
    end
end

assign CBe = CB + extra_c_present;

assign channels = regfile.pool__data_ch;
assign input_size = regfile.pool__data_wid * regfile.pool__data_hei;

assign regfile.pool__out_data_hei = (regfile.pool__data_hei)/regfile.pool__pool_vert ;
assign regfile.pool__out_data_wid = (regfile.pool__data_wid)/regfile.pool__pool_horiz ;

assign output_width = regfile.pool__out_data_wid;
assign output_height = regfile.pool__out_data_hei;
assign output_size = regfile.pool__out_data_hei*regfile.pool__out_data_wid;

assign CB = (channels >> `LOG_N_PE);



assign ping_pong = 1; //ping
assign aybz_azby = (ping_pong == 1) ? 2'b01 : 2'b00 ;















endmodule

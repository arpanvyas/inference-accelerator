module conv (
    input   logic   clk,
    input   logic   rst,
    input   logic   start,
    interface_regfile   regfile,
    interface_pe_array_ctrl     intf_pea_ctrl,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl,
    output  logic [1:0]  aybz_azby,
    output  logic   done

);


//always_ff@(posedge clk, posedge rst) begin
//
//    if(rst) begin
//        done <= #1 0;
//    end else begin
//
//        done <= #1 0;
//
//        if(start) begin
//            done <= #1 1;
//        end
//
//    end
//end

logic [`ADDR_RAM-1:0]  buf1_wr_addr         [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf1_wr_addr    [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  buf2_wr_addr         [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf2_wr_addr    [`N_BUF-1:0];

logic [`ADDR_RAM-1:0]  buf1_rd_addr        [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf1_rd_addr   [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  buf2_rd_addr        [`N_BUF-1:0];
logic [`ADDR_RAM-1:0]  next_buf2_rd_addr   [`N_BUF-1:0];

logic ping_pong; //1: ping, 0: pong

//L1 : Separator for input and filter in a buffer
logic [`ADDR_RAM-1:0]  L1                  [`N_BUF-1:0];
//S1 : Size of a channel for all filters
logic [15:0]           S1;
//n_S1 : Number of channels in buffer_i for each filter
logic [15:0]           n_S1 [`N_BUF-1:0];
logic [15:0]           n_s1 [`N_BUF-1:0];

logic   [`LOG_N_PE-1:0] extra_f;
logic   extra_f_present;
logic   [`N_PE-1:0] extra_c;
logic   extra_c_present;


logic signed  [7:0]   FB, next_fb, fb;
logic   [7:0]   next_f_mod, f_mod;//Filter blocks
logic signed   [7:0]   CB, next_cb, cb;
logic   [7:0]   next_c_mod, c_mod;//Channel blocks
logic   [7:0]   CBe;
logic   [7:0]   FBe;
logic           cbe_on, next_cbe_on;
logic           fbe_on, next_fbe_on;

logic   [15:0]  f_act;

logic   [15:0]  channels;
logic   [15:0]  filters;
logic   [15:0]  input_size;
logic   [15:0]  output_size;
logic   [15:0]  output_width;
logic   [15:0]  output_height;
logic   [7:0]   filter_size;

logic   [7:0]   kern_idx, next_kern_idx;
logic   [15:0]  input_idx_ff1, next_input_idx_ff1; //read from BUF1
logic   [15:0]  input_idx_ff2, next_input_idx_ff2; //write to PEA
logic   [15:0]  input_idx_ff3, next_input_idx_ff3; //Mac Enable
logic   [15:0]  input_idx_ff4, next_input_idx_ff4; //write to BUF2
logic   [15:0]  input_idx_ff4_gate, next_input_idx_ff4_gate; //write to BUF2
logic           ff4_gate;

logic   [15:0]  input_idx_fb1, next_input_idx_fb1; //read from buf2
logic   [15:0]  input_idx_fb1_gate, next_input_idx_fb1_gate; //read from buf2
logic           fb1_gate;
logic   [15:0]  input_idx_fb2, next_input_idx_fb2; 
logic   [15:0]  input_idx_fb2_gate, next_input_idx_fb2_gate; 
logic           fb2_gate;
logic   [15:0]  input_idx_fb3, next_input_idx_fb3; 
logic   [15:0]  input_idx_fb3_gate, next_input_idx_fb3_gate; 
logic           fb3_gate;
logic   [15:0]  input_idx_fb4, next_input_idx_fb4; 
logic   [15:0]  input_idx_fb4_gate, next_input_idx_fb4_gate; 
logic           fb4_gate;

logic   [15:0]  latency_cnt_01, next_latency_cnt_01;
logic   [15:0]  latency_cnt_02, next_latency_cnt_02;
logic   [15:0]  latency_cnt_1, next_latency_cnt_1;
logic   [15:0]  latency_inp_sh_to_mac_en, latency_cnt_2, next_latency_cnt_2;
logic   [15:0]  latency_mac_en_to_write_back, latency_cnt_3, next_latency_cnt_3;
logic   [15:0]  latency_feedback_start, latency_cnt_4, next_latency_cnt_4;
logic   [15:0]  latency_cnt_4_d, next_latency_cnt_4_d;        
logic   [15:0]  latency_nl_start, latency_cnt_5, next_latency_cnt_5;
logic   [15:0]  latency_cnt_6, next_latency_cnt_6;


typedef enum { IDLE, s_FB, s_FB_CB, s_FB_CB_F, s_FB_CB_F_push_cb, s_FB_CB_I_CH  } ConvStates;

ConvStates state;
ConvStates next_state, prev_state;

always_ff@(posedge clk, posedge rst) begin
    if(rst) begin
        state <= #1 IDLE;

        fb  <= #1 -1;
        cb  <= #1 -1;

        cbe_on <= #1 0;
        fbe_on <= #1 0;

        f_mod <= #1 0;
        c_mod <= #1 0;

        kern_idx <= #1 0;
        input_idx_ff1 <= #1 0;
        input_idx_ff2 <= #1 0;
        input_idx_ff3 <= #1 0;
        input_idx_ff4 <= #1 0;
        input_idx_ff4_gate <= #1 0;
        input_idx_fb1 <= #1 0;
        input_idx_fb2 <= #1 0;
        input_idx_fb3 <= #1 0;
        input_idx_fb4 <= #1 0;

        latency_cnt_01 <= #1 0;
        latency_cnt_02 <= #1 0;
        latency_cnt_1 <= #1 0;
        latency_cnt_2 <= #1 0;
        latency_cnt_3 <= #1 0;
        latency_cnt_4 <= #1 0;
        latency_cnt_4_d <= #1 0;
        latency_cnt_5 <= #1 0;
        latency_cnt_6 <= #1 0;

    end else begin
        state <= #1 next_state;
        prev_state <= #1 state;

        fb  <= #1 next_fb;
        cb  <= #1 next_cb;

        cbe_on <= #1 next_cbe_on;
        fbe_on <= #1 next_fbe_on;

        f_mod <= #1 next_f_mod;
        c_mod <= #1 next_c_mod;

        kern_idx <= #1 next_kern_idx;
        input_idx_ff1 <= #1 next_input_idx_ff1;
        input_idx_ff2 <= #1 next_input_idx_ff2;
        input_idx_ff3 <= #1 next_input_idx_ff3;
        input_idx_ff4 <= #1 next_input_idx_ff4;
        input_idx_ff4_gate <= #1 next_input_idx_ff4_gate;
        input_idx_fb1 <= #1 next_input_idx_fb1;
        input_idx_fb1_gate <= #1 next_input_idx_fb1_gate;
        input_idx_fb2 <= #1 next_input_idx_fb2;
        input_idx_fb2_gate <= #1 next_input_idx_fb2_gate;
        input_idx_fb3 <= #1 next_input_idx_fb3;
        input_idx_fb3_gate <= #1 next_input_idx_fb3_gate;
        input_idx_fb4 <= #1 next_input_idx_fb4;
        input_idx_fb4_gate <= #1 next_input_idx_fb4_gate;

        latency_cnt_01 <= #1 next_latency_cnt_01;
        latency_cnt_02 <= #1 next_latency_cnt_02;
        latency_cnt_1 <= #1 next_latency_cnt_1;
        latency_cnt_2 <= #1 next_latency_cnt_2;
        latency_cnt_3 <= #1 next_latency_cnt_3;
        latency_cnt_4 <= #1 next_latency_cnt_4;
        latency_cnt_4_d <= #1 next_latency_cnt_4_d;
        latency_cnt_5 <= #1 next_latency_cnt_5;
        latency_cnt_6 <= #1 next_latency_cnt_6;

    end
end


always_comb begin

    next_state = state;
    done = 0;
    next_fb = fb;
    next_fbe_on = fbe_on;
    next_cb = cb;
    next_cbe_on = cbe_on;

    next_f_mod = f_mod;
    next_c_mod = c_mod;


    next_kern_idx = kern_idx;
    next_input_idx_ff1 = input_idx_ff1;
    next_input_idx_ff2 = input_idx_ff2;
    next_input_idx_ff3 = input_idx_ff3;
    next_input_idx_ff4 = input_idx_ff4;
    next_input_idx_ff4_gate = input_idx_ff4_gate;
    next_input_idx_fb1 = input_idx_fb1;
    next_input_idx_fb1_gate = input_idx_fb1_gate;
    next_input_idx_fb2 = input_idx_fb2;
    next_input_idx_fb2_gate = input_idx_fb2_gate;
    next_input_idx_fb3 = input_idx_fb3;
    next_input_idx_fb3_gate = input_idx_fb3_gate;
    next_input_idx_fb4 = input_idx_fb4;
    next_input_idx_fb4_gate = input_idx_fb4_gate;



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

    intf_pea_ctrl.shifting_bias = 0;
    intf_pea_ctrl.bias_enable = 0;
    intf_pea_ctrl.nl_enable = 0;
    intf_pea_ctrl.row_length = regfile.conv__data_wid;
    intf_pea_ctrl.nl_type = regfile.nl__nl_type;
    intf_pea_ctrl.adder_enable = 0;
    intf_pea_ctrl.line_buffer_reset = 1;
    intf_pea_ctrl.pool_enable = 0;
    intf_pea_ctrl.dense_enable = 0;
    intf_pea_ctrl.dense_valid = 0;
    intf_pea_ctrl.dense_adder_reset = 0;
    intf_pea_ctrl.dense_adder_on = 0;
    intf_pea_ctrl.dense_latch = 0;
    intf_pea_ctrl.dense_rd_addr = 0;

    next_latency_cnt_01 = latency_cnt_01;
    next_latency_cnt_02 = latency_cnt_02;
    next_latency_cnt_1 = latency_cnt_1;
    next_latency_cnt_2 = latency_cnt_2;
    next_latency_cnt_3 = latency_cnt_3;

    next_latency_cnt_4 = latency_cnt_4;
    next_latency_cnt_4_d = latency_cnt_4_d;
    next_latency_cnt_5 = latency_cnt_5;
    next_latency_cnt_6 = latency_cnt_6;

    case(state) 


        IDLE : begin
            if(start) begin
                next_state = s_FB;
            end

        end


        s_FB : begin //for filter_block in FILTER_BLOCK

            //fb enters with FB_ENTER, goes to comp with FB_COMP = FB_ENTER+1 
            //Finally leaves when FB_ENTER == FBe - 1

            if(prev_state != s_FB) begin
                if(fb == FBe-1) begin
                    next_state = IDLE;
                    next_fbe_on = 0;
                    next_fb = -1;
                    done = 1;
                end else begin
                    next_fb = fb + 1;
                    next_state = s_FB_CB;
                    if(FB < FBe && fb == FB-1) begin
                        next_fbe_on = 1;
                    end else begin
                        next_fbe_on = 0;
                    end
                end
            end 


        end


        s_FB_CB : begin //for channel_block in CHANNLE_BLOCK
            //basically handles fb completely

            if(prev_state != s_FB_CB) begin
                if(cb == CBe-1) begin
                    next_state = s_FB;
                    next_cbe_on = 0;
                    next_cb = -1;
                end else begin
                    next_cb = cb + 1;
                    next_state = s_FB_CB_F;
                    if(CB < CBe && cb == CB-1) begin
                        next_cbe_on = 1;
                    end else begin
                        next_cbe_on = 0;
                    end
                end

            end


        end

        s_FB_CB_F : begin //for filter in filter_block, about to push cb for fb, then push input cb
            //Basically handles fb's specific cb complete

            next_input_idx_ff1 = 0;
            next_input_idx_ff2 = 0;
            next_input_idx_ff3 = 0;
            next_input_idx_ff4 = 0;
            next_input_idx_ff4_gate = 0;

            next_input_idx_fb1 = 0;
            next_input_idx_fb1_gate = 0;
            next_input_idx_fb2 = 0;
            next_input_idx_fb2_gate = 0;
            next_input_idx_fb3 = 0;
            next_input_idx_fb3_gate = 0;
            next_input_idx_fb4 = 0;
            next_input_idx_fb4_gate = 0;

            next_latency_cnt_01 = 0;
            next_latency_cnt_02 = 0;
            next_latency_cnt_1 = 0;
            next_latency_cnt_2 = 0;
            next_latency_cnt_3 = 0;
            next_latency_cnt_4 = 0;
            next_latency_cnt_4_d = 0;
            next_latency_cnt_5 = 0;
            next_latency_cnt_6 = 0;

            next_kern_idx = 0;


            if(prev_state == s_FB_CB) begin
                next_f_mod = 0;
                next_state = s_FB_CB_F_push_cb;

            end else if (prev_state == s_FB_CB_F_push_cb) begin
                if(fbe_on == 1) begin
                    if(f_mod == extra_f) begin  
                        //Means fb's cb filters pushed, now push cb inputs
                        next_state = s_FB_CB_I_CH; 
                        next_f_mod = 0;
                    end else begin
                        next_f_mod = f_mod + 1;
                        next_state = s_FB_CB_F_push_cb;
                    end
                end else begin 
                    if(f_mod == `N_PE-1) begin  
                        //Means fb's cb filters pushed, now push cb inputs
                        next_state = s_FB_CB_I_CH; 
                        next_f_mod = 0;
                    end else begin
                        next_f_mod = f_mod + 1;
                        next_state = s_FB_CB_F_push_cb;
                    end
                end

            end else if (prev_state == s_FB_CB_I_CH) begin
                next_state = s_FB_CB;

            end

        end

        s_FB_CB_F_push_cb : begin //pushes ( f_mod + fb = f_act ) filter's cb
            //also pushes filter's bias when cb is last
            //  in CB


            //1. Reading logic
            if(latency_cnt_01 == 0 && kern_idx < filter_size) begin

                for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                    if(cbe_on == 0) begin
                        intf_buf1_m1_ctrl.m1_r_en[i1] = 1;
                        intf_buf1_m1_ctrl.m1_r_addr[i1] = L1[i1] + S1*(cb) + filter_size*(`N_PE*fb+f_mod) + kern_idx;
                    end else begin //extra_c
                        if(extra_c[i1] == 1) begin
                            intf_buf1_m1_ctrl.m1_r_en[i1] = 1;
                            intf_buf1_m1_ctrl.m1_r_addr[i1] = L1[i1] + S1*(cb) + filter_size*(`N_PE*fb+f_mod) + kern_idx;
                        end else begin
                            intf_buf1_m1_ctrl.m1_r_en[i1] = 0;
                            intf_buf1_m1_ctrl.m1_r_addr[i1] = 0;
                        end
                    end
                end //for i1

                next_kern_idx = kern_idx + 1;


                next_latency_cnt_01 = 0;
            end else if(latency_cnt_01 == 0 && kern_idx == filter_size) begin //read bias

                next_kern_idx = 0;
                next_latency_cnt_01 = latency_cnt_01 + 1;

                if(cb == CBe - 1) begin //last cb so now push bias, bother 1 cycle even when use_bias = 0
                    intf_buf1_m1_ctrl.m1_r_en[`N_PE] = 1;
                    intf_buf1_m1_ctrl.m1_r_addr[`N_PE] = (`N_PE*fb+f_mod); //because bias occupies one word
                    next_state = state;
                end else begin //not the last cb, do not bother 1 cycle for bias
                    next_state = s_FB_CB_F;
                end
            end else if(latency_cnt_01 == 1) begin
                next_state = s_FB_CB_F;
                next_kern_idx = 0;
                next_latency_cnt_01 = latency_cnt_01 + 1;
            end

            //2. Writing logic, follows read logic by 1 cycle
            if(latency_cnt_02 == 1) begin

                if(latency_cnt_01 == 0) begin
                    for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                        if(cbe_on == 0) begin
                            intf_pea_ctrl.shifting_filter[f_mod][i1] = 1;                
                        end else begin //extra_c
                            if(extra_c[i1] == 1) begin
                                intf_pea_ctrl.shifting_filter[f_mod][i1] = 1;                
                            end else begin
                                intf_pea_ctrl.shifting_filter[f_mod][i1] = 0;                
                            end
                        end
                    end //for i1
                end else begin //meaning last cb and bias worth (as latency_cnt_01 == 1), reaching here automatically means bais's time
                    for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                        intf_pea_ctrl.shifting_filter[i0] = 0;                
                    end //for i0

                    intf_pea_ctrl.shifting_bias[f_mod] = 1;
                end

                next_latency_cnt_02 = latency_cnt_02;

            end else begin
                next_latency_cnt_01 = latency_cnt_02 + 1;
            end
        end

        s_FB_CB_I_CH : begin

            intf_pea_ctrl.line_buffer_reset = 0;


            //I. Feed forward

            //I.1. Read Image logic

            if(input_idx_ff1 < input_size ) begin

                for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                    if(cbe_on == 0) begin
                        intf_buf1_m1_ctrl.m1_r_en[i1] = 1;
                        intf_buf1_m1_ctrl.m1_r_addr[i1] = input_size*cb + input_idx_ff1;
                    end else begin //extra_c
                        if(extra_c[i1] == 1) begin
                            intf_buf1_m1_ctrl.m1_r_en[i1] = 1;
                            intf_buf1_m1_ctrl.m1_r_addr[i1] = input_size*cb + input_idx_ff1;
                        end else begin
                            intf_buf1_m1_ctrl.m1_r_en[i1] = 0;
                            intf_buf1_m1_ctrl.m1_r_addr[i1] = 0;
                        end
                    end
                end //for i1

                next_input_idx_ff1 = input_idx_ff1 + 1;

            end

            //I.2. Writing logic, follows read logic by 1 cycle
            if(latency_cnt_1 == 1) begin

                if(input_idx_ff2 < input_size ) begin
                    if(fbe_on == 1) begin

                        for(int i0 = 0; i0 < extra_f; i0 = i0 + 1) begin 
                            for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                                if(cbe_on == 0) begin
                                    intf_pea_ctrl.shifting_line[i0][i1] = 1;                
                                end else begin //extra_c
                                    if(extra_c[i1] == 1) begin
                                        intf_pea_ctrl.shifting_line[i0][i1] = 1;                
                                    end else begin
                                        intf_pea_ctrl.shifting_line[i0][i1] = 0;                
                                    end
                                end
                            end //for i1
                        end //for i0

                    end else begin //!fbe_on

                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                                if(cbe_on == 0) begin
                                    intf_pea_ctrl.shifting_line[i0][i1] = 1;                
                                end else begin //extra_c
                                    if(extra_c[i1] == 1) begin
                                        intf_pea_ctrl.shifting_line[i0][i1] = 1;                
                                    end else begin
                                        intf_pea_ctrl.shifting_line[i0][i1] = 0;                
                                    end
                                end
                            end //for i1
                        end //for i0

                    end //if !fbe_on

                    next_input_idx_ff2 = input_idx_ff2 + 1;

                end

            end else begin
                next_latency_cnt_1 = latency_cnt_1 + 1;
            end



            //I.3. MAC enable logic
            if(latency_cnt_2 == (regfile.conv__filter_hei-1)*regfile.conv__data_wid + regfile.conv__filter_wid ) begin

                if(input_idx_ff3 < input_size - ( (regfile.conv__filter_hei-1)*regfile.conv__data_wid + regfile.conv__filter_wid) ) begin
                    if(fbe_on == 1) begin

                        for(int i0 = 0; i0 < extra_f; i0 = i0 + 1) begin 
                            for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                                if(cbe_on == 0) begin
                                    intf_pea_ctrl.mac_enable[i0][i1] = 1;                
                                end else begin //extra_c
                                    if(extra_c[i1] == 1) begin
                                        intf_pea_ctrl.mac_enable[i0][i1] = 1;                
                                    end else begin
                                        intf_pea_ctrl.mac_enable[i0][i1] = 0;                
                                    end
                                end
                            end //for i1
                        end //for i0

                    end else begin //!fbe_on

                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                                if(cbe_on == 0) begin
                                    intf_pea_ctrl.mac_enable[i0][i1] = 1;                
                                end else begin //extra_c
                                    if(extra_c[i1] == 1) begin
                                        intf_pea_ctrl.mac_enable[i0][i1] = 1;                
                                    end else begin
                                        intf_pea_ctrl.mac_enable[i0][i1] = 0;                
                                    end
                                end
                            end //for i1
                        end //for i0

                    end //if !fbe_on

                    next_input_idx_ff3 = input_idx_ff3 + 1;

                end

            end else begin
                next_latency_cnt_2 = latency_cnt_2 + 1;
            end


            //I.4. Write to BUF2 Logic
            if(latency_cnt_3 == (regfile.conv__filter_hei-1)*regfile.conv__data_wid+regfile.conv__filter_wid+`LAT_MAC+`LAT_ADD_TREE+`LAT_FB_ADD+`LAT_BIAS_ADD+`LAT_NL) begin

                if(input_idx_ff4 < output_size) begin

                    if(ff4_gate == 1) begin
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            if(fbe_on == 0) begin
                                intf_buf2_m1_ctrl.m1_w_en[i0] = 1;
                                intf_buf2_m1_ctrl.m1_w_addr[i0] = output_size*fb + input_idx_ff4;
                            end else begin
                                if(extra_f[i0] == 1) begin
                                    intf_buf2_m1_ctrl.m1_w_en[i0] = 1;
                                    intf_buf2_m1_ctrl.m1_w_addr[i0] = output_size*fb + input_idx_ff4;
                                end else begin
                                    intf_buf2_m1_ctrl.m1_w_en[i0] = 0;
                                    intf_buf2_m1_ctrl.m1_w_addr[i0] = 0;
                                end

                            end

                        end//for i0

                        next_input_idx_ff4 = input_idx_ff4 + 1;

                    end else begin //ff4_gate == 0

                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_buf2_m1_ctrl.m1_w_en[i0] = 0;
                            intf_buf2_m1_ctrl.m1_w_addr[i0] = output_size*fb + input_idx_ff4;
                        end//for i0


                        next_input_idx_ff4 = input_idx_ff4;
                    end //ff4_gate

                end//input_idx_ff4 < ..


                if(input_idx_ff4_gate < output_width) begin
                    next_input_idx_ff4_gate = input_idx_ff4_gate + 1;
                end else if(input_idx_ff4_gate < output_width + regfile.conv__filter_wid - 2 ) begin
                    next_input_idx_ff4_gate = input_idx_ff4_gate + 1;
                end else if(input_idx_ff4_gate == output_width + regfile.conv__filter_wid - 2) begin
                    next_input_idx_ff4_gate = 0;
                end



            end else begin
                next_latency_cnt_3 = latency_cnt_3 + 1;
            end


            //II. Feed Back logic

            //II.1. Feedback Reads From Buffer2, Read Logic
            if(latency_cnt_4 == (regfile.conv__filter_hei-1)*regfile.conv__data_wid+regfile.conv__filter_wid+`LAT_MAC+`LAT_ADD_TREE-1) begin 

                if(input_idx_fb1 < output_size) begin

                    if(fb1_gate == 1) begin
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            if(cb > 0 && fbe_on == 0) begin
                                intf_buf2_m1_ctrl.m1_r_en[i0] = 1;
                                intf_buf2_m1_ctrl.m1_r_addr[i0] = output_size*fb + input_idx_fb1;
                            end else if(cb > 0) begin //fbe_on
                                if(extra_f[i0] == 1) begin
                                    intf_buf2_m1_ctrl.m1_r_en[i0] = 1;
                                    intf_buf2_m1_ctrl.m1_r_addr[i0] = output_size*fb + input_idx_fb1;
                                end else begin
                                    intf_buf2_m1_ctrl.m1_r_en[i0] = 0;
                                    intf_buf2_m1_ctrl.m1_r_addr[i0] = 0;
                                end
                            end
                        end //for i0

                        next_input_idx_fb1 = input_idx_fb1 + 1;
                    end else begin

                        for(int i0=0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_buf2_m1_ctrl.m1_r_en[i0] = 0;
                            intf_buf2_m1_ctrl.m1_r_addr[i0] = output_size*fb + input_idx_fb1;
                        end

                        next_input_idx_fb1 = input_idx_fb1;

                    end //fb1_gate 

                end

                if(input_idx_fb1_gate < output_width) begin
                    next_input_idx_fb1_gate = input_idx_fb1_gate + 1;
                end else if(input_idx_fb1_gate < output_width + regfile.conv__filter_wid - 2 ) begin
                    next_input_idx_fb1_gate = input_idx_fb1_gate + 1;
                end else if(input_idx_fb1_gate == output_width + regfile.conv__filter_wid - 2) begin
                    next_input_idx_fb1_gate = 0;
                end



            end else begin
                next_latency_cnt_4 = latency_cnt_4 + 1;
            end


            //II.2. Feedback Write to PEA, Write Logic, follows read logic by 1 cycle
            if(latency_cnt_4_d == (regfile.conv__filter_hei-1)*regfile.conv__data_wid+regfile.conv__filter_wid+`LAT_MAC+`LAT_ADD_TREE) begin

                if(input_idx_fb2 < output_size) begin

                    if(fb2_gate == 1) begin
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            if(cb > 0 && fbe_on == 0) begin
                                intf_pea_ctrl.feedback_enable[i0] = 1;
                            end else if(cb > 0) begin //fbe_on
                                if(extra_f[i0] == 1) begin
                                    intf_pea_ctrl.feedback_enable[i0] = 1;     
                                end else begin
                                    intf_pea_ctrl.feedback_enable[i0] = 0;     
                                end
                            end
                        end //for i0

                        next_input_idx_fb2 = input_idx_fb2 + 1;

                    end else begin
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_pea_ctrl.feedback_enable[i0] = 0;
                        end
                        next_input_idx_fb2 = input_idx_fb2;
                    end

                end



                if(input_idx_fb2_gate < output_width) begin
                    next_input_idx_fb2_gate = input_idx_fb2_gate + 1;
                end else if(input_idx_fb2_gate < output_width + regfile.conv__filter_wid - 2 ) begin
                    next_input_idx_fb2_gate = input_idx_fb2_gate + 1;
                end else if(input_idx_fb2_gate == output_width + regfile.conv__filter_wid - 2) begin
                    next_input_idx_fb2_gate = 0;
                end



            end else begin
                next_latency_cnt_4_d = latency_cnt_4_d + 1;
            end

            //II.3. Bias Add: When to do it, lets do it for all filters, we'll
            //only store a few from I.4.
            if(latency_cnt_5 == (regfile.conv__filter_hei-1)*regfile.conv__data_wid+regfile.conv__filter_wid+`LAT_MAC+`LAT_ADD_TREE+`LAT_FB_ADD) begin
                if(input_idx_fb3 < output_size) begin
                    if(fb3_gate == 1) begin
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            if(cb == CBe - 1) begin
                                intf_pea_ctrl.bias_enable[i0] = 1;
                            end else begin
                                intf_pea_ctrl.bias_enable[i0] = 0;
                            end
                        end //for (int i0 ..
                        next_input_idx_fb3 = input_idx_fb3 + 1;
                    end else begin
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_pea_ctrl.bias_enable[i0] = 0;
                        end
                        next_input_idx_fb3 = input_idx_fb3;
                    end //fb3_gate
                end
                if(input_idx_fb3_gate < output_width) begin
                    next_input_idx_fb3_gate = input_idx_fb3_gate + 1;
                end else if(input_idx_fb3_gate < output_width + regfile.conv__filter_wid - 2 ) begin
                    next_input_idx_fb3_gate = input_idx_fb3_gate + 1;
                end else if(input_idx_fb3_gate == output_width + regfile.conv__filter_wid - 2) begin
                    next_input_idx_fb3_gate = 0;
                end
            end else begin
                next_latency_cnt_5 = latency_cnt_5 + 1;
            end

            //II.4. Non Linear: When to do it
            if(latency_cnt_6 == (regfile.conv__filter_hei-1)*regfile.conv__data_wid+regfile.conv__filter_wid+`LAT_MAC+`LAT_ADD_TREE+`LAT_FB_ADD+`LAT_BIAS_ADD) begin
                if(input_idx_fb4 < output_size) begin
                    if(fb4_gate == 1) begin
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            if(cb == CBe - 1) begin
                                intf_pea_ctrl.nl_enable[i0] = 1;
                            end else begin
                                intf_pea_ctrl.nl_enable[i0] = 0;
                            end
                        end //for (int i0 ..
                        next_input_idx_fb4 = input_idx_fb4 + 1;
                    end else begin
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_pea_ctrl.nl_enable[i0] = 0;
                        end
                        next_input_idx_fb4 = input_idx_fb4;
                    end //fb4_gate
                end
                if(input_idx_fb4_gate < output_width) begin
                    next_input_idx_fb4_gate = input_idx_fb4_gate + 1;
                end else if(input_idx_fb4_gate < output_width + regfile.conv__filter_wid - 2 ) begin
                    next_input_idx_fb4_gate = input_idx_fb4_gate + 1;
                end else if(input_idx_fb4_gate == output_width + regfile.conv__filter_wid - 2) begin
                    next_input_idx_fb4_gate = 0;
                end
            end else begin
                next_latency_cnt_5 = latency_cnt_5 + 1;
            end

            if(input_idx_ff4 == output_size) begin
                //All over jump to parent state
                next_state = s_FB_CB_F;

            end

        end //s_FB_CB_F_push_cb


    endcase

end

assign ff4_gate = (input_idx_ff4_gate < output_width) ? 1'b1 : 1'b0;
assign fb1_gate = (input_idx_fb1_gate < output_width) ? 1'b1 : 1'b0;
assign fb2_gate = (input_idx_fb2_gate < output_width) ? 1'b1 : 1'b0;
assign fb3_gate = (input_idx_fb3_gate < output_width) ? 1'b1 : 1'b0;
assign fb4_gate = (input_idx_fb4_gate < output_width) ? 1'b1 : 1'b0;

always_comb begin

    if(input_idx_ff4_gate < output_width) begin 

    end


end




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//NOTE: The ff4/fb1,2,3_gate logic is to ensure while input wrapping, output
//is not captured
//
//Although only ff4_gate : for wr_en = 0 and wr_addr STILL and fb1 : for
//rd_addr STILL are required
//
//Still just for uniformity this gate logic is put on fb2 and fb3 as well
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////


























assign channels = regfile.conv__data_ch;
assign filters  = regfile.conv__filter_num;
assign input_size = regfile.conv__data_wid * regfile.conv__data_hei;

assign regfile.conv__out_data_hei = (regfile.conv__data_hei + 2*regfile.conv__padding_vert - regfile.conv__filter_hei)/regfile.conv__stride_vert + 1;
assign regfile.conv__out_data_wid = (regfile.conv__data_wid + 2*regfile.conv__padding_horiz - regfile.conv__filter_wid)/regfile.conv__stride_horiz + 1;
assign output_width = regfile.conv__out_data_wid;
assign output_height = regfile.conv__out_data_hei;
assign output_size = regfile.conv__out_data_hei*regfile.conv__out_data_wid;

assign filter_size = regfile.conv__filter_wid * regfile.conv__filter_hei;
assign FB = (filters >> `LOG_N_PE);
assign CB = (channels >> `LOG_N_PE);

assign latency_inp_sh_to_mac_en = regfile.conv__data_wid*2 + regfile.conv__filter_wid;
assign latency_mac_en_to_write_back = 5; //adder tree delay


assign ping_pong = 1; //ping
assign aybz_azby = (ping_pong == 1) ? 2'b01 : 2'b00 ;





//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Parameters for memory locations
//
//extra_c : for each buffer <-> PE, number of extra_c channels per buffer (0 or 1)
//
//
//extra_f : for whole PEA, number of extra_f filters (1 to 31)
//
//L1 : point where input ends and filters/kernels start
//
//S1 : size of kernels for each channel  = kernel_size * filters, same for all
//filters/channels
//
//n_S1 : number of S1's = (extra_c + CB), for each buffer
//
//
//
//  ________________________________________________________________________________________________
//  |C1 input   |C2 input   |C3 input   |##| F1 | F2 | F3 |  | FN || F1  | F2  |    ||              |
//  |           |           |           |L1| C1 | C1 | C1 |..| C1 || C33 | C33 | .. ||              |
//  |___________|___________|___________|##|____|____|____|__|____||_____|_____|____||______________|
//
//                                         |<--------------------->|
//                                                  S1
//
//                                                 n_S1
//  
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


always_comb begin
    for(int idx_var = 0; idx_var < `N_PE; idx_var = idx_var + 1) begin
        extra_c[idx_var] = ( (channels - {channels[15:`LOG_N_PE],{`LOG_N_PE{1'b0}} }) > idx_var ) ? 1 : 0;
    end
end



assign extra_f =  (filters - {filters[15:`LOG_N_PE], {`LOG_N_PE{1'b0}} } );

always_comb begin
    extra_c_present = 0;
    for(int idx_var = 0; idx_var < `N_PE; idx_var = idx_var + 1) begin
        extra_c_present = extra_c_present || extra_c[idx_var];
    end
end

always_comb begin
    extra_f_present = 0;
    if(extra_f > 0 ) begin
        extra_f_present = 1;
    end
end

assign CBe = CB + extra_c_present;
assign FBe = FB + extra_f_present;


always_comb begin
    for (int idx_var = 0; idx_var < `N_PE; idx_var = idx_var + 1) begin
        L1[idx_var] = input_size*(extra_c[idx_var] + CB);
    end
end

assign S1 = filter_size*filters;

always_comb begin
    for (int idx_var = 0; idx_var < `N_PE; idx_var = idx_var + 1) begin
        n_S1[idx_var] = extra_c[idx_var] + CB;
    end

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

        for(int idx_var = 0; idx_var < `N_BUF ; idx_var = idx_var + 1) begin
            buf1_wr_addr[idx_var]    <= #1 next_buf1_wr_addr[idx_var];
            buf2_wr_addr[idx_var]    <= #1 next_buf2_wr_addr[idx_var];

            buf1_rd_addr[idx_var]    <= #1 next_buf1_rd_addr[idx_var];
            buf2_rd_addr[idx_var]    <= #1 next_buf2_rd_addr[idx_var];
        end
    end

end


endmodule

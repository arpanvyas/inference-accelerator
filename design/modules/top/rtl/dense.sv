module dense (
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

logic ping_pong; //1: ping, 0: pong

logic   [`LOG_N_PE-1:0] extra_ob;
logic                   extra_ob_present;
logic   signed [15:0]    OB, next_ob, ob;
logic          [15:0]    OBe;


//IB : input blocks, is input_neurons / DENSE_PER_GO
logic   [7:0]       extra_ib;
logic               extra_ib_present;
logic   signed [15:0]     IB, next_ib, ib;
logic          [15:0]     IBe; 


logic                   obe_on, next_obe_on;
logic                   ibe_on, next_ibe_on;

logic   [15:0]          output_neurons, op_nu;
logic   [15:0]          input_neurons, ip_nu;

logic   [15:0]  input_idx_ff1, next_input_idx_ff1; 
logic   [15:0]  input_idx_ff2, next_input_idx_ff2; 
logic   [15:0]  input_idx_ff3, next_input_idx_ff3; 
logic   [15:0]  input_idx_ff3_cycle, next_input_idx_ff3_cycle; 
logic   [15:0]  input_idx_ff4, next_input_idx_ff4; 

logic   [15:0]  latency_cnt_1, next_latency_cnt_1;
logic   [15:0]  latency_cnt_2, next_latency_cnt_2;

logic           mac_now, nl_now;
logic   [15:0]  mac_now_d, nl_now_d, dense_latch_d;
logic           ongoing_dense_out;
logic           ongoing_dense_out_fe;
logic [15:0]    ongoing_dense_out_d;

logic           dense_latch_request, next_dense_latch_request;


typedef enum { IDLE, s_OB, s_OB_I} DenseStates;
DenseStates state;
DenseStates next_state, prev_state;

always_ff@(posedge clk, posedge rst) begin

    if(rst) begin

        state <= #1 IDLE;
        ob    <= #1 -1;
        obe_on <= #1 0;

        ib    <= #1 0;
        ibe_on <= #1 0;

        latency_cnt_1 <= #1 0;
        latency_cnt_2 <= #1 0;

        input_idx_ff1 <= #1 0;
        input_idx_ff2 <= #1 0;
        input_idx_ff3 <= #1 0;
        input_idx_ff4 <= #1 0;

        input_idx_ff3_cycle <= #1 0;

        dense_latch_request <= #1 0;

    end else begin

        state <= #1 next_state;
        prev_state <= #1 state;

        ob  <= #1 next_ob;
        obe_on <= #1 next_obe_on;

        ib  <= #1 next_ib;
        ibe_on <= #1 next_ibe_on;

        input_idx_ff1 <= #1 next_input_idx_ff1;
        input_idx_ff2 <= #1 next_input_idx_ff2;
        input_idx_ff3 <= #1 next_input_idx_ff3;
        input_idx_ff4 <= #1 next_input_idx_ff4;

        latency_cnt_1 <= #1 next_latency_cnt_1;
        latency_cnt_2 <= #1 next_latency_cnt_2;

        input_idx_ff3_cycle <= #1 next_input_idx_ff3_cycle;

        dense_latch_request <= #1 next_dense_latch_request;

    end
end


always_comb begin

    next_state = state;
    done = 0;
    next_input_idx_ff1 = input_idx_ff1;
    next_input_idx_ff2 = input_idx_ff2;
    next_input_idx_ff3 = input_idx_ff3;
    next_input_idx_ff4 = input_idx_ff4;

    intf_pea_ctrl.pool_enable = 0;
    intf_pea_ctrl.dense_valid = 0;
    intf_pea_ctrl.adder_enable = 0;
    intf_pea_ctrl.dense_latch = 0;


    for (int idx_var = 0; idx_var < `N_PE; idx_var = idx_var + 1) begin
        intf_pea_ctrl.shifting_line[idx_var] = 0;
        intf_pea_ctrl.shifting_filter[idx_var] = 0;
        intf_pea_ctrl.mac_enable[idx_var] = 0;
        intf_pea_ctrl.feedback_enable[idx_var] = 0;

        intf_pea_ctrl.dense_adder_reset[idx_var] = 0;
        intf_pea_ctrl.dense_adder_on[idx_var] = 0;
    end

    intf_pea_ctrl.dense_enable = 1;

    for (int i0 = 0; i0 < `N_BUF; i0 = i0 + 1) begin
        intf_buf1_m1_ctrl.m1_r_en[i0] = 0;
        intf_buf1_m1_ctrl.m1_r_addr[i0] = 0;

        intf_buf2_m1_ctrl.m1_r_en[i0] = 0;
        intf_buf2_m1_ctrl.m1_r_addr[i0] = 0;
    end

    intf_pea_ctrl.shifting_bias = 0;
    intf_pea_ctrl.bias_enable = 0;
    intf_pea_ctrl.nl_enable = 0;
    intf_pea_ctrl.row_length = `MAC_COL_MAX;
    intf_pea_ctrl.nl_type = regfile.nl__nl_type;
    intf_pea_ctrl.line_buffer_reset = 1;


    next_latency_cnt_1 = latency_cnt_1;
    next_latency_cnt_2 = latency_cnt_2;

    next_obe_on = obe_on;

    next_ob = ob;

    next_dense_latch_request = dense_latch_request;

    case(state)

        IDLE : begin
            if (start) begin
                next_state = s_OB;
            end
        end

        s_OB : begin
            next_input_idx_ff1 = 0;
            next_input_idx_ff2 = 0;
            next_input_idx_ff3 = 0;
            next_input_idx_ff4 = 0;
            next_latency_cnt_1 = 0;
            next_latency_cnt_2 = 0;

            if(prev_state != s_OB) begin

                if(ob == OBe-1) begin
                    if(ongoing_dense_out == 0) begin
                        next_state = IDLE;
                        next_obe_on = 0;
                        next_ob = -1;
                        done = 1;
                    end //else wait in dense till over
                end else begin
                    next_ob = ob + 1;
                    next_state = s_OB_I;
                    if(OB < OBe && ob == OB-1) begin
                        next_obe_on = 1;
                    end else begin
                        next_obe_on = 0;
                    end
                end

            end else begin
                if(ongoing_dense_out == 0) begin //leave when ongoing over
                    next_state = IDLE;
                    next_obe_on = 0;
                    next_ob = -1;
                    done = 1;
                end
            end

        end //s_OB

        s_OB_I : begin

            intf_pea_ctrl.line_buffer_reset = 0;

            //1. Read Input and Weights logic

            //1.1 Read Weights
            if(input_idx_ff1 < input_neurons + 1) begin
                if(obe_on == 0) begin 
                    for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                        intf_buf1_m1_ctrl.m1_r_en[i1] = 1;
                        intf_buf1_m1_ctrl.m1_r_addr[i1] = (input_neurons+1)*ob + input_idx_ff1;//plus 1 for bias
                    end
                end else begin //extra_ob
                    for(int i1 = 0; i1 <  extra_ob; i1 = i1 + 1) begin
                        intf_buf1_m1_ctrl.m1_r_en[i1] = 1;
                        intf_buf1_m1_ctrl.m1_r_addr[i1] = (input_neurons+1)*ob + input_idx_ff1;//plus 1 for bias
                    end
                end

                next_input_idx_ff1 = input_idx_ff1 + 1;

            end else begin //if(input_idx_ff1..
                next_input_idx_ff1 = input_idx_ff1;
            end

            //1.2 Read Input
            if(input_idx_ff1 < input_neurons) begin
                intf_buf1_m1_ctrl.m1_r_en[`N_PE] = 1;
                intf_buf1_m1_ctrl.m1_r_addr[`N_PE] = input_idx_ff1;
            end

            //2. Write Logic, follows read logic by 1 cycle
            //The dense happens diagonally because i'th input from BUF will go
            //to each PE's i'th Conv
            //Both 2.1 and 2.2
            if(latency_cnt_1 == 1) begin

                if(input_idx_ff2 < input_neurons) begin //matrix row elements
                    if(obe_on == 1) begin
                        for(int i0 = 0; i0 < extra_ob; i0 = i0 + 1) begin
                            intf_pea_ctrl.shifting_filter[i0][i0] = 1;
                            intf_pea_ctrl.shifting_line[i0][`N_PE] = 1;
                        end //for i0
                    end else begin //!obe_on
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_pea_ctrl.shifting_filter[i0][i0] = 1;
                            intf_pea_ctrl.shifting_line[i0][`N_PE] = 1;
                        end //for i0
                    end //if !obe_on

                end else if (input_idx_ff2 == input_neurons) begin //bias, do not shift input only weights
                    if(obe_on == 1) begin
                        for(int i0 = 0; i0 < extra_ob; i0 = i0 + 1) begin
                            intf_pea_ctrl.shifting_filter[i0][i0] = 0;
                            intf_pea_ctrl.shifting_bias[i0] = 1;
                        end //for i0
                    end else begin //!obe_on
                        for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin
                            intf_pea_ctrl.shifting_filter[i0][i0] = 0;
                            intf_pea_ctrl.shifting_bias[i0] = 1;
                        end //for i0
                    end //if !obe_on
                end

                next_input_idx_ff2 = input_idx_ff2 + 1;

            end else begin
                next_latency_cnt_1 = latency_cnt_1 + 1;
            end


            //3. MAC Enable Logic
            if(latency_cnt_2 == 2) begin //at this point data is out of 1'st element
                if(input_idx_ff3 < input_neurons + `LAT_MAC -1) begin
                    //+LAT_MAC for mac latency else no transfer at last stage
                    //-1 because already delayed

                    next_input_idx_ff3 = input_idx_ff3 + 1;

                    //the 0th mac_enable is made high by convention, may be
                    //extenden and made 32nd later
                    if(obe_on == 0) begin 
                        for(int i1 = 0; i1 < `N_PE; i1 = i1 + 1) begin
                            intf_pea_ctrl.mac_enable[i1][0] = 1;
                        end
                    end else begin //extra_ob
                        for(int i1 = 0; i1 <  extra_ob; i1 = i1 + 1) begin
                            intf_pea_ctrl.mac_enable[i1][0] = 1;
                        end
                    end

                end else begin
                    next_input_idx_ff3 = input_idx_ff3;
                end

                next_latency_cnt_2 = latency_cnt_2;
            end else begin
                next_latency_cnt_2 = latency_cnt_2 + 1;
            end

            //4. Marking dense numbers before MAC : via dense valid
            if(mac_now == 1) begin
                if(ibe_on == 0) begin
                    intf_pea_ctrl.dense_valid = `DENSE_PER_GO;
                end else begin
                    intf_pea_ctrl.dense_valid = extra_ib;
                end
            end

            //6.0 Making dense adder ON (accumulator of values)
            if(mac_now_d[`LAT_MAC-1] == 1) begin
                if(obe_on == 0) begin
                    for(int i = 0; i < `N_PE ; i = i + 1) begin
                        intf_pea_ctrl.dense_adder_on[i] = 1;
                    end
                end else begin
                    for(int i = 0; i < extra_ob ; i = i + 1) begin
                        intf_pea_ctrl.dense_adder_on[i] = 1;
                    end
                end
            end

            //6.1 Making bias add ON
            if(nl_now_d[`LAT_MAC+`LAT_DENSE_ADD-1] == 1) begin
                if(obe_on == 0) begin
                    for(int i = 0; i < `N_PE; i= i + 1) begin
                        intf_pea_ctrl.bias_enable[i] = 1;
                    end
                end else begin
                    for(int i = 0; i < extra_ob; i= i + 1) begin
                        intf_pea_ctrl.bias_enable[i] = 1;
                    end
                end
            end


            //6.2 Making non linearity ON
            if(nl_now_d[`LAT_MAC+`LAT_DENSE_ADD+`LAT_BIAS_ADD-1] == 1) begin
                if(obe_on == 0) begin
                    for(int i = 0; i < `N_PE; i= i + 1) begin
                        intf_pea_ctrl.nl_enable[i] = 1;
                    end
                end else begin
                    for(int i = 0; i < extra_ob; i= i + 1) begin
                        intf_pea_ctrl.nl_enable[i] = 1;
                    end
                end
            end


            //7. Dense Latch logic: Required because only single write back
            //point for BUF2, thus latching all values then releasing one by
            //one
            if(nl_now_d[`LAT_MAC+`LAT_NL+`LAT_DENSE_ADD+`LAT_BIAS_ADD-1] == 1 && ongoing_dense_out == 0) begin
                intf_pea_ctrl.dense_latch = 1;
                next_state = s_OB;
            end else if(nl_now_d[`LAT_MAC+`LAT_NL+`LAT_DENSE_ADD+`LAT_BIAS_ADD-1] == 1 && ongoing_dense_out == 1) begin
                intf_pea_ctrl.dense_latch = 0;
                next_dense_latch_request = 1;
            end else if(ongoing_dense_out_fe == 1 && dense_latch_request == 1) begin
                intf_pea_ctrl.dense_latch = 1;
                next_state = s_OB;
                next_dense_latch_request = 0;
            end else begin
                intf_pea_ctrl.dense_latch = 0;
            end






        end //s_OB_I

    endcase

end

//nl logic
always_comb begin

    next_ib = ib;
    next_ibe_on = ibe_on;
    next_input_idx_ff3_cycle = input_idx_ff3_cycle;
    mac_now = 0;
    nl_now = 0;

    if(state == s_OB_I && latency_cnt_2 == 2) begin

        mac_now = 0;
        if(input_idx_ff3 < input_neurons-1) begin //because already delayed by 2

            if(input_idx_ff3_cycle < `DENSE_PER_GO - 1) begin
                next_input_idx_ff3_cycle = input_idx_ff3_cycle + 1;
                mac_now = 0;
            end else begin
                next_input_idx_ff3_cycle = 0;
                mac_now = 1;

                if(IB < IBe && ib == IB - 1) begin
                    next_ibe_on = 1;
                    next_ib = ib + 1;
                    nl_now = 0;
                end else if(IB < IBe && ib == IBe - 1) begin
                    next_ibe_on = 0; 
                    next_ib = 0;
                    nl_now = 1;
                end else if(IB == IBe && ib == IBe - 1) begin
                    next_ibe_on = 0;
                    next_ib = 0;
                    nl_now = 1;
                end else begin
                    next_ibe_on = 0;
                    next_ib = ib + 1;
                    nl_now = 0;
                end

            end //input_idx_ff3_cycle

        end else if(input_idx_ff3 == input_neurons-1) begin
            //because here, now does not matter the modulo, just do mac_now
            mac_now = 1;
            next_input_idx_ff3_cycle = 0;
            if(IB < IBe && ib == IB - 1) begin
                next_ibe_on = 1;
                next_ib = ib + 1;
                nl_now = 0;
            end else if(IB < IBe && ib == IBe - 1) begin
                next_ibe_on = 0; 
                next_ib = 0;
                nl_now = 1;
            end else if(IB == IBe && ib == IBe - 1) begin
                next_ibe_on = 0;
                next_ib = 0;
                nl_now = 1;
            end else begin
                next_ibe_on = 0;
                next_ib = ib + 1;
                nl_now = 0;
            end
        end


    end //input_idx_ff3

end //state == s_OB_I





logic [`LOG_N_PE-1:0] next_dense_rd_addr;
logic [`LOG_N_PE-1:0] dense_rd_addr;
logic [`LOG_N_PE-1:0] dense_rd_addr_d;

logic obe_on_latch;
logic [15:0] ob_latch;
//latching logic
always_comb begin

    next_dense_rd_addr = 0;
    ongoing_dense_out = 0;
    intf_buf2_m1_ctrl.m1_w_en = 0;

    for (int i0 = 0; i0 < `N_BUF; i0 = i0 + 1) begin
        intf_buf1_m1_ctrl.m1_w_en[i0] = 0;
        intf_buf1_m1_ctrl.m1_w_addr[i0] = 0;

        intf_buf2_m1_ctrl.m1_w_en[i0] = 0;
        intf_buf2_m1_ctrl.m1_w_addr[i0] = 0;
    end

    //1. Reading from Latch
    if(obe_on_latch == 0) begin
        if((dense_rd_addr > 0 || dense_latch_d[0] == 1) && dense_rd_addr < `N_PE-1) begin
            ongoing_dense_out = 1;
            next_dense_rd_addr = dense_rd_addr + 1;
        end else if (dense_rd_addr == `N_PE-1) begin
            ongoing_dense_out = 1;
            next_dense_rd_addr = 0;
        end
    end else begin
        if( (dense_rd_addr > 0 || dense_latch_d[0] == 1) && dense_rd_addr < extra_ob-1 ) begin
            ongoing_dense_out = 1;
            next_dense_rd_addr = dense_rd_addr + 1;
        end else if (dense_rd_addr == extra_ob - 1 || dense_latch_d[0] == 1) begin
            //the || above because extra_ob may be 1 as well
            ongoing_dense_out = 1;
            next_dense_rd_addr = 0;
        end
    end

    //2. Writing from Latch (to BUF), DOES NOT follow read by 1 cycle, SAME
    //CYCLE because dense latch is a register file
    if(obe_on_latch == 0) begin
        if((dense_rd_addr > 0 || dense_latch_d[0] == 1) && dense_rd_addr < `N_PE-1) begin
            intf_buf2_m1_ctrl.m1_w_en[`N_PE] = 1;
            intf_buf2_m1_ctrl.m1_w_addr[`N_PE]   = ob_latch*`N_PE + dense_rd_addr; 
        end else if (dense_rd_addr == `N_PE-1) begin
            intf_buf2_m1_ctrl.m1_w_en[`N_PE] = 1;
            intf_buf2_m1_ctrl.m1_w_addr[`N_PE]   = ob_latch*`N_PE + dense_rd_addr; 
        end
    end else begin
        if( (dense_rd_addr > 0 || dense_latch_d[0] == 1) && dense_rd_addr < extra_ob -1 ) begin
            intf_buf2_m1_ctrl.m1_w_en[`N_PE] = 1;
            intf_buf2_m1_ctrl.m1_w_addr[`N_PE]   = ob_latch*`N_PE + dense_rd_addr;
        end else if (dense_rd_addr == extra_ob - 1 || dense_latch_d[0] == 1) begin
            //the || above because extra_ob may be 1 as well
            intf_buf2_m1_ctrl.m1_w_en[`N_PE] = 1;
            intf_buf2_m1_ctrl.m1_w_addr[`N_PE] = ob_latch*`N_PE + dense_rd_addr;
        end

    end


end


always_comb begin //dense_out_start


end

assign intf_pea_ctrl.dense_rd_addr = dense_rd_addr;

always_ff@(posedge clk, posedge rst) begin
    if(rst) begin
        mac_now_d <= #1 0;
        nl_now_d  <= #1 0;
        dense_rd_addr <= #1 0;
        dense_rd_addr_d <= #1 0;
    end else begin
        mac_now_d[15:0] <= #1 {mac_now_d[14:0],mac_now};
        nl_now_d[15:0] <= #1 {nl_now_d[14:0],nl_now};
        dense_latch_d[15:0] <= #1 {dense_latch_d[14:0], intf_pea_ctrl.dense_latch};
        dense_rd_addr <= #1 next_dense_rd_addr;
        ongoing_dense_out_d[15:0] <= #1 {ongoing_dense_out_d[14:0], ongoing_dense_out};
        dense_rd_addr_d <= #1 dense_rd_addr;

        if(intf_pea_ctrl.dense_latch) begin
            obe_on_latch <= #1 obe_on;
            ob_latch     <= #1 ob;
        end


    end
end

assign ongoing_dense_out_fe = (!ongoing_dense_out && ongoing_dense_out_d[0]);





assign OB = (output_neurons / `N_PE);
assign extra_ob = (output_neurons - OB*`N_PE);
assign extra_ob_present = (extra_ob > 0) ? 1 : 0;
assign OBe = OB + extra_ob_present;

assign IB = (input_neurons / `DENSE_PER_GO);
assign extra_ib = (input_neurons - IB*`DENSE_PER_GO);
assign extra_ib_present = (extra_ib > 0) ? 1 : 0;
assign IBe = IB + extra_ib_present;

assign output_neurons = regfile.dense__output_data_length;
assign input_neurons = regfile.dense__input_data_length;

assign ping_pong = 1; //ping
assign aybz_azby = (ping_pong == 1) ? 2'b11 : 2'b10;


endmodule

module buffer_pea_mux (

    
    interface_buffer            intf_buf1,
    interface_buffer            intf_buf2,
    interface_pe_array          intf_pea,

    input   logic   [2:0]       comp_sel,
   
    interface_pe_array_ctrl     intf_pea_ctrl_conv,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl_conv,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl_conv,
    input   logic               aybz_azby_conv,

    interface_pe_array_ctrl     intf_pea_ctrl_dense,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl_dense,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl_dense,
    input   logic               aybz_azby_dense,

    interface_pe_array_ctrl     intf_pea_ctrl_pool,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl_pool,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl_pool,
    input   logic               aybz_azby_pool

);


///////////////////////////////////////////////
//Connect Data Lines From BUF to PEA
//////////////////////////////////////////////


logic   aybz_azby;

//comp_sel
//000: IDLE
//001: CONV
//010: DENSE
//011: POOL
always_comb begin
    case(comp_sel)
        3'b000  : aybz_azby = 1;
        3'b001  : aybz_azby = aybz_azby_conv;
        3'b010  : aybz_azby = aybz_azby_dense;
        3'b011  : aybz_azby = aybz_azby_pool;
        default : aybz_azby = 1;
    endcase
end


assign intf_buf1.m1_input_bus = intf_pea.output_bus1_PEA;
assign intf_buf2.m1_input_bus = intf_pea.output_bus1_PEA;

always_comb begin

    if(aybz_azby) begin
        intf_pea.input_bus1_PEA = intf_buf1.m1_output_bus;
        intf_pea.input_bus2_PEA = intf_buf2.m1_output_bus;
    end else begin 
        intf_pea.input_bus1_PEA = intf_buf2.m1_output_bus;
        intf_pea.input_bus2_PEA = intf_buf1.m1_output_bus;
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
            intf_pea.final_filter_bank = 0;
            intf_pea.shifting_line_pool = 0;
            intf_pea.line_buffer_reset_pool = 0;
            intf_pea.row_length_pool = 0;
            intf_pea.nl_type = 0;
            intf_pea.nl_enable = 0;
            intf_pea.feedback_enable = 0;

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
            intf_pea.final_filter_bank = intf_pea_ctrl_conv.final_filter_bank;
            intf_pea.shifting_line_pool = intf_pea_ctrl_conv.shifting_line_pool;
            intf_pea.line_buffer_reset_pool = intf_pea_ctrl_conv.line_buffer_reset_pool;
            intf_pea.row_length_pool = intf_pea_ctrl_conv.row_length_pool;
            intf_pea.nl_type = intf_pea_ctrl_conv.nl_type;
            intf_pea.nl_enable = intf_pea_ctrl_conv.nl_enable;
            intf_pea.feedback_enable = intf_pea_ctrl_conv.feedback_enable;


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
            intf_pea.final_filter_bank = intf_pea_ctrl_dense.final_filter_bank;
            intf_pea.shifting_line_pool = intf_pea_ctrl_dense.shifting_line_pool;
            intf_pea.line_buffer_reset_pool = intf_pea_ctrl_dense.line_buffer_reset_pool;
            intf_pea.row_length_pool = intf_pea_ctrl_dense.row_length_pool;
            intf_pea.nl_type = intf_pea_ctrl_dense.nl_type;
            intf_pea.nl_enable = intf_pea_ctrl_dense.nl_enable;
            intf_pea.feedback_enable = intf_pea_ctrl_dense.feedback_enable;

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
            intf_pea.final_filter_bank = intf_pea_ctrl_pool.final_filter_bank;
            intf_pea.shifting_line_pool = intf_pea_ctrl_pool.shifting_line_pool;
            intf_pea.line_buffer_reset_pool = intf_pea_ctrl_pool.line_buffer_reset_pool;
            intf_pea.row_length_pool = intf_pea_ctrl_pool.row_length_pool;
            intf_pea.nl_type = intf_pea_ctrl_pool.nl_type;
            intf_pea.nl_enable = intf_pea_ctrl_pool.nl_enable;
            intf_pea.feedback_enable = intf_pea_ctrl_pool.feedback_enable;


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
            intf_pea.final_filter_bank = 0;
            intf_pea.shifting_line_pool = 0;
            intf_pea.line_buffer_reset_pool = 0;
            intf_pea.row_length_pool = 0;
            intf_pea.nl_type = 0;
            intf_pea.nl_enable = 0;
            intf_pea.feedback_enable = 0;


        end

    endcase



end






endmodule

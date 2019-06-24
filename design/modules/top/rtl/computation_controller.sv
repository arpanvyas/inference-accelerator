module computation_controller (

    input   logic clk,
    input   logic rst,
    input   logic   [2:0]   comp_sel,
    output  logic       done,
    input   logic       start_comp,
    interface_regfile   regfile,
    interface_pe_array  intf_pea,
    interface_buffer    intf_buf1,
    interface_buffer    intf_buf2

);


logic   start_conv;
interface_pe_array_ctrl    intf_pea_ctrl_conv();
interface_buffer_m1_ctrl   intf_buf1_m1_ctrl_conv();
interface_buffer_m1_ctrl   intf_buf2_m1_ctrl_conv();
logic [1:0]  aybz_azby_conv;
logic   done_conv;


conv    conv_inst (
    .clk(clk),
    .rst(rst),
    .regfile(regfile),
    .start(start_conv),
    .intf_pea_ctrl(intf_pea_ctrl_conv),
    .intf_buf1_m1_ctrl(intf_buf1_m1_ctrl_conv),
    .intf_buf2_m1_ctrl(intf_buf2_m1_ctrl_conv),
    .aybz_azby(aybz_azby_conv),
    .done(done_conv)

);



logic   start_dense;
interface_pe_array_ctrl    intf_pea_ctrl_dense();
interface_buffer_m1_ctrl   intf_buf1_m1_ctrl_dense();
interface_buffer_m1_ctrl   intf_buf2_m1_ctrl_dense();
logic [1:0]  aybz_azby_dense;
logic   done_dense;


dense   dense_inst (
    .clk(clk),
    .rst(rst),
    .regfile(regfile),
    .start(start_dense),
    .intf_pea_ctrl(intf_pea_ctrl_dense),
    .intf_buf1_m1_ctrl(intf_buf1_m1_ctrl_dense),
    .intf_buf2_m1_ctrl(intf_buf2_m1_ctrl_dense),
    .aybz_azby(aybz_azby_dense),
    .done(done_dense)
);



logic   start_pool;
interface_pe_array_ctrl    intf_pea_ctrl_pool();
interface_buffer_m1_ctrl   intf_buf1_m1_ctrl_pool();
interface_buffer_m1_ctrl   intf_buf2_m1_ctrl_pool();
logic   [1:0]  aybz_azby_pool;
logic   done_pool;


pool    pool_inst (
    .clk(clk),
    .rst(rst),
    .regfile(regfile),
    .start(start_pool),
    .intf_pea_ctrl(intf_pea_ctrl_pool),
    .intf_buf1_m1_ctrl(intf_buf1_m1_ctrl_pool),
    .intf_buf2_m1_ctrl(intf_buf2_m1_ctrl_pool),
    .aybz_azby(aybz_azby_pool),
    .done(done_pool)

);


buffer_pea_mux buffer_pea_mux_inst(

    .intf_buf1(intf_buf1),
    .intf_buf2(intf_buf2),
    .intf_pea(intf_pea),

    .comp_sel(comp_sel),

    .intf_pea_ctrl_conv(intf_pea_ctrl_conv),
    .intf_buf1_m1_ctrl_conv(intf_buf1_m1_ctrl_conv),
    .intf_buf2_m1_ctrl_conv(intf_buf2_m1_ctrl_conv),
    .aybz_azby_conv(aybz_azby_conv),

    .intf_pea_ctrl_dense(intf_pea_ctrl_dense),
    .intf_buf1_m1_ctrl_dense(intf_buf1_m1_ctrl_dense),
    .intf_buf2_m1_ctrl_dense(intf_buf2_m1_ctrl_dense),
    .aybz_azby_dense(aybz_azby_dense),

    .intf_pea_ctrl_pool(intf_pea_ctrl_pool),
    .intf_buf1_m1_ctrl_pool(intf_buf1_m1_ctrl_pool),
    .intf_buf2_m1_ctrl_pool(intf_buf2_m1_ctrl_pool),
    .aybz_azby_pool(aybz_azby_pool)

);

always_comb begin
    case(comp_sel)
        3'b000: done = 0;
        3'b001: done = done_conv;
        3'b010: done = done_dense;
        3'b011: done = done_pool;
        default: done = 0;
    endcase
end

always_comb begin
    
    start_conv = 0;
    start_dense = 0;
    start_pool = 0;

    if(start_comp) begin
    
    case(comp_sel)
        3'b001: start_conv = 1;
        3'b010: start_dense = 1;
        3'b011: start_pool = 1;
    endcase

    end

end




endmodule

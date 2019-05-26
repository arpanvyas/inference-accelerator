module computation_controller (

    input   logic clk,
    input   logic rst,
    input   logic   [2:0]   comp_sel,
    interface_regfile   regfile,
    interface_pe_array  intf_pea,
    interface_buffer    intf_buf1,
    interface_buffer    intf_buf2

);


logic   en_conv;
interface_pe_array_ctrl    intf_pea_ctrl_conv();
interface_buffer_m1_ctrl   intf_buf1_m1_ctrl_conv();
interface_buffer_m1_ctrl   intf_buf2_m1_ctrl_conv();
logic   aybz_azby_conv;

assign  en_conv = (comp_sel == 3'b001);

conv    conv_inst (
    .clk(clk),
    .rst(rst),
    .regfile(regfile),
    .en(en_conv),
    .intf_pea_ctrl(intf_pea_ctrl_conv),
    .intf_buf1_m1_ctrl(intf_buf1_m1_ctrl_conv),
    .intf_buf2_m1_ctrl(intf_buf2_m1_ctrl_conv),
    .aybz_azby(aybz_azby_conv)

);



logic   en_dense;
interface_pe_array_ctrl    intf_pea_ctrl_dense();
interface_buffer_m1_ctrl   intf_buf1_m1_ctrl_dense();
interface_buffer_m1_ctrl   intf_buf2_m1_ctrl_dense();
logic   aybz_azby_dense;

dense   dense_inst (
    .clk(clk),
    .rst(rst),
    .regfile(regfile),
    .en(en_dense),
    .intf_pea_ctrl(intf_pea_ctrl_dense),
    .intf_buf1_m1_ctrl(intf_buf1_m1_ctrl_dense),
    .intf_buf2_m1_ctrl(intf_buf2_m1_ctrl_dense),
    .aybz_azby(aybz_azby_dense)
);



logic   en_pool;
interface_pe_array_ctrl    intf_pea_ctrl_pool();
interface_buffer_m1_ctrl   intf_buf1_m1_ctrl_pool();
interface_buffer_m1_ctrl   intf_buf2_m1_ctrl_pool();
logic   aybz_azby_pool;

pool    pool_inst (
    .clk(clk),
    .rst(rst),
    .regfile(regfile),
    .en(en_pool),
    .intf_pea_ctrl(intf_pea_ctrl_pool),
    .intf_buf1_m1_ctrl(intf_buf1_m1_ctrl_pool),
    .intf_buf2_m1_ctrl(intf_buf2_m1_ctrl_pool),
    .aybz_azby(aybz_azby_pool)

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





endmodule

`include "header.vh"
module adder_tree(
    input								        rst,
    input								        clk,
    input								        adder_enable,
    input   logic           [`N_PE-1:0]         mac_enable,
    input   logic signed	[`WID_PE_BITS-1:0]	output_mac  [`N_PE-1:0],
    output  logic signed	[`WID_PE_BITS-1:0]	adder_tree_out
);


logic   signed [`WID_PE_BITS-1:0]	cleaned_output_mac		[`N_PE-1:0];

logic signed [`WID_PE_BITS-1:0]	adder_stage1	[`N_PE/2-1:0];  //

`ifdef TILL_NP4
logic signed [`WID_PE_BITS-1:0]	adder_stage2	[`N_PE/4-1:0];  //
`endif

`ifdef TILL_NP8
logic signed [`WID_PE_BITS-1:0]	adder_stage3	[`N_PE/8-1:0];  //
`endif

`ifdef TILL_NP16
logic signed [`WID_PE_BITS-1:0]	adder_stage4	[`N_PE/16-1:0]; //
`endif

`ifdef TILL_NP32
logic signed [`WID_PE_BITS-1:0]	adder_stage5    [`N_PE/32-1:0]; //
`endif

`ifdef TILL_NP64
logic signed [`WID_PE_BITS-1:0] adder_stage6    [`N_PE/64-1:0]; //
`endif

`ifdef TILL_NP128 
logic signed [`WID_PE_BITS-1:0] adder_stage7    [`N_PE/128-1:0];
`endif

integer					i1,i2,i3,i4,i5,i6,i7;


always_comb begin
    for(int i0 = 0; i0 < `N_PE; i0 = i0 + 1) begin

        if(mac_enable[i0] == 1) begin
            cleaned_output_mac[i0] = output_mac[i0];

        end else begin
            cleaned_output_mac[i0] = 0;
        end

    end

end

always @(posedge clk, posedge rst)
begin
    if(rst) begin
        for(i1=0;i1<`N_PE/2;i1=i1+1) begin
            adder_stage1[i1]	<= #1 0;
        end

        `ifdef TILL_NP4
        for(i2=0;i2<`N_PE/4;i2=i2+1) begin
            adder_stage2[i2]	<= #1 0;
        end
        `endif

        `ifdef TILL_NP8
        for(i3=0;i3<`N_PE/8;i3=i3+1) begin
            adder_stage3[i3]	<= #1 0;				
        end
        `endif

        `ifdef TILL_NP16
        for(i4=0;i4<`N_PE/16;i4=i4+1) begin
            adder_stage4[i4]	<= #1 0;								
        end
        `endif

        `ifdef TILL_NP32
        for(i5=0;i5<`N_PE/32;i5=i5+1) begin
            adder_stage5[i4]	<= #1 0;								
        end
        `endif

        `ifdef TILL_NP64
        for(i6=0;i6<`N_PE/64;i6=i6+1) begin
            adder_stage6[i4]	<= #1 0;								
        end
        `endif

        `ifdef TILL_NP128
        for(i7=0;i7<`N_PE/128;i7=i7+1) begin
            adder_stage7[i4]	<= #1 0;								
        end
        `endif


    end else begin
        if(adder_enable) begin


            for(i1=0;i1<`N_PE/2;i1=i1+1) begin
                adder_stage1[i1]	<= #1 cleaned_output_mac[2*i1]+cleaned_output_mac[2*i1+1];
            end

            `ifdef TILL_NP4
            for(i2=0;i2<`N_PE/4;i2=i2+1) begin
                adder_stage2[i2]	<= #1 adder_stage1[2*i2]+adder_stage1[2*i2+1];
            end
            `endif

            `ifdef TILL_NP8
            for(i3=0;i3<`N_PE/8;i3=i3+1) begin
                adder_stage3[i3]	<= #1 adder_stage2[2*i3]+adder_stage2[2*i3+1];				
            end
            `endif

            `ifdef TILL_NP16
            for(i4=0;i4<`N_PE/16;i4=i4+1) begin
                adder_stage4[i4]	<= #1 adder_stage3[2*i4]+adder_stage3[2*i4+1];								
            end
            `endif

            `ifdef TILL_NP32
            for(i5=0;i5<`N_PE/32;i5=i5+1) begin
                adder_stage5[i5]	<= #1 adder_stage4[2*i5]+adder_stage4[2*i5+1];								
            end
            `endif

            `ifdef TILL_NP64
            for(i6=0;i6<`N_PE/64;i6=i6+1) begin
                adder_stage6[i6]	<= #1 adder_stage5[2*i6]+adder_stage5[2*i6+1];								
            end
            `endif

            `ifdef TILL_NP128
            for(i7=0;i7<`N_PE/128;i7=i7+1) begin
                adder_stage7[i7]	<= #1 adder_stage6[2*i7]+adder_stage6[2*i7+1];								
            end
            `endif

        end		
    end
end

`ifdef NP4
assign adder_tree_out = adder_stage2[0];
`endif

`ifdef NP8
assign adder_tree_out = adder_stage3[0];
`endif

`ifdef NP16
assign adder_tree_out = adder_stage4[0];
`endif

`ifdef NP32
assign adder_tree_out = adder_stage5[0];
`endif

`ifdef NP64
assign adder_tree_out = adder_stage6[0];
`endif

`ifdef NP128
assign adder_tree_out = adder_stage7[0];
`endif











endmodule
